-- RELCO Wheels, migration 0006.
--
-- Signing up, for every provider at once.
--
-- The gap: profiles.id references auth.users, and every row level security policy compares a column
-- to auth.uid(). But nothing created the profiles row. So any sign-up produced an auth user with no
-- profile behind it, which means a signed-in visitor whose account did not exist as far as the rest
-- of the database was concerned: no listing they could post, no thread they could reply on, no
-- profile page. Every provider had this problem, Google and Apple included, and it is why sign-in
-- could not be turned on by configuration alone.
--
-- Two things here.
--
-- 1. The auth_provider enum has no 'apple'. It was written with email, google, facebook and mobile,
--    and Apple arrives without warning. Adding it now rather than when somebody tries to sign in.
--
-- 2. A trigger on auth.users that creates the profile, the private contact record and the identity
--    row, in one place, for whatever provider the sign-up came through. This is the standard Supabase
--    shape and it is the right one here: it fires inside the sign-up transaction, so a failure means
--    the account is not created at all rather than half created.
--
-- Note what this function does NOT do: it never invents a name the person can be confused by, and it
-- never weakens the impersonation guard. A Google name that fails the rule is repaired to something
-- legal, and if it cannot be repaired the account still gets a working profile. A sign-up that fails
-- because somebody's name had a hyphen in it would be a support ticket for every fifth user.
--
-- Idempotent.

begin;

-- ---------------------------------------------------------------------------
-- 1. Apple is a provider now
-- ---------------------------------------------------------------------------

alter type public.auth_provider add value if not exists 'apple';

-- ---------------------------------------------------------------------------
-- 2. A profile for every new auth user
-- ---------------------------------------------------------------------------

create or replace function public.handle_new_auth_user() returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public, private
as $$
declare
  meta       jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  app_meta   jsonb := coalesce(new.raw_app_meta_data, '{}'::jsonb);
  raw_provider text := lower(coalesce(app_meta->>'provider', 'email'));
  prov       public.auth_provider;
  name_in    text;
  local_part text := split_part(coalesce(new.email, ''), '@', 1);
  email_in   text := nullif(btrim(coalesce(new.email, '')), '');
  base_name  text;
  candidate  text;
  suffix     text;
  counter    int := 0;
  x          int;
  base_handle text;
  handle_in  text;
