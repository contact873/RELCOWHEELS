-- RELCO Wheels, migration 0003.
--
-- A security pass. Nothing here changes a feature; everything here closes a way in.
--
-- The threat model is simple and worth stating once. Supabase exposes the `public` schema through
-- PostgREST, so every table in it is reachable at /rest/v1/<table> with the anon key, which is
-- shipped in the browser. Row level security is the only thing filtering those requests. That means:
--
--   * one table with RLS disabled is a data breach
--   * one policy written as `using (true)` on a write is a data breach
--   * one SECURITY DEFINER function callable by anon is a privilege escalation
--   * one SECURITY DEFINER function without a pinned search_path is a privilege escalation
--
-- The answer to "how do I stop the public schema disclosing through the API" is not a better policy.
-- It is to stop putting sensitive things in the public schema. Anything the browser has no business
-- reading moves to `private`, which PostgREST does not expose at all, and is reached only by server
-- code holding the service role key.
--
-- Run tools/dbcheck after this file, not before.

-- ---------------------------------------------------------------------------
-- 1. A schema the API cannot reach
-- ---------------------------------------------------------------------------

create schema if not exists private;

revoke all on schema private from public;
revoke all on schema private from anon;
revoke all on schema private from authenticated;
grant usage on schema private to service_role;

comment on schema private is
  'Not exposed by PostgREST. Reached only by server code using the service role key. Anything here '
  'is invisible to the browser regardless of what any policy says, which is the point.';

-- ---------------------------------------------------------------------------
-- 2. Move the server-only tables out of the exposed schema
-- ---------------------------------------------------------------------------
--
-- Each of these was reachable at /rest/v1/<table> before this migration. They are the tables where a
-- single mistake in a policy would be unrecoverable rather than embarrassing:
--
--   leads              every buyer phone number, and the evidence the lead invoices rest on
--   auth_events        sign-in history, including IP addresses
--   user_identities    which provider each person used, and the identifiers at that provider
--   user_push_tokens   device tokens, which allow push notification to a specific person
--   user_trust         moderation standing, which an attacker would love to reset
--   reports            who reported whom, which is itself sensitive

alter table public.leads            set schema private;
alter table public.auth_events      set schema private;
alter table public.user_identities  set schema private;
alter table public.user_push_tokens set schema private;
alter table public.user_trust       set schema private;
alter table public.reports          set schema private;

-- Policies on a table the API cannot reach are not defence in depth, they are noise, and noise is
-- how a real gap gets missed. RLS stays enabled with no policies, so the rule is unambiguous:
-- nothing gets in except the service role, which bypasses RLS by design.
--
-- Dropped by iterating the catalogue rather than by naming them, because a hardcoded list of policy
-- names silently stops matching the moment somebody renames one.
do $$
declare
  p record;
begin
  for p in
    select policyname, tablename from pg_policies where schemaname = 'private'
  loop
    execute format('drop policy %I on private.%I', p.policyname, p.tablename);
  end loop;
end $$;

do $$
declare
  t text;
begin
  foreach t in array array['leads', 'auth_events', 'user_identities', 'user_push_tokens',
                           'user_trust', 'reports']
  loop
    execute format('alter table private.%I enable row level security', t);
    execute format('revoke all on private.%I from anon, authenticated', t);
    execute format('grant all on private.%I to service_role', t);
  end loop;
end $$;

-- Sequences have their own privileges and are easy to forget. A service role that can insert but not
-- advance the sequence will fail at the first write.
grant usage, select on all sequences in schema private to service_role;
revoke all on all sequences in schema private from anon, authenticated;

-- ---------------------------------------------------------------------------
-- 3. Take the contact details out of the exposed schema entirely
-- ---------------------------------------------------------------------------
--
-- 0001 protected profiles.email with a column level revoke. That works, but it relies on nobody ever
-- selecting the column through a view, a function or a careless `select *`. Moving the data is a
-- stronger guarantee than restricting access to it, and it costs nothing to do before launch.
--
-- What follows is the same reasoning that made PakWheels emit a hashed email in its page payload
-- rather than the address itself, taken to its conclusion: the address is not in the reachable
-- schema at all.

create table private.profile_contacts (
  user_id    uuid primary key references public.profiles(id) on delete cascade,
  email      citext unique,
  phone      text unique check (phone is null or phone ~ '^\+[1-9][0-9]{7,14}$'),
  email_verified_at timestamptz,
  phone_verified_at timestamptz,
  updated_at timestamptz not null default now()
);

