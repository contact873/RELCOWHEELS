# Two Supabase projects: which is which

Recorded because there are now two, they look identical from the outside, and pointing the site at
the wrong one is a mistake that is easy to make and hard to notice. The machine-readable version is
`supabase/projects.json`, which `tools/check-site.mjs` reads.

| Role | Project ref | State |
|---|---|---|
| **Production** | `ecjyqamcegxbnpidrfqb` | Migrations 0001 to 0005 applied, catalogue loaded, security verified against the live API. Vercel points here. |
| **Staging** | `vrgjqwppdeoyhjgmkaca` | **Empty.** Created 2026-10-30. Nothing has been run in it. |

## Why that way round, and how to flip it

Production is the older project because it is the one already proven: five migrations run, the
catalogue loaded, and the security posture confirmed by probing the API rather than by reading the
migrations. Staging is the empty one, which is what you want for the project you are willing to
break.

If the intent was the opposite, that is a two-line change in `supabase/projects.json`. Nothing else
depends on the assignment except the gate warning described below.

## The rules

1. **Local development never points at production.** A mistake made while working should be
   recoverable, and it is not recoverable if it happened to the live database.
2. **A migration runs in staging first.** A migration that fails halfway is a bad afternoon in
   staging and an incident in production. This is not hypothetical: `0003` failed half-applied in
   production once, for exactly this reason, which is why it is now idempotent.
3. **The service role key lives in production only.** It bypasses every row level security policy in
   the database. It never goes on a machine that does not need it and never carries a
   `NEXT_PUBLIC_` prefix.
4. **A new project is assumed insecure until 0001 to 0005 have run.** A fresh Supabase project
   exposes new tables to the API by default. That default is what migration `0003` exists to close,
   and until it runs the database is not merely empty, it is open.

## Bringing staging up

The dashboard for it is at `https://supabase.com/dashboard/project/vrgjqwppdeoyhjgmkaca`.

**Before anything else, the four settings.** They are in Project Settings, and none of them can be
set by SQL. `docs/supabase-setup.md` has the reasoning:

| Setting | Value |
|---|---|
| Automatically expose new tables | **OFF** |
| Enable automatic RLS | **ON** |
| Data API | ON |
| Region | Asia-Pacific, matching production |

**Then the five migrations, in order**, pasted one at a time into the SQL Editor. Not together: if
the third fails you want to know which one.

```
supabase/migrations/0001_init.sql
supabase/migrations/0002_blog_forum.sql
supabase/migrations/0003_harden.sql
supabase/migrations/0004_staff_created_stock.sql
supabase/migrations/0005_grant_is_admin_to_anon.sql
```

**Then the catalogue**, once:

```
data/catalogue.sql
```

That should take `makes` from 0 to 22. If it reports a duplicate key, something was run twice, which
is harmless: every statement in it is an upsert.

**Then the publishable key**, from Project Settings, API. It is the one labelled publishable or
anon, it is public by design, and it is safe to paste into a chat. Send it over and `.env.local` gets
pointed at staging.

## What the gate does about this

`tools/check-site.mjs` reads `supabase/projects.json` and warns when `site/.env.local` contains the
production project ref, because that is the mistake that matters. **It is a warning rather than a
failure today, and only because the split is half done:** production is live and staging is not
ready, so `.env.local` legitimately still points at production.

**It becomes a failure once staging is migrated and `.env.local` points at it.** That is the point at
which pointing local development back at production would be a mistake rather than a necessity.

## Why the live site is unaffected either way

`NEXT_PUBLIC_DATA_SOURCE` is `sample`, and `src/lib/queries.ts` still reads `src/lib/seed.ts`. So no
page reads a database yet, and repointing an environment variable cannot change what a visitor sees
until `queries.ts` starts querying. That is also why this split is cheap to get right now and
expensive to get wrong later.