begin
  -- Unknown providers fall back to 'email' rather than failing the cast and killing the sign-up.
  -- Named `prov`, not `provider`: a variable with the same name as the column it feeds is ambiguous
  -- inside PL/pgSQL and fails at run time, not at creation time.
  prov := case
    when raw_provider in ('google', 'facebook', 'mobile', 'apple') then raw_provider::public.auth_provider
    else 'email'::public.auth_provider
  end;

  -- A display name that satisfies the rule the table already enforces: letters and spaces, starts
  -- with a letter, 3 to 25 characters. Prefer what the provider gave us.
  name_in := coalesce(meta->>'full_name', meta->>'name', '');
  base_name := regexp_replace(name_in, '[^A-Za-z ]', '', 'g');
  if char_length(btrim(base_name)) < 3 then
    base_name := regexp_replace(local_part, '[^A-Za-z ]', '', 'g');
  end if;
  if char_length(btrim(base_name)) < 3 then
    base_name := 'Member';
  end if;

  base_name := btrim(regexp_replace(base_name, '\s+', ' ', 'g'));
  base_name := left(base_name, 25);
  if base_name !~ '^[A-Za-z]' then
    base_name := 'M' || base_name;
  end if;

  -- Sanitise for the impersonation rule BEFORE the collision loop. Appending a suffix cannot fix a
  -- forbidden word, so a name like "RELCO Admin" would spin that loop forever: every candidate would
  -- still contain "relco". Found by writing the test for it.
  if base_name ~* '(r[ _.-]*e[ _.-]*l[ _.-]*c[ _.-]*o|wheels|admin|staff|moderator)' then
    base_name := 'Member';
  end if;

  -- Resolve collisions with a letters-only suffix, because the rule forbids digits in a display name
  -- and "Ali 2" is therefore not available to us.
  candidate := base_name;
  loop
    exit when char_length(candidate) between 3 and 25
      and candidate ~ '^[A-Za-z][A-Za-z ]{2,24}$'
      and candidate !~* '(r[ _.-]*e[ _.-]*l[ _.-]*c[ _.-]*o|wheels|admin|staff|moderator)'
      and not exists (select 1 from public.profiles p where p.display_name = candidate);
    counter := counter + 1;
    x := counter;
    suffix := '';
    while x > 0 loop
      suffix := chr(97 + ((x - 1) % 26)) || suffix;
      x := (x - 1) / 26;
    end loop;
    candidate := left(base_name, greatest(3, 25 - char_length(suffix) - 1)) || ' ' || suffix;
  end loop;

  -- The handle allows digits and underscores, so it can use a plain counter.
  base_handle := lower(coalesce(nullif(regexp_replace(name_in, '[^A-Za-z0-9]', '', 'g'), ''), local_part, ''));
  base_handle := lower(regexp_replace(base_handle, '[^a-z0-9]', '', 'g'));
  if base_handle = '' or base_handle !~ '^[a-z0-9]' then
    base_handle := 'member' || base_handle;
  end if;
  base_handle := left(base_handle, 24);
  if char_length(base_handle) < 3 then
    base_handle := rpad(base_handle, 3, 'x');
  end if;

  handle_in := base_handle;
  counter := 0;
  while exists (select 1 from public.profiles p where p.handle = handle_in) loop
    counter := counter + 1;
    handle_in := left(base_handle, 20) || counter::text;
  end loop;

  insert into public.profiles (id, display_name, handle, terms_version)
  values (new.id, candidate, handle_in, '2026-10');

  -- The email lives in the private schema. profiles.email was dropped in 0003 precisely so that it
  -- could not be read through the API, and this is where it went.
  if email_in is not null then
    insert into private.profile_contacts (user_id, email, email_verified_at)
    values (new.id, email_in, new.email_confirmed_at)
    on conflict (user_id) do nothing;
  end if;

  if new.phone is not null then
    insert into private.profile_contacts (user_id, phone, phone_verified_at)
    values (new.id, new.phone, new.phone_confirmed_at)
    on conflict (user_id) do update
      set phone = excluded.phone,
          phone_verified_at = excluded.phone_verified_at,
          updated_at = now();
  end if;

  -- Which provider this account came through, and what it called them there. user_identities was
  -- built for exactly this and had nothing writing to it.
  insert into private.user_identities (user_id, provider, provider_uid, email_at_provider)
  values (
    new.id,
    prov,
    coalesce(meta->>'provider_id', meta->>'sub', new.id::text),
    email_in
  )
  on conflict (provider, provider_uid) do nothing;

  return new;
end $$;

comment on function public.handle_new_auth_user() is
  'Creates the public profile, the private contact record and the identity row for a new auth user, '
  'so that a signed-in visitor exists as far as every row level security policy is concerned. '
  'Repairs a display name that the table rules would reject rather than failing the sign-up.';

drop trigger if exists auth_users_create_profile on auth.users;
create trigger auth_users_create_profile
  after insert on auth.users
  for each row execute function public.handle_new_auth_user();

-- ---------------------------------------------------------------------------
-- 3. The trigger is not a public function
-- ---------------------------------------------------------------------------
--
-- It fires as the table owner and needs no grant. Revoking keeps it off the RPC surface, which is
-- the same rule 0003 applied to every other function in this schema.

revoke execute on function public.handle_new_auth_user() from public;
revoke execute on function public.handle_new_auth_user() from anon;
revoke execute on function public.handle_new_auth_user() from authenticated;

commit;
