# RELCO Wheels: home page in the Sigma Motors composition

## What this is

A rebuild of the RELCO Wheels home page so that its **structure and conversion devices** match what a
Pakistani car buyer expects from a dealer site, executed at a higher level of craft than the reference
achieves, inside RELCO Wheels' existing identity.

It is not a restyle and it is not a copy.

## Correction on the brief

`sigmamotors.com` is a parked domain for sale. There is no site there. The real reference is
**sigmamotors.pk**, a Lahore Japanese-import dealer, and that is what this plan works from. Noted
because the same mistake would waste the next session too.

## What I take from each reference

### From sigmamotors.pk: architecture and conversion

Their home page runs: utility bar with phones -> header with a call number and a "Find a Car" button ->
hero -> **body-type tiles** -> new/used band -> **three benefits with icons** -> long trust copy -> a
phone CTA band -> testimonials -> **team grid** -> client logo wall -> **contact-heavy footer**, plus a
WhatsApp float.

What is worth taking:

| Device | Why |
|---|---|
| Utility bar carrying phone, WhatsApp, email | In this market buyers call. RELCO Wheels currently publishes no phone number anywhere, which is the single biggest conversion gap on the site. |
| Body-type tiles as the first browse step | "Sedan, SUV, Hatchback, Van" is how a non-expert buyer thinks. It is faster to scan than a make list. |
| Benefits trio | Three short reasons, above the listings. |
| CTA band before the footer | Captures the buyer who has scrolled the whole page. |
| Contact-heavy footer | Address, numbers, email, socials, by-brand links. |

Their **inventory page** gives the second lesson: nine filters, nine cars per page, sort, compare. And
it gives us the differentiator, because their filter data is unmanaged. Their make list contains
**"Toyata" misspelled beside "Toyota", "cultus" as a make, "Swift GLX CVT" as a make, and "Luxury"
appearing twice as a body type.** RELCO Wheels already has 22 clean makes, 71 models and 117 variants
with derived counts. Clean taxonomy is a claim we can actually make and they cannot.

### From n8n.io: craft

- Every benefit carries a **number** ("saved 1,000 hours", "£2.2M", "250k+ developers"), not an adjective.
- The hero **shows the product** rather than describing it. Their product visual is a workflow diagram.
- Section headlines are two balanced lines with a deliberate **plus** or second clause ("Built by you + readable by anyone").
- Consistent 3-up feature cards, each a headline plus one line.
- A credentials row of third-party proof (SOC 2, GDPR, GitHub stars, G2 score).

The transferable rule for us: **our product is not cars, it is the condition report and the price
record.** So the hero visual should be a condition sheet, not a car photograph. That is both stronger
and it sidesteps the photography problem entirely, since we have no verified car photographs.

## What must not change

Non-negotiable, each enforced by a gate. A breakdown here fails the build.

| Constraint | Enforced by |
|---|---|
| Brand hex `#0E5C4A` and the three faces (Archivo, Public Sans, IBM Plex Mono) stay | `tools/check-identity.mjs` rules 1 and 2. Changing them risks colliding with another RELCO property. |
| The orange node `#C9541F` in the mark is fixed | `brand/BRAND-WHEELS.md`. The header renders it as a literal. |
| Exactly one `h1` per page | `tools/check-site.mjs`, reads built HTML. Every new section heading must be `h2`/`h3`. |
| No em dashes or en dashes anywhere under `site/src` | `tools/check-site.mjs`. Includes CSS and Markdown comments. |
| `data-display` and `data-surface="ink"` stay | They carry token resolution, not decoration. |
| Every `dangerouslySetInnerHTML` starts with `renderBody(`, `plainText(` or `JSON.stringify(` | `tools/check-site.mjs`. |
| A listing photograph must depict that car | Established last commit. A hero is illustration; a listing photo is evidence. |

## Honesty constraints

The reference leans on claims RELCO Wheels cannot make. Per your decision, the sections stay and the
content is true.

**Cannot appear:** years of experience, customer testimonials, team members, client logos, cars sold,
registered users, "thousands of buyers".

**Can appear, because it is checkable:** 22 makes, 71 models, 117 variants, 18 cities. Price history
kept after the sale. The condition score broken into five measured parts. Clean, deduplicated filters.

**One integrity bug found while planning.** `seed.ts` article 2 states: *"the gap between the final
asking price and the price actually agreed ran between four and eleven percent."* That is an invented
statistic presented as a finding from real sales, and there have been no sales. It has been sitting in
published content. Fix it in this pass by rewriting the claim as what it is, guidance rather than
measurement.

## The new home page, in order

Replaces the current seven sections. Net effect: five new sections, four kept, two tightened.

