# Filling the database

Five things go into the database, in this order. Two of them are already written into the migrations,
so in practice you run four SQL files and one is generated on demand.

| What | Where it comes from | How it gets in |
|---|---|---|
| Tables, policies, triggers | `supabase/migrations/*.sql` | Paste into the SQL editor |
| Cities, city areas, equipment list | `0001_init.sql`, at the bottom | Comes with the migration |
| Forum categories, article tags | `0002_blog_forum.sql`, at the bottom | Comes with the migration |
| The vehicle catalogue | `data/catalogue.json` | `tools/seed-catalogue.mjs`, then paste the SQL |
| Your stock | A dealer's CSV | `tools/import-dealer-stock.mjs`, then paste the SQL |
| Users and dealers | People signing up, or the service role | Automatic on sign up |

---

## The order

Do not skip ahead. Each step depends on the one above it.

```
1. 0001_init.sql          creates the tables and the reference data
2. 0002_blog_forum.sql    creates the content tables
3. 0003_harden.sql        moves the sensitive tables into the private schema
4. 0004_staff_created_stock.sql  lets a dealer and their stock exist before a signup
5. data/catalogue.sql     fills makes, models and variants
6. a dealer's stock       fills listings
```

`0003` runs before the catalogue on purpose: it is the migration that changes where `user_trust` and
`leads` live, and running it after data exists means moving rows rather than moving an empty table.

`0004` runs before any stock because it is what makes stock possible at all. See step 4.

## Steps 1 to 3: the schema

Supabase, **SQL Editor**, **New query**. Paste one file, run it, then the next.

```
supabase/migrations/0001_init.sql
supabase/migrations/0002_blog_forum.sql
supabase/migrations/0003_harden.sql
supabase/migrations/0004_staff_created_stock.sql
supabase/migrations/0005_grant_is_admin_to_anon.sql
```

Each should report success. If `0003` fails on `create schema private`, run `create schema private;`
alone first and re-run the file.

**This is where most of the data actually arrives**, which surprises people. Cities, Lahore's twelve
city areas, the fourteen equipment keys, six forum categories and seven article tags all ship inside
the migrations, because they are fixed reference data that never changes rather than content somebody
maintains.

## Step 4: allow dealers who have not signed up yet

`0004_staff_created_stock.sql`. Easy to skip and it breaks everything after it.

The plan is that the first two hundred to three hundred cars go up because somebody walks into a
showroom, photographs the cars and posts them on the dealer's behalf. The schema as first written made
that impossible: `profiles.id` references `auth.users`, so a profile only exists once a person has
signed up, and `listings.seller_id` was `NOT NULL`. No car could be listed until its seller had an
account, which is the exact opposite of how a cold start works.

What `0004` changes:

| Before | After |
|---|---|
| `dealers.owner_id` NOT NULL | Nullable. A dealer record exists as a business before anyone claims it |
| `listings.seller_id` NOT NULL | Nullable, with a new constraint requiring a seller **or** a dealer. Never neither |
| `leads.seller_id` NOT NULL | Nullable, with the same recipient rule |
| Policies only recognised `seller_id = auth.uid()` | A dealer can also manage and price the stock posted for them |

`profiles.id` deliberately still references `auth.users`. Every row-level security policy compares a
column to `auth.uid()`, and if that link were removed, all of them would silently stop matching. The
fix belongs at the dealer and listing level, not the identity level.

## Step 5: the vehicle catalogue

`makes`, `models` and `variants` are deliberately empty in the migrations. They are the thing that
changes whenever a new model launches, and a migration that has to be edited every time is a migration
nobody trusts. So they live in a data file and are generated into SQL.

```bash
cd ~/Documents/apps/RELCOWHEELS

# check the file without writing anything
node tools/seed-catalogue.mjs --dry-run

# produce the SQL
node tools/seed-catalogue.mjs --out data/catalogue.sql
```

Then paste `data/catalogue.sql` into the Supabase SQL editor and run it.

Current contents: **22 makes, 71 models, 117 variants**, covering every body type the site facets by.
It is idempotent, so running it again after adding a model updates rather than duplicating.

**To add a model**, edit `data/catalogue.json`, regenerate, and run it again. That is the whole
workflow. Keep `slug` matching `name` in lower case with hyphens, because the slug becomes the URL.

## Step 6: your stock

The importer does more than import. **It creates the dealer record if one does not exist**, with
`owner_id` left null, so you do not need the dealer to have signed up first. That is what `0004` is
for, and it is the difference between "post this dealer's cars for them" working and not working.

```bash
node tools/import-dealer-stock.mjs stock/zahid-autos.csv \
  --dealer zahid_autos --dealer-name "Zahid Autos" --dry-run

# when it reports clean, emit the SQL
node tools/import-dealer-stock.mjs stock/zahid-autos.csv \
  --dealer zahid_autos --dealer-name "Zahid Autos" --out stock/zahid_autos.sql
```

Other options: `--city lahore` (default), `--out <path>`.

**`stock/` is gitignored, and should stay that way.** A generated stock file carries real dealer
contact details, real prices and real registration numbers. Treat it like a customer list, not like
source code. The one exception committed to the repository is
`tools/dbcheck/fixtures/zahid_autos.sql`, which is the template rehearsed, carries a banner saying its
cars are invented, and exists only so the test harness can run the import end to end.

Paste `stock/zahid_autos.sql` into the SQL editor. The importer refuses the whole file if any row
fails, because a partly imported stock list is worse than none, and it creates any make, model or
variant the catalogue has never seen.

When the dealer eventually signs up, claim their record by setting `owner_id`, and they can then edit
and price their own stock through the site.

## Running SQL without the dashboard

If you would rather not paste into a browser, use the connection string:

```bash
psql "postgres://postgres:[password]@db.[project-ref].supabase.co:5432/postgres" \
  -f supabase/migrations/0001_init.sql
```

Get the string from **Project Settings, Database, Connection string, URI**. It contains the database
password, not the API keys, so it is a different secret. Do not commit it.

## Check that it worked

```sql
select
  (select count(*) from cities)          as cities,        -- 18
  (select count(*) from city_areas)      as areas,         -- 12
  (select count(*) from forum_categories) as categories,   -- 6
  (select count(*) from makes)           as makes,         -- 22
  (select count(*) from models)          as models,        -- 71
  (select count(*) from variants)        as variants,      -- 117
  (select count(*) from listings)        as listings;      -- 0 until step 5
```

`listings` at zero is correct until you import stock. Everything else at zero means a step above did
not run.

## What is still empty on purpose, and why

- **`listings`**: nobody has imported stock yet. The site renders its sample content instead.
- **`profiles`**: created when somebody signs up. There is no way to seed users meaningfully, and no
  reason to.
- **`articles`**: the six in the app are sample content. Real articles arrive through `/write` and are
  held for review.
- **`threads` and `posts`**: same. The forum starts empty and fills itself.

## The one thing that is easy to get wrong

**Order.** `0003_harden.sql` moves six tables into the `private` schema. If you run the catalogue or a
stock import before it and then run `0003`, the tables move with their rows intact, which is fine. But
if you run `0003` first and then hand-write SQL against `public.leads`, it will fail with "relation does
not exist" and look like a broken migration rather than a wrong schema name.

The generated files from `tools/` already use the right schema names. Hand-written SQL will not.
