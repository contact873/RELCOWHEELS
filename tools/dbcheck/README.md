# dbcheck

Runs the migrations against a real Postgres, then tests the triggers and the access rules.

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

It has already earned its place. Four defects were found by executing the SQL rather than reading it:

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
4. **The public key could not read six of the site's own tables.** `anon` had no execute privilege on
   `is_admin()`, which row level security policies call, so `listings`, `articles`, `threads`, `posts`,
   `post_revisions` and `profiles` all answered the API with `42501 permission denied for function
   is_admin`. The marketplace, the blog, the forum and every member page. It was found by probing the
   live API with the publishable key, not by this harness, because at the time the harness had no way
   to see it. It does now: see the note on switching role below.

Number 4 is the reason for the fourth gap in the shortcomings table, and the reason the anon tests
switch role instead of asserting things about the catalogue.

## What it checks

- Every statement in all five migrations executes, with line numbers on any failure.
- The counts: 30 tables, 16 functions, 25 triggers, 41 policies.
- **Every table has row level security enabled.** Printed as `30 of 30`.
- The public read path, **as the `anon` role**, by switching role first: every table the site reads
  without a sign in is readable, a live listing is visible while a draft is not, and the `private`
  schema refuses the public even when named directly.
- That `anon` can execute `is_admin()` **and nothing else**. An allowlist of exactly one function,
  because the public read path needs that one and no other.
- Behaviour tests, including: a first post is held and then released permanently on approval, counters
  track visibility changes, edits record a revision, link limits apply, an accepted answer must belong
  to its own thread, an article cannot be self-published, only an administrator can publish, the
  thread rate limit holds at three per day, a display name cannot impersonate the platform, a dealer
  and its stock can exist before anyone signs up, and the generated dealer stock file imports end to
  end.

## What it cannot prove

Be honest about the gaps before trusting a pass:

| Gap | Consequence |
|---|---|
| `citext` is unavailable in pglite | It is substituted with `text`. Case-insensitive uniqueness is **untested**. Supabase does have `citext`, so this is a harness limitation, not a schema one. |
| `pg_trgm` is unavailable | The three trigram indexes are stripped before execution. Full text search performance is **untested**. |
| Tests run as the table owner by default | Row level security does not evaluate for the owner, so an assertion made as the owner proves nothing about policies. The `anon` section works around this by switching role with `set role`, and covers the public read path only. **Policies for signed-in members are still untested**, because `auth.uid()` is stubbed and cannot be changed mid-session. |
| No Supabase `auth` | `auth.users` and `auth.uid()` are stubbed. `auth.uid()` always returns null, so anything depending on the signed-in user is untested. This is what leaves the `authenticated` policies unverified. |
| Supabase-specific privileges are not reproduced | The harness grants `anon` and `authenticated` the same privileges the migrations do, against stub roles. It cannot confirm what the real project granted at creation time. Only a probe against the live API proves that, which is how defect 4 was found. |

So a green run means the schema parses, the triggers behave, no table was left unprotected, and the
public read path works as `anon`. It does **not** mean the access rules for signed-in members are
right. That still has to be checked against the real database by signing in as two different accounts
and trying to read each other's rows.

## Next time

Re-run this after any schema change, before running the migration in Supabase. If it reports
`30 of 30` and all behaviour tests pass, the migration is safe to apply. Then probe the live API with
the publishable key, because that is the only thing that tests the real project's privileges rather
than the harness's stubs.

