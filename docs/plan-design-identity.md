# Per-property design identity: one portfolio, no lookalikes

**Supersedes section 9 of `RELCOWHEELS-marketplace.md`.** That section reused the parent tokens (Ink `#0C1014`, Bone `#F5F1E8`, Fraunces + Inter), which would have made RELCO Wheels a fourth copy of the same skin.

---

## 1. What actually went wrong

Measured from the token files, not remembered:

| Property | Ink | Paper | Accent | Display | Body |
|---|---|---|---|---|---|
| `relco-digital-brand` | `#0C1014` | `#F5F1E8` | `#C9541F` | Fraunces | Inter |
| `connect.raschident.com` | `#0c1014` | `#f5f1e8` | `#c9541f` | Fraunces | Inter |
| `universal-business-os` | `#0c1014` | `#f5f1e8` | `#c9541f` | Fraunces | Inter |
| `Zahid Autos` | `#0d1113` | `#f5f6f4` | `#0e7490` | Space Grotesk | Inter |
| `website-demo/relco-mfr-demo` | `#0d1113` | `#f7f8f6` | `#0e7490` | Space Grotesk | Inter |

Three properties are **byte-identical**. Zahid Autos and one of the demo themes are the same theme twice. Inter is the body face on essentially everything.

But the hex collisions are the smaller half of it. The deeper problem is that every property follows the *same recipe*:

> near-black ink → warm off-white paper → exactly one saturated accent → one display face → Inter body → soft corner radius → card-and-shadow layout

Changing the accent hex does not make a different website. It makes the same website in a different colour. That is the thing to fix.

## 2. The strategy

**Endorsed brand architecture with one immutable element.**

- **Immutable:** the RELCO mark, and specifically the **orange node** at the end of the R's leg. That orange node appears in every property's logo, unchanged, at `#C9541F`. It is the only colour shared across the portfolio, and it is the entire family signature.
- **Variable:** palette, typefaces, shape language, density, structure, and the logic of how accents are used. All of it differs per property.
- **Corporate use:** `relco-digital-brand` keeps Ink/Bone/Burnt orange with Fraunces + Inter, but stops being a website identity. It is for company-level things only: proposals, invoices, business cards, letterheads, the brand kit itself.

The wordmark commits to the property's own display face, exactly as the parent kit already does with Fraunces. So recognition comes from the mark and the orange node, not from a shared typeface.

**"Same product line" exception.** `universal-business-os` and `connect.raschident.com` are one product line, confirmed. They keep matching each other. What changes is that the pair stops wearing the corporate tokens verbatim and gets an identity of its own, so the collision below the corporate level is resolved rather than created.

## 3. The six axes, and the rule

Every property declares a fingerprint on six axes:

| Axis | Values |
|---|---|
| **Ground** | warm · cool · neutral · none (pure white or pure black) |
| **Value key** | light-dominant · dark-dominant · split |
| **Display face** | editorial serif · transitional serif · grotesk · expanded grotesk · condensed · geometric · humanist · monospace-led · decorative |
| **Body face** | must differ from every other property's body face |
| **Shape** | sharp 0px · crisp 2px · soft 8-10px · round 14px+ · pill · asymmetric |
| **Structure** | editorial rules · product cards · dense data table · airy editorial · brutalist offset |

**The rule:** no two properties may share more than **three** of the six axes, and no two may share a display face, a body face, or a brand hex at all. Four properties may all be light-dominant; only one may pair established-grotesk with a green-on-cool-white ground.

**Semantic colours are exempt.** `--warn`, `--danger`, `--sold` may repeat across properties, because they mean the same thing everywhere and confusing them would be worse.

## 4. The token contract

Adopted from Astra's nine-slot model, which is production-tested and forces each property to declare a complete, coherent palette instead of an ad-hoc set:

```
--brand        primary accent, buttons and links
--brand-alt    hover and variants
--heading      all heading text
--text         body text
--bg           page background
--bg-alt       alternating sections
--border       borders, dividers, rules
--bg-subtle    cards, inputs, quiet areas
--extra        one supporting colour

--price  --warn  --danger  --sold     functional, exempt from the rule
```

## 5. The registry

New file: `~/Documents/apps/DESIGN-IDENTITY.md`

