# RELCO Wheels — a car marketplace, planned against PakWheels

**Project root:** `/Users/misbah/Documents/apps/RELCOWHEELS/`
**Brand:** RELCO Wheels
**Decisions taken:** full marketplace with accounts from day one · Google + Facebook + phone OTP · revenue from selling leads to dealers

---

## 1. What PakWheels actually is

I read their home page, a live ad page, the search results page, their login page, `robots.txt` and `sitemap.xml`, and pulled the JSON-LD out of the markup. This is what is really there.

### 1.1 Stack, as evidenced

Ruby on Rails (there is an `authenticity_token` CSRF field on every page), Algolia for search (`algoliasearch` with a public `applicationId` and search key), Google Ad Manager for ad slots, Firebase Cloud Messaging for web push, OptinMonster for exit-intent popups, and four separate asset hosts (`wsa1`–`wsa4`) plus four image hosts (`cache1`–`cache4`). Fonts are Lato, self-hosted as woff2. There is a web manifest and iOS/Android app deep links, because their traffic is heavily mobile.

### 1.2 URL architecture — the part worth stealing

Every meaningful combination gets its own crawlable, indexable URL, and each carries an internal numeric ID in the path:

```
/used-cars/                                       hub
/used-cars/{city}/{id}                            lahore/24858
/used-cars/{make}/{id}                            suzuki/32
/used-cars/{make}-{model}/{id}                    honda-civic/642
/used-cars/{make}-{model}-{year}/{id}             honda-civic-2018/342545
/used-cars/{make}-{model}-{city}/{id}             honda-civic-lahore/1045
/used-cars/{make}-{model}-{year}-{city}/{id}      honda-civic-2018-lahore/223614
/used-cars/{slug}/{id}                            sedan/107775, 1300cc-cars/191144,
                                                  cars-under-20-lakhs/477658, petrol/57338,
                                                  automatic/57336, family-cars/587667,
                                                  7-seater/266616, 2018/342545
/used-cars/{make}-{model}-{year}-for-sale-in-{city}-{adid}
                                                  honda-civic-2018-for-sale-in-lahore-12121499
/used-cars/search/-/                              search
/used-cars/search/-/featured_1/  direct_1/        saved server-side searches
/new-cars/{make}/{model}/{year}/{variant}         mirrors, plus /compare/{a}-vs-{b}
/bikes/...  /accessories-spare-parts/...          same shape, other verticals
```

Facet query parameters in use: `transmission`, `engine_type`, `color`, `cc`, `registration_city`, `assembly`, `city_area`, `seats`, `body_type`, `category`, `country`, `direct`, `sortby`, `page`.

**The discipline is in what they refuse to index.** `robots.txt` disallows `/*?*sortby=*` and thousands of specific parameterised duplicates, so the clean facet URL is the only one that ranks. They also split sitemaps by vertical (seven of them, gzipped, plus index files) so a crawl never has to swallow the whole site at once.

### 1.3 The ad page, top to bottom

Breadcrumb chain (`Home › Used Cars › Cars Lahore › Honda Lahore › Civic Lahore › Civic 2018 Lahore`) → title → area and city → **Send Message** and **Show Phone Number** → three headline specs (year, mileage, engine) → price in both raw PKR and lacs/crore → `Managed by PakWheels` and `FEATURED` badges → a 25-image gallery → a spec table (registered in, colour, assembly, engine capacity, body type, last updated, ad reference number) → an inspection report with five subscores and an overall rating out of 10 → features grouped into Exterior / Interior / Safety & Security / Comfort & Convenience with icons → seller's comments → price repeated with a finance calculator deep link carrying 30+ prefilled fields → a trust block → a masked phone number → seller details gated behind the phone reveal → safety tips → `Notify as Sold` and `Report this ad` → sponsored partner widgets → **SIMILAR ADS** → a Notify Me panel with email frequency → long SEO internal-link blocks by year, by city, by variant → app promo.

The listing card in search and grid carries: photo with a count badge, featured ribbon, title, price, city, a four-part spec strip, inspection score, "updated N minutes ago", and two CTAs.

