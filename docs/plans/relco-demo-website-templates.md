
# Per-niche demo website templates (website-demo/)

Related: `~/.commandcode/plans/partner-referral-program-and-japan-site.md` (Part B/C). These demos are the
"show a prospect their own niche" asset that Part B's pitch leans on.

## Outcome

A `website-demo/` folder holding ready-to-show, self-contained demo websites, one per niche, each
populated with sample content and pictures like a WordPress theme demo. A prospect in a trade sees a
site built for that trade, with placeholder figures and imagery, and can be walked through it on a phone
with no network.

Three demos, named as asked:

| Demo | Niche | Archetype |
|---|---|---|
| `relco-mfr-demo` | Manufacturer / supplier | Industrial, enquiry-first (no cart) |
| `relcotrade-demo` | Exporter / trading | B2B catalogue plus enquiry |
| `relco-ecom-demo` | Ecommerce | Shop with products, prices, cart or quote |

Build order: `relco-mfr-demo` first (it is also the Japanese proof), then `relcotrade-demo`, then
`relco-ecom-demo`.

## Decisions taken

- **Static, generator-built, no framework.** Follows the M.RAIKOU pattern (`tools/build.py` writes a
  linked-asset `DEPLOY/` plus a single self-contained HTML file). It already produces a demo that opens
  offline on a phone, which is exactly what a theme demo needs.
- **Branding: subtle.** Each demo is named with its `relco-*` slug and carries a small "Sample design
  prepared by Relco Digital" line in the footer. It is clearly ours, not passed off as a real client.
- **Languages: English for all, plus a Japanese version of `relco-mfr-demo`** (reusing the M.RAIKOU
  `hreflang` and JP font-stack approach) to prove the Japan-market pattern.
- **Themes are adopted, not invented.** Reuse the corpus design systems that are ours or approved for
  reuse, rather than writing new CSS.

## Folder layout

```
~/Documents/apps/website-demo/
  README.md                     what this is, how to add a niche, the rights note
  index.html                    the hub: links to the three demos
  tools/
    shell.py                    head(), header(), footer(), sample banner, single-file export
    theme/
      base.css                  shared reset, container, buttons, motion, sample banner
      mfr.css                   tokens + components, adopted from zahid-autos
      trade.css                 tokens + components, trade/export accent
      ecom.css                  tokens + components, adopted from autostore
    build-mfr.py                content + sections -> relco-mfr-demo/
    build-trade.py              -> relcotrade-demo/
    build-ecom.py               -> relco-ecom-demo/
    build-index.py              -> index.html (the hub)
  assets/
    fonts/                      self-hosted OFL woff2 (Space Grotesk, Inter, Bebas Neue, DM Sans, JetBrains Mono)
    img/                        sample imagery: allowed corpus media + generated SVG plates
  relco-mfr-demo/
    DEPLOY/                     index.html, ja.html, range.html, about.html, contact.html, assets/
    demo/relco-mfr-demo.html    single self-contained file (images and fonts inlined)
  relcotrade-demo/              DEPLOY/ + demo/
  relco-ecom-demo/              DEPLOY/ + demo/
```

## The three demos

Each is a small multi-page site (four to six pages) in the archetype's structure, with one visible
sample-content marker.

**`relco-mfr-demo`** (manufacturer / supplier, theme `mfr.css` from zahid-autos: graphite, filtration
teal, JetBrains Mono for part numbers):
- hero with one claim and "request a quote"; product range by category; capability and specification
  table; quality and approvals; about the facility; enquiry form (category, part numbers, quantity,
  buyer type).
- Bilingual: `index.html` (EN) and `ja.html` (JA), with the `en/ja/x-default` hreflang pair.

**`relcotrade-demo`** (exporter / trading, theme `trade.css`):
- hero; markets and sectors served; a sample catalogue table (stock, product, spec, availability);
  export process; logistics and documentation; enquiry form. Enquiry-first, no cart.

**`relco-ecom-demo`** (ecommerce, theme `ecom.css` from autostore: one red hue in three steps, red
confined to price and action):
- hero; category tiles; a product grid with sample prices and a cart or quote button; a trust strip;
  delivery and returns; contact. Cart interaction is a demo only (no payment, no server).

## Placeholder content and imagery (the important part)

- **Every figure on the page is visibly sample.** The `relco-online-shop` project already has a
  `SampleBanner` pattern; reuse it as a fixed ribbon, plus a small "sample" tag on figures and images.
  Nothing on a demo may look like a real claim about us or the prospect.
- **Sample business names, not real ones.** Use invented names (for example "Northline Industrial",
  "Pacific Rim Trading", "Summit Supply") and placeholder identifiers (`MFR-0001`, lot codes, sample
  SKUs). Never a real client's name or numbers.
