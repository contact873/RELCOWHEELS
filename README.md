# RELCOWHEELS

A used-car marketplace for Pakistan. Lahore first.

Brand: **RELCO Wheels**
Domain: `wheels.relcoai.com` to launch, `relcowheels.com` once it earns
Tagline: **Know what you're buying.**
Identity: cool grey-white ground, verified green, Archivo Expanded + Public Sans + IBM Plex Mono

---

## What is in this folder

```
RELCOWHEELS/
  README.md                     this file
  identity.json                 the property's colour and type fingerprint, read by the checker

  docs/
    plan-marketplace.md         the full build plan: routes, schema, SEO, lead engine, costs, risks
    plan-design-identity.md     the portfolio-wide design strategy, and why this property looks the way it does
    dealer-onboarding.md        the consent process, the wording to use, and who to visit
    supabase-setup.md           the browser steps to connect the database, and the checks that prove it
    filling-the-database.md     what goes in, in what order, and how
    color-schemes.html          eight palette options, with contrast ratios computed live
    palette-proposal-connect.html   the Connect before and after

  data/
    catalogue.json              22 makes, 71 models, 117 variants. Edit here, not in a migration
    catalogue.sql               generated. Paste into Supabase

  site/                         the Next.js 15 application
    src/app/tokens.css          THE FILE THAT DEFINES HOW THIS SITE LOOKS. Start here.
    src/app/globals.css         base layer, component classes
    src/app/layout.tsx          fonts, metadata, header, footer, cookie consent
    src/components/             header, footer, cookie consent
    src/lib/types.ts            types mirroring the database
    src/lib/seed.ts             seed content, so the site renders before Supabase exists
    src/lib/format.ts           PKR, lakh and crore, mileage, relative dates
    src/lib/render.ts           sanitises every piece of user authored HTML
    .env.example                the four environment variables

  supabase/migrations/
    0001_init.sql               catalogue, registered visitors, listings, the lead ledger, RLS
    0002_blog_forum.sql         articles, tags, forum categories, threads, posts, revisions, reactions
    0003_harden.sql             the private schema, least privilege, pinned search_path
  tools/dbcheck/                executes all three migrations, the catalogue seed, and 26 tests
  tools/check-site.mjs          the site gate: dashes, sanitiser, secrets, h1, identity, gitignore
  tools/seed-catalogue.mjs      turns data/catalogue.json into idempotent SQL
  tools/import-dealer-stock.mjs turns a dealer's CSV into SQL, refusing the whole file if any row fails
  templates/                    the CSV a dealer fills in

  brand/                        logo, tagline lockups and exports. See brand/BRAND-WHEELS.md
    logo/                       7 SVGs: mark, roundel, three lockups, two mono variants
    png/                        17 exports, 16px to 1600px
    preview.html                open this first. Every variant inlined
    tools/                      build-pngs, build-preview, verify-pngs
  tools/                        checkers: identity, and the site gate
```

## Running it

```bash
cd RELCOWHEELS/site
npm install
npm run dev          # http://127.0.0.1:3000
```

It runs with no configuration. Every page renders from `src/lib/seed.ts` until a Supabase project
exists, and a visible marker appears on the site while it is doing so.

To connect a real database, copy `.env.example` to `.env.local` and fill in the Supabase values.

## Before you edit the look

Read `site/src/app/tokens.css`. Every colour on the site comes from that one file. Nothing else
declares a hex value, so a palette change is a single-file change.

Then run:

```bash
node ../tools/check-identity.mjs
```

It fails if this property's colours or typefaces collide with another RELCO property. See
`docs/plan-design-identity.md` for why that matters.

## The two navigation services

Supabase, for the database, sign-in and photograph storage, and Vercel, for hosting. The plan
explains the reasoning. Both are free at this size, and the first real cost is photograph storage,
somewhere between 250 and 400 listings.

## Where the money comes from

Not from listings and not from advertising. From **leads**. A buyer reveals a seller's phone number
or sends a message, that is recorded in the `leads` table, and it is forwarded to the seller over
WhatsApp. That table is append only because it is the invoice evidence.

We do not charge a dealer until they have watched their own numbers for at least a month.

## Security posture

