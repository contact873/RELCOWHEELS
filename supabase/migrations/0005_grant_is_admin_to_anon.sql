-- RELCO Wheels, migration 0005.
--
-- Grant anon execute on is_admin().
--
-- A real defect, found by probing the live API with the publishable key rather than by reading these
-- files. Six publicly readable tables answered an unauthenticated client with
--
--   42501  permission denied for function is_admin
--
--   listings, articles, threads, posts, post_revisions, profiles
--
-- Which is the marketplace, the blog, the forum and every member and seller page. The site would have
-- gone blank the moment it stopped reading seed data and started reading the database, and it would
-- have looked like an empty database rather than a permissions fault.
--
-- The cause is not a missing table grant. 0003 revoked execute on every function from PUBLIC and
-- granted it back only to authenticated and service_role, and it revoked this one from anon by name.
-- But a row level security policy is evaluated by whoever is reading the table, and every predicate
-- inside it runs as that role. The policy on listings reads:
--
--   using (status = 'live' or status = 'sold' or seller_id = auth.uid() or is_admin())
--
-- An anonymous reader has to be able to call is_admin() for that expression to be evaluated at all.
-- Postgres does not short-circuit its way past it: a function the reader cannot execute takes the
-- whole table down, not merely the admin branch. The revoke removed the admin branch and the table
-- with it.
--
-- Granting it leaks nothing. is_admin() takes no arguments and answers exactly one question, whether
-- the caller is an admin. For an anonymous caller auth.uid() is null, so the answer is false, and it
-- is false for every row.
--
-- Everything else in 0003's revoke stays revoked, and should. Every other function in public is a
-- trigger helper, and triggers fire as the table owner without consulting EXECUTE, so no caller needs
-- a grant on them. is_admin() is the only function a policy calls, and it is the only one this
-- migration restores. That distinction is asserted in tools/dbcheck, which now fails if anon can
-- execute anything other than this single function.
--
-- Idempotent.

begin;

grant execute on function public.is_admin() to anon;

comment on function public.is_admin() is
  'Referenced by row level security policies, so anon must be able to execute it or the tables that '
  'use those policies become unreadable to the public. It takes no arguments and reveals only whether '
  'the caller is an admin, which is false for anyone unauthenticated.';

commit;
