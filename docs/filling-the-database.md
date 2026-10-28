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
4. data/catalogue.sql     fills makes, models and variants
5. a dealer's stock       fills listings
```

`0003` runs before the catalogue on purpose: it is the migration that changes where `user_trust` and
`leads` live, and running it after data exists means moving rows rather than moving an empty table.

## Step 1 to 3: the schema

Supabase, **SQL Editor**, **New query**. Paste one file, run it, then the next.

```
supabase/migrations/0001_init.sql
supabase/migrations/0002_blog_forum.sql
supabase/migrations/0003_harden.sql
```

Each should report success. If `0003` fails on `create schema private`, run `create schema private;`
alone first and re-run the file.

**This is where most of the data actually arrives**, which surprises people. Cities, Lahore's twelve
city areas, the fourteen equipment keys, six forum categories and seven article tags all ship inside
the migrations, because they are fixed reference data that never changes rather than content somebody
maintains.

## Step 4: the vehicle catalogue

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

## Step 5: your stock

Two ways in, and they are for different situations.

**A dealer hands you a file.** Fill in `templates/dealer-stock-template.csv`, then:

```bash
node tools/import-dealer-stock.mjs stock/zahid-autos.csv --dealer zahid_autos --dry-run
node tools/import-dealer-stock.mjs stock/zahid-autos.csv --dealer zahid_autos --out stock/zahid.sql
```

Paste `stock/zahid.sql` into the SQL editor. The importer refuses the whole file if any row fails,
because a partly imported stock list is worse than none.

It also creates the make, model and variant if they do not exist yet, so a dealer can list a car the
catalogue has never seen.

**A member posts it themselves.** That is the `/sell` flow, and it needs the auth wiring finished and
the service role key present on the server. Until then, use the CSV route.

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