The threat model is one sentence: **Supabase exposes the `public` schema through its API, so every
table in it is reachable with the anon key that ships in the browser.** Row level security is the
only thing filtering those requests. Everything below follows from that.

**Two schemas, not one.** `public` holds what the browser legitimately reads and writes, guarded by
RLS and by least privilege. `private` is not exposed by PostgREST at all, and is reached only by
server code holding the service role key. Six tables were moved out of `public` in `0003`, because a
single wrong policy on any of them would have been unrecoverable rather than embarrassing:

| Moved to `private` | Why it must never be reachable |
|---|---|
| `leads` | Every buyer phone number, and the evidence the lead invoices rest on |
| `auth_events` | Sign-in history, including IP addresses |
| `user_identities` | Which provider each person used, and their identifier there |
| `user_push_tokens` | Device tokens, which can push a notification to one specific person |
| `user_trust` | Moderation standing, which an attacker would love to reset |
| `reports` | Who reported whom, which is itself sensitive |

**Contact details are not in the exposed schema at all.** `profiles.email`, `profiles.phone` and
`dealers.phone` moved to `private.profile_contacts` and `private.dealer_contacts`. Restricting a
column is weaker than removing it: a column grant can be undone by a view, a function, or one
careless `select *`. The dealer numbers matter twice over, because the lead ledger is the revenue and
a readable `dealers.phone` would let anyone harvest every dealer on the platform and call them
directly.

**Least privilege on what remains.** `anon` gets `SELECT` and nothing else. `authenticated` gets
`SELECT` plus writes only on the tables a member actually writes. No table grants delete on listings,
because withdrawing a listing is a status change, not a row deletion, so the price history survives.

**Functions are not endpoints.** Postgres grants `EXECUTE` on a new function to `PUBLIC`, which in an
exposed schema makes every function an unauthenticated RPC. All are revoked. `is_admin()` keeps
`EXECUTE` for `authenticated` only, because RLS policies call it as the querying role. Every
`SECURITY DEFINER` function pins its `search_path`, so it cannot be pointed at attacker-controlled
objects.

**User HTML is sanitised on render, not on write.** `src/lib/render.ts` allowlists about twenty tags,
strips `data:` and `javascript:` URLs, and forces `rel="nofollow noopener noreferrer"` on every link.
Sanitising on the way out means a mistake at write time cannot become a stored attack.

### Four things set in the Supabase dashboard that SQL cannot enforce

Check these once, by hand, after creating the project. If any is wrong, the work above is undone.

1. **API settings, Exposed schemas.** Must read `public, graphql_public` and **not** `private`. If
   somebody adds `private` there, every table listed above becomes reachable again.
2. **Storage buckets.** Car photographs may be public. Registration books, inspection reports and
   anything showing an owner-identifying plate must be in a private bucket served by short-lived
   signed URLs.
3. **Realtime.** Do not add any table to the `supabase_realtime` publication. Realtime streams row
   changes to every subscriber and does not re-check RLS per column.
4. **The service role key.** It bypasses every rule in this document. Vercel server-side environment
   variables only, never with a `NEXT_PUBLIC_` prefix. `npm run check:site` fails the build if a
   public-prefixed secret appears in the source.

### The three gates

```bash
cd ~/Documents/apps/RELCOWHEELS/site
npm run check:site        # dashes, sanitiser, secrets, h1 count, identity, gitignore
npm run check:identity    # no two RELCO properties look alike
npm run check:db          # all three migrations execute, plus 23 behaviour and security tests
```

### Still open

- **The identity collisions in the portfolio.** `npm run check:identity` reports 12 problems across 13
  claims in 11 properties. They have two root causes, not twelve: the corporate kit is being worn by
  Connect and Business OS, and Fraunces plus Inter became the default everywhere. The full mapping and
  the remediation sequence are in `~/Documents/apps/DESIGN-IDENTITY.md`, and the proposed Connect
  palette is at `docs/palette-proposal-connect.html`, awaiting a decision rather than a machine check.
- **Row level security is not exercised by the tests.** `tools/dbcheck` runs as the table owner, so it
  proves the triggers, not the policies. Policies must be checked against the real database by
  signing in as two accounts and attempting to read each other's rows.
