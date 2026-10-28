# dbcheck

Runs the migrations against a real Postgres and tests the triggers.

```bash
cd ~/Documents/apps/RELCOWHEELS/tools/dbcheck
npm install          # once
npm run check
```

## Why this exists

There is no Postgres or Docker installed on this machine, so the migrations could not otherwise be
executed before being pasted into Supabase's SQL editor. A migration that does not parse is worthless
and the failure surfaces at the worst possible moment, mid-deploy. pglite is a WebAssembly build of
Postgres 16 that runs in Node, so the SQL is genuinely executed rather than pattern matched.

It has already earned its place. Three defects were found by running it which reading the file did
not catch:

1. **Row level security was disabled on six tables.** `cities`, `city_areas`, `features`, `makes`,
   `models` and `variants` had no RLS. In Supabase the public schema is exposed through the API and
   the `anon` and `authenticated` roles hold privileges on those tables, so the entire vehicle
   catalogue would have been writable by any visitor with a curl command. Fixed by enabling RLS with
   a read-only policy on all six.
2. **A member could self-publish an article.** The review guard only ran on update, so inserting a
   row already marked `published` skipped it, which defeats pre-approval for articles entirely. Fixed
   with a guard on insert and a narrower insert policy.
3. **The reply counter compared ids across two unrelated sequences**, so `reply_count` would have
   been quietly wrong from the first reply.

## What it checks

- Every statement in both migrations executes, with line numbers on any failure.
- The counts: 28 tables, 15 functions, 23 triggers, 51 policies.
- **Every table has row level security enabled.** Printed as `28 of 28`.
- Fourteen behaviour tests, including: a first post is held and then released permanently on
  approval, counters track visibility changes, edits record a revision, link limits apply, an
  accepted answer must belong to its own thread, an article cannot be self-published, only an
  administrator can publish, the thread rate limit holds at three per day, and a display name cannot
  impersonate the platform.

## What it cannot prove

Be honest about the gaps before trusting a pass:

| Gap | Consequence |
|---|---|
| `citext` is unavailable in pglite | It is substituted with `text`. Case-insensitive uniqueness is **untested**. Supabase does have `citext`, so this is a harness limitation, not a schema one. |
| `pg_trgm` is unavailable | The three trigram indexes are stripped before execution. Full text search performance is **untested**. |
| pglite runs as the table owner | **Row level security is bypassed**, so these tests exercise triggers, not policies. A policy that is wrong will still pass here. |
| No Supabase `auth` | `auth.users` and `auth.uid()` are stubbed. `auth.uid()` always returns null, so anything depending on the signed-in user is untested. |

So a green run means the schema parses, the triggers behave, and no table was left unprotected. It
does **not** mean the access rules are right. That has to be checked against the real database by
signing in as two different accounts and trying to read each other's rows.

## Next time

Re-run this after any schema change, before running the migration in Supabase. If it reports
`28 of 28` and all behaviour tests pass, the migration is safe to apply.
