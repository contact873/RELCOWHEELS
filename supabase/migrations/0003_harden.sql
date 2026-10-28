-- RELCO Wheels, migration 0003.
--
-- A security pass. Nothing here adds a feature; everything here closes a way in.
--
-- The threat model in one sentence: Supabase exposes the `public` schema through PostgREST, so every
-- table in it is reachable with the publishable key that ships in the browser. Row level security is
-- the only filter. Therefore one table with RLS off is a breach, one permissive write policy is a
-- breach, and one SECURITY DEFINER function callable by anon is a privilege escalation.
--
-- The answer is not a better policy. It is to stop putting sensitive things in `public` at all:
-- anything the browser has no business reading moves to `private`, which PostgREST does not expose,
-- and is reached only by server code holding the secret key.
--
--
-- WHY THIS FILE IS IDEMPOTENT, AND WHY THAT MATTERS
--
-- The first version of this file was not. It was a sequence of unguarded statements, and the Supabase
-- SQL editor commits each one as it goes rather than running the lot in a transaction. So when it
-- failed partway, it left the database half-hardened: the six tables had moved, and every retry then
-- died on its very first statement with `relation "public.leads" does not exist`.
--
-- A migration that cannot be safely re-run is a hazard, and a security migration that leaves the
-- database in an unknown state is worse than one that never ran. So every statement below is guarded:
-- moves check whether the table is still in `public`, column drops use IF EXISTS, copies check whether
-- the source column still exists, and the whole thing runs inside one transaction so a failure leaves
-- nothing half-applied.
--
-- Run it as many times as you like. The second run is a no-op.
--
-- Run tools/dbcheck before applying it anywhere that matters.

begin;

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
-- These are the tables where a single mistake in a policy would be unrecoverable rather than
-- embarrassing:
--
--   leads              every buyer phone number, and the evidence the lead invoices rest on
--   auth_events        sign-in history, including IP addresses
--   user_identities    which provider each person used, and their identifier there
--   user_push_tokens   device tokens, which allow a push notification to one specific person
--   user_trust         moderation standing, which an attacker would love to reset
--   reports            who reported whom, which is itself sensitive
--
-- Each is moved only if it is still in `public`. On a second run they are already in `private` and
-- the block does nothing.

do $$
declare
  t text;
begin
  foreach t in array array['leads', 'auth_events', 'user_identities', 'user_push_tokens',
                           'user_trust', 'reports']
  loop
    if exists (
      select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = t and c.relkind = 'r'
    ) then
      execute format('alter table public.%I set schema private', t);
      raise notice 'moved public.% to private', t;
    end if;
  end loop;
end $$;

-- Policies on a table the API cannot reach are noise, and noise is how a real gap gets missed. RLS
-- stays enabled with no policies, so the rule is unambiguous: nothing gets in except the service
-- role, which bypasses RLS by design.
--
-- Dropped by iterating the catalogue rather than by name, because a hardcoded list of policy names
-- stops matching the moment somebody renames one.

do $$
declare
  p record;
begin
  for p in select policyname, tablename from pg_policies where schemaname = 'private'
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
    if exists (
      select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'private' and c.relname = t and c.relkind = 'r'
    ) then
      execute format('alter table private.%I enable row level security', t);
      execute format('revoke all on private.%I from anon, authenticated', t);
      execute format('grant all on private.%I to service_role', t);
    end if;
  end loop;
end $$;

-- Sequences have their own privileges and are easy to forget. A service role that can insert but not
-- advance the sequence fails at the first write.
grant usage, select on all sequences in schema private to service_role;
revoke all on all sequences in schema private from anon, authenticated;

-- ---------------------------------------------------------------------------
-- 3. Take the contact details out of the exposed schema entirely
-- ---------------------------------------------------------------------------
--
-- 0001 protected profiles.email with a column level revoke. That works, but it relies on nobody ever
-- selecting the column through a view, a function, or a careless `select *`. Moving the data is a
-- stronger guarantee than restricting access to it.
--
-- The copy runs before the drop, and the copy is skipped if the column is already gone. That is what
-- makes the whole block safe to repeat.

create table if not exists private.profile_contacts (
  user_id    uuid primary key references public.profiles(id) on delete cascade,
  email      citext unique,
  phone      text unique check (phone is null or phone ~ '^\+[1-9][0-9]{7,14}$'),
  email_verified_at timestamptz,
  phone_verified_at timestamptz,
  updated_at timestamptz not null default now()
);

do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'profiles' and column_name = 'email'
  ) then
    insert into private.profile_contacts (user_id, email, phone, email_verified_at, phone_verified_at)
    select id, email, phone, email_verified_at, phone_verified_at from public.profiles
    on conflict (user_id) do nothing;
  end if;
end $$;

alter table public.profiles drop column if exists email;
alter table public.profiles drop column if exists phone;
alter table public.profiles drop column if exists email_verified_at;
alter table public.profiles drop column if exists phone_verified_at;

-- Dealer contact numbers, for the same reason and one more.
--
-- It is a business number rather than a private one, so the privacy argument is weaker, but the
-- commercial argument is stronger: the lead ledger is the revenue. If dealer numbers are readable at
-- /rest/v1/dealers, anyone can harvest every dealer on the platform and call them directly, and the
-- thing we sell stops being worth anything.

create table if not exists private.dealer_contacts (
  dealer_id uuid primary key references public.dealers(id) on delete cascade,
  phone     text,
  whatsapp  text,
  updated_at timestamptz not null default now()
);