**The phone number is the product.** It is masked until clicked. Every reveal is the billable event, tracked through `/increment_phone_count`. That is their monetisation and it is the model you chose.

### 1.4 Structured data

They emit JSON-LD but thinly. Home and login pages get a bare `WebPage`. Service tiles get `WebPage` with a `relatedLink`. Ad listings get `@type: ["Product"]` with `brand`, `model`, `description`, `itemCondition: "used"`, `modelDate`, `manufacturer`, `fuelType`, `name` ("Honda Civic 2018 for sale in Lahore"), `image`, `vehicleTransmission`, `color`, `bodyType`, `vehicleEngine.engineDisplacement`, `mileageFromOdometer` as a string, and `offers` with `price`, `priceCurrency: "PKR"`, `availability: InStock` and `url`.

There is no `BreadcrumbList` anywhere, no `ItemList` on search or facet pages, no `Vehicle` type, and no `SearchAction`. Those are four real openings.

### 1.5 Accounts, and how they sign people in

Google Sign-In through the GIS client (`google-signin-client_id` plus `data-login_uri="/confirm-google-login"`), Facebook SDK with a public app ID, and a mobile-number flow with a 6-digit OTP that auto-submits when the sixth digit lands. `intl-tel-input` defaults to Pakistan. Live availability checks hit `/checkphone`, `/checkemail` and `/check_display_name` as you type.

There is **no LinkedIn and no Apple sign-in**, which is worth noting given what you asked for.

One detail worth copying: clicking any sign-in trigger stashes the current `pathname` into an `intent_url` field, so after authenticating you are returned to the ad you were looking at rather than dumped on a dashboard.

### 1.6 Design and layout

Dense, grey-blue, Lato throughout, blue links, green price text, hard rectangles, heavy on advertising. Ad slots are declared at 970x250, 728x90, 300x250, 1024x90 and two 170x540 skyscrapers on the desktop home page alone, plus a 450x30 sticky bar. It is unmistakably dated, and it is slow. It ranks anyway because of the URL surface and fifteen years of links, not because of the design.

### 1.7 Two things they get wrong, which we will not copy

**Cookies.** GTM, Google Analytics and Ad Manager all fire on page load, before any choice is recorded. There is no cookie banner anywhere in the markup. For a Pakistan-only audience that is survivable, but it is not a pattern worth inheriting, and you asked for consent handling.

**Mobile viewport.** They set `user-scalable=no, maximum-scale=1.0`, which blocks pinch-zoom. That fails accessibility, and it is a habit worth leaving behind.

---

## 2. Decisions for RELCO Wheels

I checked what already exists: you have Next.js 15 on React 19 with Tailwind and TypeScript running in `relco-online-shop` and `relcoai`, so that part is proven. There is no database, no ORM, no auth and no file storage anywhere in the workspace, so all of that is genuinely new.

| Decision | Choice | Why |
|---|---|---|
| Framework | Next.js 15 App Router, React 19, Tailwind 3.4, TypeScript | Same versions already running in `relco-online-shop`. No new learning. |
| Database | Supabase Postgres | Free tier covers this comfortably. Server-side rendering needs a real database, not SQLite on shared hosting. |
| Auth | Supabase Auth | Google and Facebook providers are configuration, not code. Gives us sessions, RLS and a user table for free. |
| Image storage | Supabase Storage | Car photos must not live in git or on cPanel. Includes a CDN. |
| Hosting | Vercel | Already in use for `relcoai` and `maqsood-cars`. Free. |
| Domain | `wheels.relcoai.com` to launch | You already own `relcoai.com`. Register `relcowheels.com` later once it earns, and 301 the subdomain to it. |
| Ad network | None at launch | Their ad load is what makes their pages slow. We sell leads instead, which is your chosen model. |

**Why not cPanel and PHP.** You already have hosting and a working `lead.php` pattern, but a public marketplace takes user uploads and public posting. On shared hosting that means no image CDN, no atomic deploys, no reliable backups of a growing user database, and a much larger attack surface. Your own notes record folder uploads failing four times. Vercel plus Supabase costs the same at this scale, which is nothing.