| # | Section | Status | Notes |
|---|---|---|---|
| 1 | Utility bar | **new** | Location, phone, WhatsApp, email. Hidden entirely while contact details are unset, so nothing false ships. |
| 2 | Header | **change** | Add a WhatsApp/call button beside "Post an ad". Mark and node untouched. |
| 3 | Hero | **rewrite** | Same promise, but the visual becomes a **condition-report panel** built from existing components and real score fields, with the sold-price record beside it. Add a make quick-pick row under the search box. Still exactly one `h1`. |
| 4 | Body-type tiles | **new** | Five tiles from the catalogue (Hatchback, Sedan, SUV, Van, Crossover) with counts derived from data, mirroring the reference's "select car types". |
| 5 | The numbers band | **new** | Four checkable facts. This is the section that replaces their "20 years of experience". |
| 6 | Latest listings | **change** | Cap at 5 rows with "See all 26". Today all 26 render, which makes the page enormous. |
| 7 | Browse by make, city, budget | **keep**, tightened | Three columns stay, hairlines stay. |
| 8 | How a listing gets its numbers | **keep** | The ink band and the four numbered steps. Strongest section on the page, leave it alone. |
| 9 | The sold record | **keep** | The one number a competitor does not publish. |
| 10 | Forum and guides | **keep** | Two columns. |
| 11 | Forum categories | **keep** | Plain index. |
| 12 | CTA band | **new** | "Tell us what you want and we will find it" with a call/WhatsApp route. Their phone band, done without three competing numbers. |
| 13 | Footer | **change** | Add a Contact column (address, phone, WhatsApp, email) and a by-body-type link column. |
| 14 | WhatsApp float | **new** | Fixed lower right, mirrors the reference. Hidden while the number is unset. |

One `h1` remains, in the hero. Everything new is `h2` or below.

## Files to change

| File | Change |
|---|---|
| `site/src/lib/contact.ts` | **new.** One place for phone, WhatsApp, email, address. Empty strings by default. |
| `site/src/components/contact-bar.tsx` | **new.** The utility bar. Renders `null` when `contact.ts` is empty. |
| `site/src/components/whatsapp-float.tsx` | **new.** Same gating. |
| `site/src/components/condition-panel.tsx` | **new.** The hero visual: score breakdown from `listing.inspection`, using `.spec-row` and `.data` which already exist and are currently unused. |
| `site/src/components/body-type-tiles.tsx` | **new.** Tiles with derived counts. |
| `site/src/components/stat-band.tsx` | **new.** The four checkable facts. |
| `site/src/app/page.tsx` | Recompose the thirteen sections. |
| `site/src/lib/queries.ts` | Add `countByBody()`, alongside the existing `countByMake`/`countByCity`. |
| `site/src/components/site-header.tsx` | Add the call button. Do not touch `Mark` or `fill="#C9541F"`. |
| `site/src/components/site-footer.tsx` | Add Contact and by-body-type columns. |
| `site/src/lib/seed.ts` | Fix the invented statistic in article 2. |
| `site/src/app/globals.css` | Only if a tile or band needs a class. Reuse `.card`, `.badge`, `.spec-row` where possible rather than adding. |
| `identity.json` | Fix the drift: it declares `bg-alt: #FFFFFF`, the stylesheet uses `#fcfdfe`. Align the registry to the stylesheet. |
| `docs/design-craft.md` | **new.** The principles taken from the two references, and how each maps to our pages. This is the durable answer to "develop your skill in design". |

No new brand colour, no new font, no change to the token names.

## Verification

1. `cd site && npm run build` then `npm run check:site` for all seven checks, including one h1 per page.
2. `cd tools/dbcheck && npm run check` for the 336 statements and 36 tests, unchanged.
3. Run the production server and confirm on `/`: the contact bar is hidden while details are unset, body-type counts equal the browse page counts, no listing shows an unconfirmed photograph, and the mobile width does not overflow.
4. Confirm `node ../tools/check-identity.mjs` still reports no collisions.
5. Confirm the hero renders with no car photograph, so the photograph rule from the last commit holds.

## What I need from you

**One thing: the contact details.** Phone, WhatsApp number and email, plus the address you want shown.
They go in `site/src/lib/contact.ts`. I will not invent them, so until they are set the utility bar,
the WhatsApp float and the footer contact column stay hidden. Everything else is unaffected.

## Separate, and not part of this plan

You asked to install the Command Code CLI. The command is `cmd`, not `cmdc`:

```bash
npm i -g command-code
cmd login
cmd
```

If `cmd` is not found afterwards, `npm config get prefix` gives the prefix and `<prefix>/bin` needs to
be on your `PATH`. I cannot run this in plan mode, since installing a global package changes the
machine. Say the word once we are out of plan mode and I will run it and check the version.