do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'dealers' and column_name = 'phone'
  ) then
    insert into private.dealer_contacts (dealer_id, phone, whatsapp)
    select id, phone, whatsapp from public.dealers
    on conflict (dealer_id) do nothing;
  end if;
end $$;

alter table public.dealers drop column if exists phone;
alter table public.dealers drop column if exists whatsapp;

alter table private.dealer_contacts enable row level security;
revoke all on private.dealer_contacts from anon, authenticated;
grant all on private.dealer_contacts to service_role;

alter table private.profile_contacts enable row level security;
revoke all on private.profile_contacts from anon, authenticated;
grant all on private.profile_contacts to service_role;

create or replace function private.touch_updated_at() returns trigger
language plpgsql set search_path = pg_catalog as $$
begin
  new.updated_at := now();
  return new;
end $$;

drop trigger if exists profile_contacts_touch on private.profile_contacts;
create trigger profile_contacts_touch before update on private.profile_contacts
  for each row execute function private.touch_updated_at();

drop trigger if exists dealer_contacts_touch on private.dealer_contacts;
create trigger dealer_contacts_touch before update on private.dealer_contacts
  for each row execute function private.touch_updated_at();

-- ---------------------------------------------------------------------------
-- 4. Pin every function's search_path, and stop granting EXECUTE to the world
-- ---------------------------------------------------------------------------
--
-- Postgres grants EXECUTE on a new function to PUBLIC, which in an exposed schema makes every
-- function an unauthenticated RPC endpoint. And a SECURITY DEFINER function that resolves its tables
-- through the caller's search_path can be pointed at attacker-controlled objects. Both are closed
-- here.
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

drop trigger if exists profiles_create_trust on public.profiles;
create trigger profiles_create_trust after insert on public.profiles
  for each row execute function private.create_user_trust();

-- Moving a table does not move the functions that touch it. The original public.create_user_trust
-- survives the move above: a SECURITY DEFINER function with no pinned search_path, still sitting in
-- the exposed schema. Dead code is where a future session reintroduces a hole, so it goes.
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

-- Every other function is a trigger helper. Triggers fire as the table owner and do not consult
-- EXECUTE at fire time, so these need no grants at all, and granting them would recreate the RPC
-- surface this section exists to remove.
do $$
declare
  f record;
begin
  for f in
    select p.oid::regprocedure as sig
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname in ('public', 'private')
      and p.proname <> 'is_admin'
  loop
    execute format('revoke execute on function %s from public, anon, authenticated', f.sig);
  end loop;
end $$;

grant execute on all functions in schema private to service_role;

-- ---------------------------------------------------------------------------
-- 5. Least privilege on the exposed schema
-- ---------------------------------------------------------------------------
--
-- Supabase grants ALL on every table in public to anon and authenticated by default, unless
-- "automatically expose new tables" was turned off at project creation. Most of that is never used,
-- and an unused privilege is a free option for an attacker. Start from nothing, then grant the two
-- things the application actually does.

revoke all on all tables in schema public from anon;
revoke all on all tables in schema public from authenticated;

-- Readable by anyone, signed in or not. The catalogue and published content.
grant select on
  public.cities, public.city_areas, public.makes, public.models, public.variants, public.features,
  public.dealers, public.listings, public.listing_photos, public.listing_features, public.inspections,
  public.articles, public.tags, public.article_tags,
  public.forum_categories, public.threads, public.posts, public.post_revisions, public.reactions,
  public.profiles
to anon, authenticated;

-- Writable by a signed in member, always filtered again by row level security. No delete on listings:
-- withdrawing a listing is a status change, not a row deletion, so the price history survives.
grant insert, update on
  public.profiles, public.dealers, public.listings, public.listing_photos, public.listing_features,
  public.saved_searches, public.follows,
  public.articles, public.article_tags, public.threads, public.posts, public.reactions
to authenticated;

grant delete on
  public.saved_searches, public.follows, public.posts, public.threads, public.article_tags
to authenticated;

grant usage, select on all sequences in schema public to authenticated;

-- Nothing else. Not inspections: those are written by an inspector through server code, never by a
-- browser. Not tags or forum_categories: those are ours.

-- ---------------------------------------------------------------------------
-- 6. What this file cannot do, and where the remaining risk lives
-- ---------------------------------------------------------------------------
--
-- Five things are configured in the dashboard rather than in SQL. They must be checked by hand, once,
-- and they are listed here so they are not forgotten:
--
--   a. API settings, Exposed schemas. It must read `public, graphql_public` and NOT `private`.
--      Nothing in this file can enforce that, and if somebody adds `private` there, every table in
--      section 2 becomes reachable again. Check it after creating the project.
--
--   b. Storage buckets. Car photographs may be in a public bucket. Registration books, inspection
--      reports and anything showing a plate that identifies an owner must be in a private bucket
--      served through signed URLs with a short expiry.
--
--   c. Realtime. Do not add any table to the `supabase_realtime` publication. It streams row changes
--      to every subscriber and does not re-check row level security per column.
--
--   d. The secret key. It bypasses every rule in this file. Vercel server-side environment variables
--      only, never with a NEXT_PUBLIC_ prefix.
--
--   e. Automatically expose new tables, at project creation. Turning it off means new tables fail
--      closed and need an explicit grant, which is why section 5 exists.

comment on schema public is
  'Exposed by PostgREST. Every table here is reachable with the publishable key, so row level '
  'security is the only filter. Anything not intended for the browser belongs in the private schema.';

commit;