**Why not NextAuth (Auth.js).** It works, but you would hand-register every OAuth app, hand-roll sessions, and add a second vendor for file storage. Supabase gives all three in one free tier.

---

## 3. Data model

New file: `RELCOWHEELS/supabase/migrations/0001_init.sql`

```
makes            id, name, slug
models           id, make_id, name, slug
variants         id, model_id, name, slug, engine_cc, transmission, fuel
cars             id, variant_id, year            -- the catalogue, not a listing
profiles         id (=auth.users.id), display_name, phone, role, created_at
                                                 -- role: member | dealer | admin
dealers          id, owner_id, name, slug, city_id, phone, verified_at, logo_path
cities           id, name, slug, province
city_areas       id, city_id, name, slug
listings         id, seller_id, car_id, city_id, city_area_id,
                 title, description, price_pkr, mileage_km, color,
                 registered_in_city_id, assembly, body_type, condition,
                 status,               -- draft | pending | live | sold | rejected | expired
                 published_at, expires_at, sold_at, view_count, phone_reveal_count
listing_photos   id, listing_id, storage_path, position, width, height, alt
listing_features id, listing_id, feature_key       -- 'alloy_wheels', 'sun_roof', ...
leads            id, listing_id, seller_id, buyer_id, buyer_phone,
                 channel,              -- phone_reveal | message | whatsapp
                 message, created_at, forwarded_at, outcome
reports          id, listing_id, reporter_id, reason, detail, status, resolved_at
saved_searches   id, user_id, name, filters jsonb, frequency, last_sent_at
sessions_audit   id, actor_id, action, entity, entity_id, created_at
```

Rules that must be enforced in the database, not in application code:

- `listings.status` transitions only through the allowed graph. A `sold` or `rejected` listing can never return to `live` without an admin write.
- `leads` are append-only. No updates to `buyer_phone` or `created_at`, ever. This table is the invoice evidence.
- Row Level Security on every table. A member reads live listings and their own rows. A dealer also reads and writes rows where `seller_id` is theirs. `leads` are readable only by the seller they belong to and by admins.
- `listing_photos` capped at 20 per listing, enforced by a trigger. Storage quotas are what will cost money first.

Indexes that matter from day one: `listings(status, published_at desc)`, `listings(car_id, city_id, status)`, a trigram index on `listings.title` for search, and `leads(seller_id, created_at desc)`.

---

## 4. Routes

```
/                                   home: search, recent listings, makes, cities
/cars                               all live listings, faceted
/cars/lahore                        by city
/cars/suzuki                        by make
/cars/suzuki/alto                   by model
/cars/suzuki/alto/2019              by model and year
/cars/suzuki/alto/lahore            by model and city
/cars/sedan  /cars/1300cc  /cars/under-20-lakh  /cars/automatic  /cars/petrol
/car/{slug}-{adid}                  one listing
/dealers/{slug}                     dealer profile and their stock
/sell                               post an ad (auth required)
/sell/{listingId}/edit
/account  /account/listings  /account/saved-searches  /account/alerts
/auth/sign-in  /auth/sign-up  /auth/callback        noindex, nofollow
/find-my-car                        want-to-buy lead form, no account needed
/compare/{a}-vs-{b}
/blog/{slug}                        price guides and buying advice
/privacy  /terms  /cookies  /safety  /report/{adid}
/admin                              moderation queue, dealers, leads ledger
```

Facet combinations are capped. `/cars/suzuki/alto/2019/lahore/automatic` gets a page only when it has at least three live listings, decided at build time. Everything else canonicalises to its nearest parent facet. This is the rule that stops us generating tens of thousands of thin pages that Google will ignore.

**Crawl discipline**, mirroring theirs but stricter:

`RELCOWHEELS/site/src/app/robots.ts`

```
allowed:  /
disallowed:  /api/  /auth/  /account/  /admin/  /sell/  /report/
             /*?sortby=*  /*?page=*  /*?utm_
sitemaps:    /sitemap-index.xml
```