It holds three things: the six axes explained, the **claim table** (every property's fingerprint, exact hex values, and the file paths that carry them), and the **unclaimed pool** so the next new site starts from what is left rather than from the brand kit.

Every project declares its own fingerprint in a machine-readable `identity.json` at its root:

```json
{
  "property": "RELCO Wheels",
  "domain": "wheels.relcoai.com",
  "axes": { "ground": "cool", "key": "light", "display": "expanded-grotesk",
            "body": "public-sans", "shape": "crisp-2px", "structure": "dense-data" },
  "tokens": { "brand": "#0E5C4A", "heading": "#0F1B26", "bg": "#F4F6F8", "...": "..." },
  "type": { "display": "Archivo Expanded", "body": "Public Sans", "data": "IBM Plex Mono" }
}
```

## 6. The checker

New file: `~/Documents/apps/tools/check-identity.mjs`

Reads every `identity.json` under `apps/` and fails when:

1. Two properties declare the same `brand` hex.
2. Two properties declare the same display face or body face.
3. Two properties match on more than three of the six axes.
4. A token file on disk disagrees with the declared `identity.json`. This is the one that matters months from now, when somebody edits a stylesheet by hand and the registry silently goes stale.

Same shape as the gates already running in `connect.raschident.com/tools/check-site.mjs`. Run it before any new property ships.

## 7. RELCO Wheels: the identity

**Concept: "the inspection sheet."** A marketplace should read like documentation. Precise, cool, data-forward. Not warm, not editorial. Warm cream flatters photographs of nothing in particular and actively dulls silver, grey and white cars, which is most of the market.

| Axis | Value |
|---|---|
| Ground | **cool** |
| Value key | light-dominant |
| Display | **expanded grotesk** |
| Body | **Public Sans** |
| Data | **IBM Plex Mono** |
| Shape | **crisp 2px** |
| Structure | **dense data table** |

```
--brand       #0E5C4A   verified green
--brand-alt   #128168
--heading     #0F1B26   cool graphite-navy
--text        #33414E
--bg          #F4F6F8   cool grey-white
--bg-alt      #FFFFFF
--border      #D3DBE2
--bg-subtle   #E8EDF1
--extra       #1D4ED8   action blue, links

--price       #0E5C4A
--sold        #64748B
--warn        #A16207
--danger      #B3261E
```

**Why these.** Green carries verification, which is the marketplace's actual product, and it is unused anywhere else in the portfolio. Blue is reserved strictly for links and actions so the two never compete. The cool grey-white ground is a photographic decision before a stylistic one: it makes car photography read true.

Type: **Archivo Expanded** for display (mechanical, confident, wide enough to hold a headline), **Public Sans** for body (a neutral government-grade humanist that is not Inter), **IBM Plex Mono** for prices, mileage, engine capacity and ad reference numbers.

## 8. Connect and Business OS: the identity

The pair keeps matching each other, and stops matching the corporate kit.

| Axis | Value |
|---|---|
| Ground | **cool** |
| Value key | **dark-dominant** |
| Display | **geometric** |
| Body | **Instrument Sans** |
| Data | **JetBrains Mono** |
| Shape | **soft 10px** |
| Structure | **product cards** |

```
--bg          #0B1220   deep navy-black, cool. Not #0c1014, which is warm-neutral
--bg-alt      #121C2E
--heading     #E8EEF5
--text        #A9B7C6
--brand       #2E7DF6   product blue
--brand-alt   #5B9BFF
--extra       #22D3A6   the answer teal, echoing the relay-node idea
--border      #1E2A3D
--bg-subtle   #16202F
```

Sora or Schibsted Grotesk for display, Instrument Sans for body. Dark-first because it is a software product, and because it is the clearest single move that separates it from both the corporate kit and RELCO Wheels.

## 9. Retrofit list

| Property | Action | Carries |
|---|---|---|
| `relco-digital-brand` | **No visual change.** Re-scope as corporate-only in `BRAND.md` | logo, png, preview |
| `connect.raschident.com` | Re-skin to the dark product identity in section 8 | `DEPLOY/assets/css/styles.css`, all pages, `ja/` |
| `universal-business-os` | Same identity, applied together | `src/app/globals.css` |
| `RELCOWHEELS` | Build with the identity in section 7 | new project |
| `autoparts.raschident.com` | **No change.** Already distinct | — |
| `Zahid Autos` | Separate from the mfr demo theme so they stop being the same site | `css/styles.css` |
| `website-demo/*` | Treat the three demos as one product and one theming system. Confirm the three differ from each other, which they do | `tools/theme/*.css` |
| `Maqsood Japan` + `maqsood-cars` | **No change.** One brand, correctly shared across its own pages | — |

Registration is added for every property, including the unchanged ones, so the checker has a complete picture.

## 10. RELCO Wheels: the logo and tagline

Built on the existing mark, following the parent kit's construction exactly. The R and its orange node are carried over unchanged, because that node is the family signature.

New files under `RELCOWHEELS/brand/`:

```
RELCOWHEELS-mark.svg                      the shared R mark, unchanged
RELCOWHEELS-mark-roundel.svg              the R inside a hairline ring: wheels-specific alternate
RELCOWHEELS-lockup-horizontal.svg         primary
RELCOWHEELS-lockup-horizontal-tagline.svg with the tagline
RELCOWHEELS-lockup-stacked.svg            square spaces, avatars, panels
RELCOWHEELS-lockup-horizontal-mono-light.svg
RELCOWHEELS-lockup-horizontal-mono-dark.svg
BRAND-WHEELS.md
preview.html
png/                                       16px to 1600px, via the existing Chrome exporter
tools/build-pngs.mjs  tools/build-preview.mjs   adapted from relco-digital-brand
```

**Wordmark:** `RELCO` in Archivo Expanded 700, `WHEELS` in Public Sans 600 letterspaced, matching the parent pattern of a prominent name and a small spaced descriptor.

**Classic treatment.** Three devices make it read as established rather than startup:

1. A **hairline rule** beneath the wordmark, spanning the R's top to the end of `WHEELS`.
2. `EST. 2026` in small letterspaced caps, sitting on that rule, right-aligned.
3. The tagline beneath, in Public Sans 500 at 1.6 letterspacing.

The roundel alternate (`RELCOWHEELS-mark-roundel.svg`) puts the R inside a thin ring, which reads as a wheel rim without drawing a literal tyre. Reserved for the app icon and for print where a crest shape helps.

**Tagline: "Know what you're buying."**

Chosen because it is the one line that is both a benefit and unfalsifiable. It describes the buyer's position rather than promising our perfection, so a single bad listing cannot make it a lie, and it is precisely what verified listings, inspection data and real prices deliver.

Alternatives, with why each was not chosen:

| Option | Why not |
|---|---|
| **Every car, inspected.** | Specific and strong, and the one to avoid for now. It promises completeness, and until every listing on the platform is genuinely inspected it is checkably false. Revisit it once it is true, at which point it becomes the better tagline. |
| **Where Pakistan buys cars.** | Good ambition, and honest as a positioning line. Too big to sit under a logo before there are listings; hold it as the campaign line. |
| **Verified cars, honest prices.** | Two separate promises, both checkable, both requiring operational perfection from day one. |
| **Buy and sell, properly.** | Echoes the house voice and the M.RAIKOU line, but "properly" carries no information a buyer can act on. |

For tight spaces where four words is too many, the short form is **"Cars, verified."**

## 11. The unclaimed pool

Recorded in the registry so the next property starts from what is left. Drawn from the research: Colorlib's 30 documented schemes with hex values, Visme's 50 award-winning directions, Astra's nine-slot slot model, and the WordPress default themes.

**Display faces not yet claimed:** Playfair Display, Libre Baskerville, Bodoni Moda, Instrument Serif, Syne, Outfit, Manrope, Figtree, Familjen Grotesk, Chivo, Epilogue, Anton, Archivo Narrow, Roboto Condensed, Oswald, Newsreader, Redaction.

**Body faces not yet claimed:** Manrope, Figtree, Karla, Work Sans, Rubik, Nunito Sans, IBM Plex Sans, Inter Tight, Geist, Schibsted Grotesk, Atkinson Hyperlegible.

**Ground-plus-accent combinations not yet claimed**, with hex taken from the sources:

| Direction | Ground | Accent | Source |
|---|---|---|---|
| Mineral luxury | `#0d0d0d` | `#a78444` | Colorlib, Sierra Hull |
| Botanical calm | `#f6f2e5` | `#113023` | Colorlib, Koysor Abdul |
| Editorial medical | `#ffffff` | `#18246f` | Colorlib, S Kaba Consulting |
| Warm industrial | `#f4f0ed` | `#eaaa64` | Colorlib, Katie Lemon |
| Vintage terracotta | `#241a14` | `#c2673a` | Visme, Deep Vintage Mood |
| Cool metallic | `#0f1720` | `#4a93c7` | relcoai sky, unused on web |
| Plum and lime | `#171321` | `#b9f24d` | Visme, Innovative and Audacious |

Two practical rules extracted from the sources and worth keeping: three colours is the working maximum for one identity, and one of them must be an accent used sparingly. Both are already how the parent kit behaves.

## 12. Build order

1. `DESIGN-IDENTITY.md` written with the axes, the claim table and the pool.
2. `identity.json` added to every existing property, capturing what it *currently* is, collisions and all. This makes the problem visible before it is fixed.
3. `tools/check-identity.mjs` written and run. It should fail on the first pass, reporting the connect/business-os/brand triplet and the Zahid/mfr pair. A checker that passes on day one has proved nothing.
4. RELCO Wheels brand files built, exported and verified. Preview first, because the small sizes are what matters.
5. RELCO Wheels application built on the section 7 tokens.
6. Connect and Business OS re-skinned to section 8, together, so they stay in step.
7. Zahid Autos separated from the mfr demo theme.
8. `BRAND.md` in `relco-digital-brand` re-scoped to corporate-only, with a note pointing every property at its own identity.
9. Checker re-run: zero failures. That is the signal the portfolio is genuinely differentiated.

## 13. Verification

1. `node ~/Documents/apps/tools/check-identity.mjs` reports zero failures.
2. No two `identity.json` files share a `brand` hex, a display face or a body face.
3. Every property's on-disk tokens match its declared `identity.json`.
4. RELCO Wheels: `node tools/build-pngs.mjs` writes all exports, then `python3 tools/verify-pngs.py` reports no clipping and no blank output.
5. Open `RELCOWHEELS/brand/preview.html` and check the 16px and 24px rows first, then the horizontal and stacked lockups, then the on-ink variant.
6. Side-by-side test, which is the real one: open `connect.raschident.com`, `universal-business-os` and the RELCO Wheels home page in three browser tabs. If they read as the same website in three colours, the work has failed, whatever the checker says.
7. Confirm the orange node is present and identical in every property's mark.
8. Confirm no em dash appears in any built output, per the standing house rule.
