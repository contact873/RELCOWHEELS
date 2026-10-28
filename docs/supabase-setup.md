# Connecting the database

Everything except this is done. The site builds, runs, and passes its gates on sample content. These
are the steps that turn it into a real marketplace, in the order they have to happen.

Estimated: twenty minutes, mostly waiting for the project to provision.

---

## 1. Create the Supabase project

1. Go to `https://supabase.com/dashboard` and sign in.
2. **New project**.
3. Name: `relco-wheels`
4. **Region: Southeast Asia (Singapore).** Not the default US region. Pakistan is roughly 200ms from
   Singapore and 250ms from Frankfurt, but every query here is regional traffic, so pick the nearest.
5. Database password: generate one and **store it in a password manager**. It is shown once and it is
   not the same as the keys you will use in the app.
6. Plan: Free.

Wait for provisioning, about two minutes.

## 2. Copy the two keys

**Project Settings, API.**

| Value | Where it goes |
|---|---|
| Project URL | `NEXT_PUBLIC_SUPABASE_URL` |
| `anon` / publishable key | `NEXT_PUBLIC_SUPABASE_ANON_KEY` |
| `service_role` / secret key | `SUPABASE_SERVICE_ROLE_KEY` |

The service role key bypasses every row level security policy in the database. It goes in Vercel's
server-side environment variables and in `site/.env.local`. It never gets a `NEXT_PUBLIC_` prefix. The
site gate fails the build if a public-prefixed secret appears in the source.

## 3. Run the migrations, in order

**SQL Editor, New query.** Paste one file at a time and run it. Do not paste all three together; if
the second fails you want to know which one.

```
site/../supabase/migrations/0001_init.sql     catalogue, visitors, listings, lead ledger
             0002_blog_forum.sql              articles, forum, posts, revisions
             0003_harden.sql                  private schema, least privilege
```

Paths from the project root:

```
supabase/migrations/0001_init.sql
supabase/migrations/0002_blog_forum.sql
supabase/migrations/0003_harden.sql
```

Each should report success. `0003` moves six tables into a new `private` schema, which is the step
that takes buyer phone numbers and dealer numbers out of the API's reach.

**If `0003` errors on `create schema private`**, run `create schema private;` on its own first and then
re-run the file. Some Supabase roles cannot create schemas inside a transaction.

## 4. Prove it worked

Paste this into the SQL editor. It should return the numbers shown.

```sql
select
  (select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relkind = 'r')            as exposed_tables,   -- 22
  (select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'private' and c.relkind = 'r')           as private_tables,   -- 8
  (select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname in ('public','private') and c.relkind = 'r' and c.relrowsecurity)
                                                               as tables_with_rls,  -- 30
  (select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname in ('public','private') and c.relkind = 'r') as total_tables;   -- 30
```

And this one should return **zero rows**. If it returns anything, a personal column is still reachable
through the API and `0003` did not finish.

```sql
select table_name, column_name
from information_schema.columns
where table_schema = 'public'
  and column_name in ('email', 'phone', 'phone_verified_at', 'email_verified_at');
```

## 5. The four settings SQL cannot set

These live in the dashboard. If any is wrong, everything in step 3 is undone.

### a. Exposed schemas

**Project Settings, API, Exposed schemas.**

Must read exactly `public, graphql_public`. It must **not** contain `private`. If somebody adds it
there, `leads`, `profile_contacts`, `dealer_contacts` and the rest become readable by anyone with the
anon key, and no policy in the database can stop it.

This is the single most important item in this document.

### b. Storage

**Storage, New bucket.**

| Bucket | Public | Holds |
|---|---|---|
| `car-photos` | Yes | Listing photographs. Nothing personal. |
| `documents` | **No** | Registration books, inspection PDFs, anything showing a plate that identifies an owner |

The private bucket is served through signed URLs with a short expiry. Never a public URL.

### c. Realtime

**Database, Replication.** The `supabase_realtime` publication should list **no tables**. Realtime
broadcasts row changes to every subscriber and does not re-check row level security per column. Adding
`profiles` or `leads` here would defeat the entire design.

### d. Authentication providers

**Authentication, Providers.**

- **Google**: enable, add the client ID and secret from Google Cloud Console. Authorised redirect:
  `https://<project-ref>.supabase.co/auth/v1/callback`
- **Facebook**: same, with the app secret from developers.facebook.com.
- **Email**: enable, for the people who have no social account.

Phone sign-in is **deferred deliberately**. Every code SMS costs money, and there is no revenue yet.
It goes in after the first dealer pays for leads.

## 6. Point the site at it

Locally:

```bash
cd ~/Documents/apps/RELCOWHEELS/site
cp .env.example .env.local
```

Fill in the three Supabase values and set `NEXT_PUBLIC_SITE_URL` to the address you will actually use.

Then in Vercel: **Settings, Environment Variables**, same four values, for Production and Preview.

## 7. What changes by itself once it is connected

Nothing needs switching on. All four of these key off whether a database is configured:

| Changes | Why |
|---|---|
| The **Sample content** banner disappears | `src/components/sample-notice.tsx` |
| `robots.txt` stops disallowing everything | `src/app/robots.ts` |
| `sitemap.xml` stops being empty and lists listings, articles, categories and threads | `src/app/sitemap.ts` |
| The forms stop being disabled | They were waiting for a database |

That is the point of gating them on configuration rather than on a flag somebody has to remember.

## 8. Seed the catalogue, then the stock

`makes`, `models` and `variants` are deliberately empty. They number in the thousands and belong in a
data file, not a migration. Until they exist, `/cars?make=suzuki` will return nothing.

That is the next piece of work, and it is a lot of typing rather than a lot of thinking. Then real
stock, which is the fieldwork in `docs/dealer-onboarding.md`: two hundred to three hundred Lahore cars,
photographed, with the dealer's written permission.

---

## Order of operations, for the impatient

```
create project  ->  copy 3 keys  ->  run 3 migrations  ->  run the 2 checks
  ->  set the 4 dashboard items  ->  enable Google + Facebook  ->  paste keys into Vercel
  ->  deploy  ->  seed makes and models  ->  import the first dealer's stock
```

The site is buildable and reviewable at any point before the database exists. Do not wait for it.