`/auth/*` and `/account/*` additionally carry `robots: { index: false, follow: false }` in their metadata, exactly as PakWheels does on `/login`.

Sitemaps are generated per facet type and gzipped past 5,000 URLs: `sitemap-cars.xml`, `sitemap-makes.xml`, `sitemap-models.xml`, `sitemap-cities.xml`, `sitemap-facets.xml`, `sitemap-blog.xml`, plus the index. Splitting them is the whole point: a single sitemap will not survive growth.

---

## 5. Structured data

New file: `RELCOWHEELS/site/src/lib/schema.ts`, one builder per shape, all injected through a single `<JsonLd>` component so nothing is hand-written twice.

**Listing page** — use `Vehicle`, which is what PakWheels should be using instead of bare `Product`. It inherits everything from `Product` and adds the fields Google's vehicle guidance actually reads:

```json
{
  "@context": "https://schema.org",
  "@type": "Vehicle",
  "name": "2019 Suzuki Alto VXL for sale in Lahore",
  "brand":    { "@type": "Brand", "name": "Suzuki" },
  "model": "Alto",
  "vehicleModelDate": 2019,
  "bodyType": "Hatchback",
  "color": "White",
  "fuelType": "Petrol",
  "vehicleTransmission": "Manual",
  "mileageFromOdometer": { "@type": "QuantitativeValue", "value": 55000, "unitCode": "KMT" },
  "vehicleEngine": { "@type": "EngineSpecification", "engineDisplacement": { "@type": "QuantitativeValue", "value": 660, "unitCode": "CMQ" } },
  "itemCondition": "https://schema.org/UsedCondition",
  "image": ["https://…/1.jpg", "https://…/2.jpg"],
  "offers": {
    "@type": "Offer",
    "price": 2350000,
    "priceCurrency": "PKR",
    "availability": "https://schema.org/InStock",
    "url": "https://wheels.relcoai.com/car/2019-suzuki-alto-lahore-1042",
    "seller": { "@type": "AutoDealer", "name": "…", "telephone": "+92…" }
  }
}
```

Two rules. `mileageFromOdometer` must be a `QuantitativeValue` with unit `KMT`, not the string `"55,000 km"` that PakWheels uses. And `vehicleIdentificationNumber` is omitted entirely when unknown. Never invent a VIN.

**Also emitted:** `BreadcrumbList` on every listing page and every facet page; `ItemList` on search and facet pages with positions and URLs; `WebSite` with `SearchAction` on the home page for a sitelinks searchbox, which PakWheels does not do; `FAQPage` on price-guide pages; `AutoDealer` with address and `areaServed` on dealer profiles; `CollectionPage` on facet pages; `Organization` sitewide.

---

## 6. Accounts

Built now, per your decision, with one sequencing note attached.

**Phase 1 (free, immediate): Google and Facebook.** Both are configuration inside Supabase, no code. Facebook is worth having because it is how a very large share of Pakistani buyers already log in.

**Phase 2 (costs money per message): phone OTP.** I want to be straight with you: this is the one part of the whole build that cannot be free, because every code sent costs something. Twilio to Pakistan is the most expensive option and has known deliverability problems. Firebase Phone Auth wants the Blaze plan for volume. Supabase's own phone auth routes through Twilio, MessageBird or Vonage, all metered. The cheapest reliable route in Pakistan is a local bulk-SMS gateway on prepaid credit, which means writing the OTP send and verify ourselves against it, roughly a day of work, at local per-message rates far below the international providers.

So Phase 1 ships Google, Facebook and an email sign-in link, and the phone field is collected but verified later. OTP is added in Phase 2, once leads are actually earning, using a local gateway. Building the SMS integration first would spend money before there is any revenue, on the one component that can be swapped in later without touching anything else.

Copy their `intent_url` trick: stash the current path on sign-in click, return the user to the ad afterwards.

---

## 7. The lead engine

This is the business, so it gets built properly from the start rather than bolted on.