- **Imagery rights.** Reuse only what is ours or approved: `_corpus/media/autostore/` (53 images, our
  build), `_corpus/media/zahid-autos/` (9 plates, already placeholders), and generated SVG plates (the
  autoparts project's drawn-outline approach). **Do not reuse** `media/sora-kuro` or
  `media/autohousesupply` (third-party brand assets). `media/theflowerstudio` is ours with a caveat;
  use sparingly. Where no picture fits, use a labelled gradient block rather than a wrong photo.
- **Fonts offline.** Self-host the OFL fonts as woff2 in `assets/fonts/`, inlined in the single-file
  demo, so it renders correctly with no network and no Google Fonts request.

## Generator design

- `tools/shell.py` holds the reusable shell (document head with SEO/canonical/hreflang, header, footer,
  the sample banner, and the `write_demo()` that inlines CSS, fonts and images into one file). This is
  the one place the three demos share, so a header change lands in all three.
- Each `build-*.py` carries its own content (a Python dict of copy and sample data) and its sections,
  because the three archetypes have different structures. No cross-demo content coupling.
- `base.css` provides the shared spine; each `theme/*.css` supplies tokens and the archetype's
  components. Inherited from the corpus systems rather than written fresh.
- The hub `index.html` lists the three demos as cards with a one-line niche description.

## Hosting and sharing

- Each demo opens from disk (the `demo/` single file for a phone; the `DEPLOY/` folder for a browser).
- To share a link, host the set as subfolders on one origin (for example
  `demo.<domain>/relco-mfr-demo/`), or as separate Cloudflare Pages projects. This ties into Part C's
  Cloudflare Pages plan; the domain is a later decision, not a blocker.
- Any share link can carry `?ref=` so a demo sent by a partner is credited in the ledgers already built.

## Files to create

- `~/Documents/apps/website-demo/README.md`, `index.html`
- `~/Documents/apps/website-demo/tools/{shell.py, build-mfr.py, build-trade.py, build-ecom.py, build-index.py}`
- `~/Documents/apps/website-demo/tools/theme/{base.css, mfr.css, trade.css, ecom.css}`
- `~/Documents/apps/website-demo/assets/{fonts/, img/}`
- `~/Documents/apps/website-demo/relco-mfr-demo/{DEPLOY/, demo/}`
- `~/Documents/apps/website-demo/relcotrade-demo/{DEPLOY/, demo/}`
- `~/Documents/apps/website-demo/relco-ecom-demo/{DEPLOY/, demo/}`

## Reuse (with rights)

| Need | Use | Rights |
|---|---|---|
| Manufacturer/trade design system | `~/Documents/apps/SKILLS/_corpus/themes/zahid-autos/styles.css` | Ours |
| Ecommerce design system | `~/Documents/apps/SKILLS/_corpus/themes/autostore/starter.css` | Ours, approved |
| General marketing layout + JS | `~/Documents/apps/SKILLS/marketing-site-rebuild/assets/{starter.css, interactions.js}` | Approved |
| Multi-brand components | `~/Documents/apps/SKILLS/multi-brand-store/assets/starter.css` | Approved |
| Sample imagery | `_corpus/media/autostore/` (53), `_corpus/media/zahid-autos/` (9 plates) | Ours |
| Sample-content banner | `~/Documents/apps/relco-online-shop/` `SampleBanner` | Ours |
| Demo + bilingual pattern | `~/Documents/apps/Maqsood Japan/tools/build*.py` | Ours |
| Niches and structure | `_corpus/catalog/0{1..5}-*/README.md` | Reference |
| Imagery NOT to reuse | `_corpus/media/{sora-kuro,autohousesupply}/` | Third party |

## Verification

1. `cd ~/Documents/apps/website-demo && python3 tools/build-mfr.py && python3 tools/build-trade.py && python3 tools/build-ecom.py && python3 tools/build-index.py`.
2. Each `demo/*.html` opens from disk with the network off and looks correct (fonts and images are
   inlined, no Google Fonts request).
3. Every demo shows the sample-content banner, and every figure/photo is tagged as sample.
4. Nitpick pass per demo: one `<h1>`; every local link resolves; no third-party image is present
   (grep the `img/` for provenance); the JA page has `lang="ja"`, the JP font stack and the hreflang pair.
5. `index.html` links to all three demos and each resolves.
6. A shared-shell change (for example the footer credit) appears in all three demos after one rebuild.

## Open decisions

1. **Hosting origin** for the demos (subfolders on one host vs separate Cloudflare Pages projects) - ties
   to the Part C domain decision; not a blocker to building them.
2. **Whether to embed images as base64** in the single-file demo or rely on CSS-only placeholders for
   size. Embedded is truer to "pictures included", at a few hundred KB per demo.
3. **Adding more niches later** (local service, multi-brand retail) once these three are shown around.