insert into private.profile_contacts (user_id, email, phone, email_verified_at, phone_verified_at)
select id, email, phone, email_verified_at, phone_verified_at from public.profiles;

alter table public.profiles drop column email;
alter table public.profiles drop column phone;
alter table public.profiles drop column email_verified_at;
alter table public.profiles drop column phone_verified_at;

alter table private.profile_contacts enable row level security;
revoke all on private.profile_contacts from anon, authenticated;
grant all on private.profile_contacts to service_role;

create or replace function private.touch_updated_at() returns trigger
language plpgsql set search_path = pg_catalog as $$
begin
  new.updated_at := now();
  return new;
end $$;

create trigger profile_contacts_touch before update on private.profile_contacts
  for each row execute function private.touch_updated_at();

-- Dealer contact numbers, for the same reason and one more.
--
-- Found by the security assertions in tools/dbcheck, which flagged dealers.phone as personal data
-- still sitting in the exposed schema. It is a business number rather than a private one, so the
-- privacy argument is weaker, but the commercial argument is stronger: the lead ledger is the
-- revenue. If dealer numbers are readable at /rest/v1/dealers, anyone can harvest every dealer on
-- the platform and call them directly, and the thing we sell stops being worth anything.
--
-- The public dealer page shows the name, city and about text. The number is released through the
-- lead flow, server side, which also means every reveal is recorded.

create table private.dealer_contacts (
  dealer_id uuid primary key references public.dealers(id) on delete cascade,
  phone     text,
  whatsapp  text,
  updated_at timestamptz not null default now()
);

insert into private.dealer_contacts (dealer_id, phone, whatsapp)
select id, phone, whatsapp from public.dealers;

alter table public.dealers drop column phone;
alter table public.dealers drop column whatsapp;

alter table private.dealer_contacts enable row level security;
revoke all on private.dealer_contacts from anon, authenticated;
grant all on private.dealer_contacts to service_role;

create trigger dealer_contacts_touch before update on private.dealer_contacts
  for each row execute function private.touch_updated_at();

-- ---------------------------------------------------------------------------
-- 4. Pin every function's search_path, and stop granting EXECUTE to the world
-- ---------------------------------------------------------------------------
--
-- Postgres grants EXECUTE on a new function to PUBLIC. In an exposed schema that makes every
-- function an unauthenticated RPC endpoint. And a SECURITY DEFINER function that resolves its
-- tables through the caller's search_path can be pointed at attacker-controlled objects. Both are
-- closed here rather than left to be discovered.
--
-- The four functions below are recreated because they read user_trust, which has just moved.

create or replace function private.create_user_trust() returns trigger
language plpgsql security definer set search_path = pg_catalog, public, private as $$
begin
  insert into private.user_trust (user_id) values (new.id) on conflict do nothing;
  return new;
end $$;

create or replace function public.hold_first_post() returns trigger
language plpgsql set search_path = pg_catalog, public, private as $$
declare
  still_held boolean;
begin
  select first_post_held into still_held from private.user_trust where user_id = new.author_id;
  if coalesce(still_held, true) and new.status = 'visible' then
    new.status := 'held';
  end if;
  return new;
end $$;

create or replace function public.release_first_post_hold() returns trigger
language plpgsql set search_path = pg_catalog, public, private as $$
begin
  if old.status = 'held' and new.status = 'visible' then
    update private.user_trust set first_post_held = false where user_id = new.author_id;
  end if;
  return new;
end $$;

create or replace function public.limit_first_post_links() returns trigger
language plpgsql set search_path = pg_catalog, public, private as $$
declare
  still_held boolean;
  links      int;
begin
  select first_post_held into still_held from private.user_trust where user_id = new.author_id;
  links := (length(new.body_md) - length(replace(new.body_md, 'http', ''))) / 4;

  if coalesce(still_held, true) and links > 0 then
    raise exception 'A first post may not contain links.';
  end if;
  if not coalesce(still_held, true) and links > 3 then
    raise exception 'That post has too many links.';
  end if;
  return new;
end $$;

-- The trigger that used to call public.create_user_trust now points at the private one.
drop trigger if exists profiles_create_trust on public.profiles;

create trigger profiles_create_trust after insert on public.profiles
  for each row execute function private.create_user_trust();

-- Moving a table does not move the functions that touch it. The original public.create_user_trust
-- survived the move above: a SECURITY DEFINER function with no pinned search_path, still sitting in
-- the exposed schema. Dead code is exactly where a future session reintroduces a hole, so it goes.
drop function if exists public.create_user_trust();