A listing shows the phone masked as `03XX-XXXXXXX`. Clicking **Show number** records a row in `leads` with the listing, the seller, the buyer (if signed in) and the buyer's own number captured at that moment. The seller then receives it instantly over WhatsApp, which is how business is actually done here, and email as a fallback. The buyer's number is never shown to the seller as a raw database field; it arrives as a message.

The seller's dashboard shows reveals and messages per listing, per week. That screen is the sales tool: it exists so a dealer can be shown a number, not an argument.

**Somewhere between 10 and 20 signals per listed car per month is the point at which a dealer will pay.** Nothing is charged until a dealer has seen their own figures for at least one month. The `leads` table is append-only precisely so those figures cannot be argued with.

A legal point that has to be right: the buyer's phone number is personal data being passed to a third party. The reveal button must say so plainly before it is pressed ("Your number will be shared with this seller so they can contact you"), `/privacy` must describe it, and there must be a deletion route. Pakistan's data protection law is not yet enforced but this is the direction it is going, and doing it correctly from the start costs nothing.

---

## 8. Cookies and consent

Better than the original, using the pattern from `auctions22.com` which I examined earlier.

No analytics script ships in the initial HTML. A first-party banner offers **Accept all** and **Essential only**. The choice is written to a first-party cookie, and Google Analytics is only injected after a recorded acceptance. Essential-only keeps the site fully working: sign-in, search, posting and messaging all function without analytics. A **Cookie settings** link in the footer reopens the banner so a choice can be changed, and `/cookies` documents what each cookie is for in plain language.

---

## 9. Design

Two files, following the token architecture already proven in `website-demo/tools/theme/`.

`RELCOWHEELS/site/src/app/tokens.css`

Same structural approach as the Relco Digital kit, different accent so Wheels is never mistaken for `connect.raschident.com` or the parts site:

```
--ink      #0C1014     (shared with the Relco Digital parent)
--bone     #F5F1E8     (shared)
--surface  #FFFDF9
--line     #DDD6C8
--accent   #1F5FC9     signal blue: trust, distinctly not the connect orange
--price    #0F7A4A     green, only ever on a price
--warn     #B45309
--danger   #B3261E
--sold     #6B7280     grey, the whole card desaturates once sold
--display  Fraunces
--body     Inter
--mono     JetBrains Mono    prices, mileage, ad reference numbers
```

Neumorphic or glassy treatments are not appropriate for a marketplace. The listing card is the product and it should read like a specification sheet: photo, price in tabular figures, the four-part spec strip, location, and time since posting. Sold listings stay in the index with the card desaturated and a `SOLD` stamp, because a page that ranks and then goes blank throws away the traffic it earned.

Nothing from the PakWheels visual language gets carried over except the information hierarchy, which is genuinely good and deserves to be kept.

**House rule to enforce in the checker:** no em dashes anywhere in site copy, matching the gate already running in `connect.raschident.com/tools/check-site.mjs`.

---

## 10. Build order

### Phase 1 — a working marketplace, Lahore only
1. `RELCOWHEELS` project, Next.js 15, Tailwind, TypeScript, deploy to Vercel on day one
2. Supabase project, migration `0001_init.sql`, RLS policies on every table
3. Google and Facebook sign-in, profile creation on first login, `intent_url` return
4. `cars` catalogue seeding: makes, models, variants, cities and city areas for Punjab
5. Post-an-ad flow: car details, photos to Supabase Storage, up to 20 images, draft and submit
6. Listing page, search, and the faceted browse pages of section 4
7. Lead capture: masked phone, reveal and message, `leads` rows, WhatsApp delivery to the seller
8. Sold, report and saved-search flows
9. SEO: sitemaps, `robots.ts`, JSON-LD builders, breadcrumbs, canonicals
10. Cookie consent barrier, `/privacy`, `/terms`, `/cookies`, `/safety`
11. A checker script at `RELCOWHEELS/tools/check-site.mjs`, modelled on the existing one: one `h1` per page, titles under 60 characters, descriptions under 160, canonical present, JSON-LD parses and carries the required fields, no em dashes, every internal link resolves, sitemap matches the indexable page set