- **`citext` and `pg_trgm` are untested** locally, because the embedded Postgres used for validation
  does not have them. Case-insensitive uniqueness and the trigram search indexes will be exercised
  for the first time in Supabase.
- **No rate limiting at the edge.** The database rate limits posting, but nothing limits anonymous
  reads. Add Vercel or Cloudflare rate limiting before the site is promoted anywhere.

## Standing rules for anything added here

1. **No em dashes.** Not in copy, not in markup, not in code comments.
2. **One `h1` per page.**
3. **Every listing page carries `Vehicle` and `Offer` structured data.** `mileageFromOdometer` is a
   `QuantitativeValue` in kilometres, never a formatted string.
4. **Never return an email address to a client.** The column is revoked at the database level.
5. **No shadows.** This identity reads as documentation. A drop shadow reads as a consumer app.
6. **Self-host everything.** No hotlinked photographs, no Google Fonts by `<link>`.
7. **Real photographs only.** No stock photography standing in for a car.

## Status

| Part | State |
|---|---|
| Marketplace plan | Written, `docs/plan-marketplace.md` |
| Design identity strategy | Written, `docs/plan-design-identity.md` |
| Dealer onboarding and consent | Written, `docs/dealer-onboarding.md` |
| Database schema, core | Written, `supabase/migrations/0001_init.sql` |
| Database schema, blog and forum | Written, `supabase/migrations/0002_blog_forum.sql` |
| Security hardening | Written, `supabase/migrations/0003_harden.sql` |
| Schema validation | 315 statements and 26 behaviour and security tests pass, 30 of 30 tables have RLS. `tools/dbcheck` |
| Vehicle catalogue | 22 makes, 71 models, 117 variants. Generates idempotent SQL, verified to load twice without duplicating |
| Site gate | 6 checks pass across 60 built pages. `npm run check:site` |
| Application scaffold | Built: tokens, layout, header, footer, cookie consent, sample notice |
| Pages | Built, 21 routes, 66 static pages |
| SEO plumbing | `robots.ts` and `sitemap.ts`, both gated on whether a database is configured |
| Logo and tagline lockups | Built: 7 SVGs, 17 PNG exports, measured. `brand/BRAND-WHEELS.md` |
| Repository | Initialised and committed locally at `0ad0d5d`, 96 files, working tree clean |
| Seed data | 26 cars, 6 articles, 6 forum threads, 3 profiles |
| Supabase project | Not created. Needs a browser |
| Deployment | Not deployed. `DEPLOY.md` is ready |

### Pages that exist

```
/                       home
/cars                   browse, with facets and a working sort
/car/[slug]             26 car pages, Vehicle plus Offer structured data
/blog  /blog/[slug]     6 articles, BlogPosting structured data
/forum                  index
/forum/[category]       6 categories
/forum/t/[slug]         6 threads, DiscussionForumPosting structured data
/forum/u/[handle]       3 public profiles
/forum/new  /write  /sell  /find-my-car      forms, built and disabled pending a database
/auth/sign-in           provider buttons, noindex
/privacy  /terms  /cookies  /safety  /about-sample-data
```

Verified: `npm run build` passes with no type errors, every generated page has exactly one `h1`,
there are no em dashes or en dashes anywhere in the source, and every internal link resolves to a
real route.

## Next, in order

Everything that can be done without a browser is done. What is left:

1. **Create the Supabase project and run the three migrations.** `docs/supabase-setup.md` has the
   exact steps, the two verification queries, and the four dashboard settings SQL cannot enforce.
2. **Push to GitHub and import to Vercel.** `DEPLOY.md` has the steps. Remember the Root Directory is
   `site`, not the repo root.
3. **Seed `makes`, `models` and `variants`.** They are deliberately empty. Until they exist,
   `/cars?make=suzuki` returns nothing.
4. **Seed real stock.** Two hundred to three hundred Lahore cars, on the ground, with the dealer's
   written permission. `docs/dealer-onboarding.md` is the process, `tools/import-dealer-stock.mjs` is
   the importer.
5. **The portfolio re-skins in `DESIGN-IDENTITY.md` section 6.** Connect and Business OS are done.
   Consolidated, Agent School and the two demo templates still need their typefaces changed, and the
   identity checker reports 5 remaining collisions until they are.