-- is_admin() is called from inside row level security policies, and a policy is evaluated as the
-- querying role, so `authenticated` genuinely needs EXECUTE on it. Everything else does not.
create or replace function public.is_admin() returns boolean
language sql security definer stable set search_path = pg_catalog, public as $$
  select exists (select 1 from profiles where id = auth.uid() and role = 'admin');
$$;

revoke execute on function public.is_admin() from public;
revoke execute on function public.is_admin() from anon;
grant  execute on function public.is_admin() to authenticated;
grant  execute on function public.is_admin() to service_role;

-- Every other function in the exposed schema is a trigger helper. Triggers fire as the table owner
-- and do not consult EXECUTE at fire time, so these need no grants at all, and granting them would
-- recreate the RPC surface this section exists to remove.
do $$
declare
  f record;
begin
  for f in
    select p.oid::regprocedure as sig, n.nspname, p.proname
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname in ('public', 'private')
      and p.proname not in ('is_admin')
  loop
    execute format('revoke execute on function %s from public, anon, authenticated', f.sig);
  end loop;
end $$;

-- Anything the service role still needs, it keeps.
grant execute on all functions in schema private to service_role;

-- ---------------------------------------------------------------------------
-- 5. Least privilege on the exposed schema
-- ---------------------------------------------------------------------------
--
-- Supabase grants ALL on every table in public to anon and authenticated. Most of that is never
-- used, and an unused privilege is a free option for an attacker. Start from nothing, then grant the
-- two things the application actually does: read public content, and write your own content.

revoke all on all tables in schema public from anon;
revoke all on all tables in schema public from authenticated;

-- Readable by anyone, signed in or not. This is the catalogue and published content.
grant select on
  public.cities, public.city_areas, public.makes, public.models, public.variants, public.features,
  public.dealers, public.listings, public.listing_photos, public.listing_features, public.inspections,
  public.articles, public.tags, public.article_tags,
  public.forum_categories, public.threads, public.posts, public.post_revisions, public.reactions,
  public.profiles
to anon, authenticated;

-- Writable by a signed in member, always filtered again by row level security. No delete on
-- listings here: withdrawing a listing is a status change, not a row deletion, so the price history
-- survives.
grant insert, update on
  public.profiles, public.dealers, public.listings, public.listing_photos, public.listing_features,
  public.saved_searches, public.follows,
  public.articles, public.article_tags, public.threads, public.posts, public.reactions
to authenticated;

grant delete on
  public.saved_searches, public.follows, public.posts, public.threads, public.article_tags
to authenticated;

-- Sequences in the exposed schema, for the tables a member inserts into.
grant usage, select on all sequences in schema public to authenticated;

-- Nothing else. Not inspections: those are written by an inspector through server code, never by a
-- browser. Not tags or forum_categories: those are ours.

-- ---------------------------------------------------------------------------
-- 6. What this file cannot do, and where the remaining risk lives
-- ---------------------------------------------------------------------------
--
-- Four things are configured in the Supabase dashboard rather than in SQL. They must be checked by
-- hand, once, and they are listed here so they are not forgotten:
--
--   a. API settings, Exposed schemas. It must read `public, graphql_public` and NOT `private`.
--      Nothing in this file can enforce that, and if somebody adds `private` there, every table in
--      this migration becomes reachable again. Check it after creating the project.
--
--   b. Storage buckets. Car photographs may be in a public bucket. Registration books, inspection
--      reports and anything with a number plate that identifies an owner must be in a private bucket
--      served through signed URLs with a short expiry.
--
--   c. Realtime. Do not add any table to the `supabase_realtime` publication. Realtime streams row
--      changes to every subscriber, and it does not re-check row level security per column.
--
--   d. The service role key. It bypasses every rule in this file. It must exist only in Vercel's
--      server-side environment variables, never with a NEXT_PUBLIC_ prefix. A build check for that
--      belongs in the site's check script.
--
-- One more, deliberately left out: `alter default privileges` would stop future tables being
-- auto-granted to anon. It is not included because a surprising revoke in a later migration fails at
-- the worst moment, and because this project creates tables rarely. If that changes, add:
--
--   alter default privileges in schema public revoke all on tables from anon, authenticated;

comment on schema public is
  'Exposed by PostgREST. Every table here is reachable with the anon key, so row level security is '
  'the only filter. Anything not intended for the browser belongs in the private schema.';