### Phase 2 — supply before noise
12. Seed 100 to 300 real cars by hand. This is not optional and it is not a coding task.
13. Dealer accounts and `/dealers/{slug}` public profiles
14. Phone OTP via a local SMS gateway, swapped in behind the existing auth screen
15. Email and WhatsApp alerts for saved searches
16. Admin moderation queue

### Phase 3 — turn the leads into invoices
17. Dealer dashboard with lead counts per listing per month
18. Paid tiers: featured placement, dealer subscription, extra photos beyond 20
19. Auction-sheet verification as a paid service, drawing on Maqsood in Japan
20. A price-history page per model, built from our own sold data. Nobody in Pakistan publishes achieved prices, and after a year we will own that dataset.

---

## 11. The risk that decides whether this works

An empty marketplace is worth nothing to a buyer, and a seller will not post into an empty marketplace. This is the actual threat to the project, well ahead of anything technical. PakWheels has 79,270 live listings and 20,000 Suzuki cars alone.

The mitigation has to happen before launch, not after:

- **Lahore only.** A Lahore marketplace with 300 real cars beats a Pakistan-wide one with 300 spread thin.
- **You post the first 200 to 300 cars yourself**, on behalf of dealers along Main Boulevard in Gulberg, with their permission, photographs taken by you and their phone numbers on the ads. Sweat, not cash. You live in Gulberg III, which is where the showrooms are.
- **Start with the dealers you already know.** Zahid Autos is a real business with a real site you built. That is a first dealer account with real stock.
- **Never scrape PakWheels** or any competitor to populate listings. The copy is theirs, the database has rights, and it is against their terms. It would poison the whole project, and the first DMCA notice would end it.

---

## 12. Running costs, honestly

| Item | Cost | Ceiling before it starts charging |
|---|---|---|
| Vercel | 0 | Generous bandwidth on the free plan |
| Supabase | 0 | 500 MB database, 1 GB file storage, 50,000 monthly users |
| Domain | 0 | `wheels.relcoai.com` uses what you already own |
| SMS OTP | paid, per message | Deferred to Phase 2 precisely because of this |
| Total to launch | **0** | |

**The first real ceiling is photo storage, not database rows.** Twenty photos per car at roughly 200 KB each is about 4 MB per listing, so 1 GB holds around 250 cars. That is comfortable for Phase 2 and it is the wall that arrives first, somewhere between 250 and 400 listings. The options then are Supabase's paid tier (USD 25 per month) or image compression and a tighter photo limit (10 images, WebP, 1600px longest edge), which pushes the same 1 GB to roughly 600 cars. The second option is the one to take first, and it should be built in from the start rather than retrofitted.

---

## 13. Other risks

| Risk | Mitigation |
|---|---|
| Advance-payment fraud and fake listings | Sign-in required to post, phone verification before ads go live, a `/safety` page on every listing, report flow, ban policy, and a first-N-listings manual review window |
| Moderation load, one person deep | Auto-publish with post-hoc review and reports, never pre-approval. A pre-approval queue will kill the project in week two |
| Personal data exposure | RLS on every table, no raw phone numbers in any API response, consent wording at the point of reveal, deletion route |
| Competitor response | Do not compete on breadth. Own Lahore, own achieved-price data, own auction-sheet verification through Maqsood |
| Cost creep after the free tiers | Photo compression and caps from day one, alerting on storage usage at 70 percent |
| Legal exposure as a marketplace | Clear terms that we are a venue and not a party to any sale, no escrow, no payments held |

---

## 14. Verification

