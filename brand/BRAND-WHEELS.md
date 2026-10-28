# RELCO Wheels, logo and tagline

Built from the parent kit at `~/Documents/apps/relco-digital-brand`. The mark is carried over; the
identity around it is this property's own.

---

## 1. The idea

**The inspection sheet.**

A marketplace should read like documentation rather than like a consumer app. That single decision
produces most of the choices below: a cool grey-white ground rather than warm cream, crisp 2 pixel
corners rather than soft ones, no shadows anywhere, and a mono face for the numbers a buyer is
actually comparing.

The mark itself is not new, and that is deliberate. The R and its **orange node** are the only
elements every RELCO property shares. The node is the family signature: it is the same `#C9541F` in
every property, and it is the one colour that never changes. Everything else here is Wheels.

## 2. What is in the folder

| File | Use |
|---|---|
| `logo/relco-wheels-mark.svg` | The mark alone. Favicon, avatar, small spaces |
| `logo/relco-wheels-mark-roundel.svg` | The mark inside a hairline ring. App icon, social avatar, print crest |
| `logo/relco-wheels-lockup-horizontal.svg` | **Primary.** Headers, signatures, print |
| `logo/relco-wheels-lockup-horizontal-tagline.svg` | With the tagline. Covers, decks, the back of a card |
| `logo/relco-wheels-lockup-stacked.svg` | Square spaces: avatars, panels, print covers |
| `logo/relco-wheels-lockup-horizontal-mono-light.svg` | Single colour for ink grounds, photography, one plate printing |
| `logo/relco-wheels-lockup-horizontal-mono-dark.svg` | Single colour for white paper |
| `png/` | 17 exports, 16px to 1600px, light, ink, white and transparent |
| `preview.html` | Open this first. Every variant inlined, so it shows what the exports contain |

## 3. Type and colour

The wordmark uses this property's own faces, not the parent's, so the logo and the site cannot drift
apart.

- **RELCO** in **Archivo 700 at a width of 118%**. That is the site's display face, and the width
  axis is what gives it the mechanical, expanded feel.
- **WHEELS** in **Public Sans 600**, letterspaced 6.4 units. The descriptor is furniture, not a
  headline, which is why it is small and spaced.

| Role | Colour | Value |
|---|---|---|
| Brand, and the condition result | Verified green | `#0E5C4A` |
| Links and actions only | Action blue | `#1D4ED8` |
| Headings | Cool graphite navy | `#0F1B26` |
| Body text | | `#33414E` |
| Page ground | Cool grey white | `#F4F6F8` |
| Rules and borders | | `#D3DBE2` |
| **The node, in every property** | Burnt orange | `#C9541F` |

**Why green rather than the parent's orange.** On this property colour has a job: green means
verified, and verification is the product. Blue is ring-fenced for links and actions so the two
never compete for the same meaning.

**Why cool rather than warm.** This is a photographic decision before a stylistic one. Warm cream
flatters food and clothing. It dulls silver, grey and white cars, which is most of the Pakistani
market. The cool ground lets car photography read true.

## 4. The tagline

**Know what you're buying.**

Chosen because it is the only line that is both a benefit and unfalsifiable. It describes the
buyer's position rather than promising our perfection, so a single bad listing cannot make it a lie.
And it is precisely what verified listings, inspection results and published sale prices deliver.

Alternatives, with the reason each was not chosen:

| Option | Why not |
|---|---|
| **Every car, inspected.** | Specific, strong, and the one to avoid for now. It promises completeness, and until every listing on the platform is genuinely inspected it is checkably false. Revisit it once it is true, at which point it becomes the better line. |
| **Where Pakistan buys cars.** | Good ambition and honest as a positioning statement. Too large to sit under a logo before there are listings. Hold it as the campaign line. |
| **Verified cars, honest prices.** | Two separate promises, both checkable, both demanding operational perfection from day one. |
| **Buy and sell, properly.** | Echoes the house voice and the M.RAIKOU line, but "properly" carries nothing a buyer can act on. |

