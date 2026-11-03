# RELCO Wheels — halted, and how to pick it up

**Halted:** 31 October 2026, at the user's instruction. Nothing was left half-finished: the working
tree is clean, local `main` equals `origin/main`, and no dev server was left running.

| | |
|---|---|
| **Live** | https://relcowheels.vercel.app — no custom domain, so this URL is the site |
| **Repo** | `github-relcowheels:contact873/RELCOWHEELS`, branch `main` |
| **Commit at halt** | `aa96091` (see `git log` for anything after) |
| **Production database** | Supabase `ecjyqamcegxbnpidrfqb` |
| **Staging database** | Supabase `vrgjqwppdeoyhjgmkaca` (see `supabase/projects.json`) |

---

## What exists and works

- **70 prerendered pages**, `npm run build` clean, `npm run check:site` at **8 checks, 0 failures**.
- **Database harness** in `tools/dbcheck/`: **416 statements, 44 behaviour tests**, all passing.
  It switches role with `set role anon`, so RLS is actually exercised rather than assumed.
- **Catalogue**: 22 makes, 71 models, 117 variants, generated from `data/catalogue.json` by
  `tools/seed-catalogue.mjs` into `data/catalogue.sql`.
- **Migrations** `0001_init` … `0006_signup` in `supabase/migrations/`.
- **Design**: blue `#1B4AD4`, amber `#A84807`, off-white ground `#fafaf8`, Sora + Figtree. Chosen
  because no other RELCO property uses blue — see `docs/plans/per-property-design-identity.md`.

## Deliberately not switched on

The site reads **sample data** (`site/src/lib/queries.ts`), and `NEXT_PUBLIC_DATA_SOURCE=sample`
keeps three things in their safe state:

- the **"Sample content"** banner on every page, from `src/components/sample-notice.tsx`
- `robots.txt` → `Disallow: /`
- `sitemap.xml` → 0 URLs

**These are correct and must not be "tidied".** `src/lib/data-source.ts` explains at length why the
gate is a deliberate switch rather than an inference about whether a database exists.

---

## Open items, in the order they block things

### 1. Staging needs `data/catalogue.sql` run — 2 minutes
Production is **done and verified**: the Alto carries exactly `VXR`, `VXR-AGS`, `VXL-AGS`, and the
total is still 117 variants, which proves the prune removed the phantom `VXL` and added `VXR-AGS`.

Staging has not been re-run since the variant correction. Paste `data/catalogue.sql` into
`https://supabase.com/dashboard/project/vrgjqwppdeoyhjgmkaca/sql/new`. It is idempotent.

### 2. Three photographs — blocked on data only the user has
`site/public/cars/` holds exactly three files. All three are **unidentified to the model level in the
code** except as recorded in `seed.ts`, and **none can be used yet**:

| File | Shows | Why it is unused |
|---|---|---|
| `13-1.jpg` | BMW 3 Series | No BMW is listed |
| `11-2.jpg` | Mazda MX-5 | No Mazda is listed |
| `10-3.jpg` | Mercedes Benz C Class | The only Mercedes listed is an **E Class** |

To publish any of them, three things are needed: **year**, **price**, and **provenance**. The price
is not invented — a made-up price on a live page is a number a buyer could act on. Provenance matters
because if these were downloaded rather than shot or licensed, they cannot go up at all.

### 3. Contact details — `site/src/lib/contact.ts` is empty
The utility bar and the WhatsApp button are built and render **nothing** until a real phone or email
exists. This is the last thing on the site deliberately hiding itself.

### 4. The domain
`relcowheel.com` is not purchased. The registry says `wheels.relcoai.com` (does not resolve), the
canonical points at `relcowheels.vercel.app`, and conversation says `relcowheel.com`. Nothing is
decided. It gates email, the canonical URL, and getting off `*.vercel.app`.

### 5. Going live, when real cars exist — two steps, not one
1. Point `src/lib/queries.ts` at Supabase.
2. Set `NEXT_PUBLIC_DATA_SOURCE=database` in `.env.local` **and in Vercel**.

Doing only the second makes the site claim to be live while showing invented cars, and the banner,
robots rule and sitemap will all flip while the data has not.

### 6. Approved but not started
`image-pipeline --ingest` — writes precise prompts for the user to paste into free ChatGPT, then
records provenance for whatever comes back. Plan: `docs/plans/logo-and-image-skills.md`.
The `--live` half waits on a paid key.

### 7. Smaller, awaiting the user's word
- **Confirm `0006_signup.sql` has been run on both projects.** It creates the trigger that gives every
  new signup a `profiles` and `user_identities` row, and it was written after the last staging
  migration run, so its application is unverified either way.
- Add the `node` to `relcoai/identity.json` and `connect.raschident.com/identity.json` so those two
  kits get the family orange mark.
- `npm audit` was taken to 0 with an `overrides` pin on `postcss`; drop it when Next ships a fix.

### 8. Later, deliberately unbuilt
Saved-search alerts, forum reply notifications, account mail, dealer CSV intake. Specified in
`docs/email.md`. **WhatsApp-direct leads were chosen over a portal**, which is why Resend Inboxes was
rejected.

---

## How to work on it again

```bash
cd ~/Documents/apps/RELCOWHEELS

# the three checks that matter, in order
npm --prefix tools/dbcheck run check     # 416 statements, 44 tests
npm --prefix site run build              # 70 pages
npm --prefix site run check:site         # 8 gate checks

# run the site locally
cd site && NEXT_PUBLIC_DATA_SOURCE=sample npm run dev
```

Environment for a build: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`,
`NEXT_PUBLIC_DATA_SOURCE=sample`, `NEXT_PUBLIC_SITE_URL`.

**Sweep `localhost`, never the deployment.** A polling loop against Vercel trips a bot checkpoint
that returns 403 for about five minutes. `docs/design-craft.md` has the postmortem.

---

## Rules that must survive this project

1. **Never invent** prices, statistics, view counts, search volumes, contact numbers or photographs.
   Two claims were removed for breaching this: a `userInteractionCount` in structured data, and a
   "four to eleven percent" figure in an article.
2. **A listing photograph is evidence; a hero or article cover is illustration.** Evidence must depict
   that car or it is not shown. This is the defect that started all of it — a Honda Civic displaying a
   Mercedes.
3. **No scraping or republishing third-party images.** Pak Suzuki's photographs were offered and
   declined.
4. **Every property keeps its own design identity** — no shared brand hex, display face or body face.
5. **Dealer leads go to WhatsApp**, not a portal. Buyer phone numbers stay in `private.leads`.
6. **`queries.ts` stays on sample data** until real cars exist. Switching now empties `/cars`, which
   is worse than a sample.
7. **Verify by measurement, not assertion.** Contrast computed to AA, the served stylesheet read
   rather than the source, `cmd whoami` rather than `cmd status`.

## Corrections made during this project, worth not repeating

- The harness once **encoded a bug as a requirement** (`is_admin` execute revoked from `anon` while
  policies called it), which is why it now allowlists exactly `is_admin()` and switches role.
- A prune test asserted by `slug` alone; `slug` is unique **per model**, so `vxl` matched the phantom
  and Cultus's real variant. It made a working prune look broken for three runs.
- The sample-content banner was **incorrectly reported as missing** after grepping three page files and
  missing `layout.tsx`. One `curl` would have settled it before the claim, not after.