1. `cd RELCOWHEELS/site && npm run build` passes with no type errors.
2. `node tools/check-site.mjs` reports zero failures across all pages.
3. Every page has exactly one `h1`, a canonical, and a title under 60 characters.
4. Each listing page's JSON-LD parses, and `mileageFromOdometer` is a `QuantitativeValue` with unit `KMT`, not a string.
5. `/auth/*` and `/account/*` return `noindex, nofollow`.
6. Contact sheets for every generated page, listed in `RELCOWHEELS/CONTACT-SHEET.md`.
7. Manual pass, at 360px and 1280px, signed in and signed out:
   - Sign in with Google, then with Facebook, and confirm you land back on the page you started from
   - Post a car with 20 photos, confirm the 21st is refused
   - Reveal a phone number and confirm exactly one `leads` row appears and the seller's WhatsApp receives it
   - Mark a listing sold and confirm it leaves the live index while its page still resolves with a `SOLD` state
   - Submit a report and confirm it lands in the admin queue
   - Set a saved search and confirm the alert fires
8. Verify with JavaScript disabled that the cookie banner still blocks analytics: view source on the home page and confirm no `googletagmanager` or `gtag` script is present before acceptance.
9. Verify RLS by signing in as one dealer and requesting another dealer's listing by ID directly. It must 404, not leak.
10. Confirm no em dash appears in any built output: `grep -r $'\u2014' RELCOWHEELS/site/out RELCOWHEELS/site/src` returns nothing.

---

## 15. Blog and forum, added

### 15.1 Why these belong, rather than being a distraction

Nobody buys a car weekly. That is the structural weakness of every marketplace: visitors arrive, buy once, and never return. Community is the only thing that brings them back between purchases.

PakWheels has run a forum for years, which is why `/forums/` appears in their sitemap and their `robots.txt`. Three concrete returns for us:

1. **Repeat visits without inventory.** A forum works on day one with fifty threads. Listings do not.
2. **Unique indexable text.** Threads and articles rank for the long-tail questions people actually type.
3. **Threads attached to listings** put unique prose on listing pages. No competitor has that, and it is the one forum feature that ties directly into the lead engine.

### 15.2 Two systems with deliberately different rules

Treating a blog and a forum as one feature is the usual mistake. They have opposite economics.

**Blog: editorial. Pre-approved.**

| | |
|---|---|
| Who writes | Few authors. A mix of us and invited guests |
| Volume | Low, maybe 4 to 12 a year |
| Value each | High, it carries our credibility and our domain |
| Approval | **Before publication.** Nothing is public until reviewed |
| SEO | Indexed under our canonical, `BlogPosting` schema, byline credited |

Pre-approval because a published article sits under `wheels.relcoai.com` with our name near it, and a bad one is a lasting liability that a forum post is not. Guest writers keep their byline and we take the canonical. Cross-posting is allowed only if their copy points its canonical at us, otherwise we lose the ranking to their site.

**Forum: conversational. Published, then reviewed.**

| | |
|---|---|
| Who writes | Anyone signed in |
| Volume | The point is for it to be high |
| Value each | Low. Value is in the aggregate |
| Approval | **After publication**, with a first-post hold |
| SEO | `DiscussionForumPosting` schema, `noindex` until a thread has two or more replies |

Post-approval because pre-approving every forum post is precisely what kills a forum: people wait, lose interest, and never come back. But an unmoderated forum is a spam farm within a week, so the compromise is that a member's **first** post is held for review and everything after it publishes immediately. A spammer gets one attempt, a real member is delayed once and never again.

### 15.3 Threads attached to listings

The differentiating feature. Every listing page carries **Ask about this car**, which opens a new thread in the Buying advice category with the listing attached, its title and reference prefilled.

That thread then appears on the listing page as well as in the forum, which means:

- Listing pages gain unique user prose, which is what makes them rank for long-tail queries.
- Buyers ask questions in public, which helps everyone.
- The seller can reply in the thread, so the answer is visible to every later visitor instead of dying in a private message.

### 15.4 Structure

Nested one level only. A thread has posts, and posts have replies. No deeper, because deep threading is unreadable on a phone and impossible to moderate. Question threads support a single accepted answer, which is what makes a forum useful rather than a pile of opinions.

Seeded categories: Buying advice · Selling advice · Inspection and condition · Prices and what things are worth · Ownership and running costs · one per major make · one for Lahore.