Where to use it: under the wordmark on covers, decks and print. **Not in the site header**, where it
would compete with the page. The short form for tight spaces is **Cars, verified.**

## 5. Space and size

- **Clear space:** half the mark's height on all four sides. Nothing enters that band, including
  page edges and other logos.
- **Minimum sizes:** 16px for the mark, 140px wide for the horizontal lockup, 110px wide for the
  stacked lockup. Below those, use the mark alone rather than shrinking the wordmark into
  illegibility.
- **Alignment:** the horizontal lockup aligns on the cap height of RELCO, not on its bounding box.
  Against a rule or a heading, line up the R's top.

## 6. The roundel, and when to use it

`relco-wheels-mark-roundel.svg` puts the same R and the same orange node inside a 1.6 unit hairline
ring. The ring is a wheel rim without drawing a tyre, which is the only nod to the name this
identity allows itself.

It is for the app icon, social avatars, and print where a crest shape helps. **It is not the primary
mark**, because a ring around a letter reads as a badge rather than a signature, and it needs more
room than a 16 pixel favicon has.

## 7. How this is different from the parent kit

| | Parent, Relco Digital | Wheels |
|---|---|---|
| Ground | Warm bone `#F5F1E8` | Cool grey white `#F4F6F8` |
| Accent | Burnt orange `#C9541F` | Verified green `#0E5C4A` |
| Display | Fraunces, a serif | Archivo at 118% width, a grotesk |
| Body | Inter | Public Sans |
| Corners | Soft | Crisp 2px, everywhere |
| Shadows | Permitted | None |
| Descriptor | DIGITAL | WHEELS |

The parent identity is now **corporate only**: proposals, invoices, business cards, letterheads. It
is not a website identity, and no property should wear it. See
`docs/plan-design-identity.md`.

## 8. Do not

- Do not redraw, reweight or recolour the mark to suit a page. If a ground is too dark for the ink
  strokes, use the single colour variant.
- Do not change the node's colour. It is the family signature, and it is the one fixed point across
  every RELCO property.
- Do not stretch, skew or rotate the mark.
- Do not put the two colour lockup on a busy photograph. Use the mono light file.
- Do not add a gradient, a shadow, an outline or a glow.
- Do not set the wordmark in another typeface to save installing Archivo. Export a PNG instead. The
  118% width will not survive a fallback font.
- Do not put the mono dark mark on an ink ground, or the mono light mark on white. The verify script
  fails an export whose ink coverage is too low, which is exactly that mistake.

## 9. Regenerating

```bash
cd ~/Documents/apps/RELCOWHEELS

node brand/tools/build-preview.mjs      # rewrites preview.html with the SVGs inlined
node brand/tools/build-pngs.mjs         # exports png/ from logo/ using headless Chrome
python3 brand/tools/verify-pngs.py      # measures every export: no clipping, nothing blank

python3 -m http.server 8080             # then open http://127.0.0.1:8080/brand/preview.html
```

Chrome is used for export because it is the only rasteriser on this machine and the only one that
renders the variable webfonts, so `png/` matches what the SVG describes. Inlining matters for the
same reason: an externally referenced SVG cannot reach the page's fonts and would silently fall back
to Arial.

## 10. An honest note on how this was verified

The exports cannot be inspected by eye here, so `verify-pngs.py` measures the bounding box of the
artwork and reports the margin on each edge. Two real defects were found and fixed this way during
the build:

- Both horizontal lockups sat about 2 units low in their canvas, and the tagline lockup sat 2.6
  units high. Corrected by adjusting the viewBox, then re-exported and re-measured. The tagline
  lockup now sits at 154/154 top and bottom.
- The mark's own vertical centring is inherited from the parent and is 0.7% low at 1024px, which is
  left alone deliberately: it is optical centring, and matching the parent matters more than
  matching a ruler.

**What only you can check.** Whether the Archivo wordmark at 118% width pleases you next to the
Public Sans descriptor, and whether the roundel or the plain mark reads better as a favicon. Open
`preview.html` and look at the small sizes row first.