### 15.5 New tables

Migration `0002_blog_forum.sql`.

```
articles          id, author_id, slug, title, dek, body_md, body_html, status,
                  cover_path, published_at, reviewed_by, reviewed_at, rejection_reason,
                  view_count, is_guest, guest_name, guest_email, guest_url,
                  license_accepted_at
tags              id, name, slug
article_tags      id, article_id, tag_id

forum_categories  id, name, slug, description, position, is_locked, min_role_to_post
threads           id, category_id, author_id, title, slug, body_md, listing_id,
                  kind (discussion|question), status, is_pinned, is_locked,
                  reply_count, view_count, accepted_post_id, last_reply_at
posts             id, thread_id, author_id, parent_post_id, body_md,
                  status, edited_at, edit_count
reactions         id, post_id, user_id, kind     -- helpful | thanks

user_trust        user_id, thread_count, post_count, accepted_answers,
                  flag_count, first_post_held, banned_until

reports           extended with entity_type, entity_id so it covers listings,
                  articles, threads and posts from one queue
```

Rules enforced in the database:

- `posts.status` moves `visible` to `flagged` to `hidden`, and back only by an admin. A member can edit their own post for **10 minutes**, after which `edit_count` increments and the revision is kept. An edit history is what stops somebody from changing a post after it has been answered.
- `threads.reply_count` and `last_reply_at` are maintained by trigger, never by application code, or they drift and the sorting breaks.
- `user_trust.first_post_held` flips to false on the first admin approval, so the hold applies exactly once per member.
- RLS: public reads published articles and visible threads and posts. Authors read and edit their own. `reports` is insert-by-anyone-signed-in and read-by-admin only. `user_trust` is admin and self only.

### 15.6 Routes added

```
/blog                          index
/blog/{slug}                   one article
/blog/tag/{tag}
/blog/author/{slug}
/write                         submit a draft, signed in
/write/{id}/edit

/forum                         index: categories, latest threads
/forum/{category}
/forum/t/{slug}                one thread
/forum/new                     new thread, optionally ?listing={adid}
/forum/u/{username}            public profile, their threads and articles

/admin/moderation              one queue: pending articles, held posts, open reports
```

### 15.7 Schema added

- `BlogPosting` with `author`, `datePublished`, `dateModified`, `publisher` and `BreadcrumbList` on every article.
- `DiscussionForumPosting` with `author`, `datePublished`, `commentCount` and the accepted answer on every thread, plus `BreadcrumbList`. Google reads this type, and almost nobody in Pakistan uses it.
- `Person` on `/forum/u/{username}` and `/blog/author/{slug}` profiles.
- Threads with fewer than two replies carry `noindex, follow`. This is the crawl-budget rule from the PakWheels study: mass-produced thin pages are what gets a site demoted, and an empty forum generates them faster than anything else.
- `sitemap-blog.xml` and `sitemap-forum.xml`, separate from the listings, added to the index.

### 15.8 Spam, with no budget

No CAPTCHA service, because they are all metered and this has to launch at zero cost. Instead, layered and free:

- Sign-in required to post anything. This alone removes most automated spam.
- Honeypot field on both forms, hidden from people and visible to bots.
- Rate limits: 3 threads and 20 posts per day per member, enforced in the database.
- One link permitted in a member's first post, none in the first post of a brand-new account.
- First post held for review, per 15.2.
- Every post and thread reportable, and the report count surfaces in one queue.

Honest limitation: this will not stop a determined human spammer. At that point the answer is a paid service or captcha, and it is a decision to make when the volume justifies the cost, not before.

### 15.9 Moderation is a setting, not a hard-coded choice

```
RELCOWHEELS/site/src/lib/moderation.ts
  articles:        'pre'      // nothing public until reviewed
  forum:           'post'     // publish, then review
  firstPostHeld:   true
  editWindowMins:  10
  minRepliesToIndex: 2
  maxLinksFirstPost: 0
```

Written this way because the right values will change once there is real traffic, and because changing a constant should not require rewriting the flows around it.
