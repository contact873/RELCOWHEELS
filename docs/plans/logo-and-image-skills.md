# Logos and images: what can be built now, and what needs a key

Answering: is it possible to develop skills that create logos and images, and what is needed to
generate AI images for websites and campaigns.

**The short answer splits in two.** Logos you can already produce, and producing them with an AI image
model would make them worse. Photographic AI imagery you cannot produce at all until one provider key
exists, and no skill changes that.

---

## 1. What already exists, checked rather than assumed

| Thing | State | Evidence |
|---|---|---|
| A working logo pipeline | **exists** | `RELCOWHEELS/brand/tools/build-pngs.mjs`, `verify-pngs.py`, `build-preview.mjs`. Seven SVGs to seventeen measured PNGs |
| A real compositing tool | **exists and can run** | `social-cards/scripts/card_kit.py` uses PIL, and Pillow is present in four Python 3.12 virtualenvs under `ws-10-agents` |
| `imagegen-frontend-web` | **prompt only** | Its body instructs a model to generate one image per section. Nothing runs here |
| `brandkit` | **prompt only** | Its body instructs a model to generate brand boards. Nothing runs here |
| Any image-generation API key | **none** | No `OPENAI_API_KEY`, `REPLICATE`, `FAL_KEY`, `IDEASTABILITY`, `GEMINI_API_KEY` or `IMAGEN` anywhere in `~/Documents/apps` |
| Raster tooling | **headless Chrome only** | `rsvg-convert`, ImageMagick and cairosvg are absent. The existing pipeline uses Chrome, and its own header comment says why |

So the library has two skills that assume a capability the machine does not have, and one that does not
need it. That is the same pattern as `orchestrate`: instructions written for an environment that is not
this one.

---

## 2. Why logos must not be AI-generated

This is a technical claim, not a taste one.

An image model outputs a **raster rectangle of pixels**. A logo needs to be a **vector** because it goes
on a business card, a shopfront, a 16px favicon and a billboard, and each needs clean edges and a file
somebody can edit. A raster logo is unusable at every size except the one it was generated at.

Three more reasons, all observed:

- **Type is mangled.** Every general image model still produces near-letters. A wordmark needs exact
  letterspacing and a real typeface.
- **Geometry is inconsistent.** Ask for the same mark twice and you get two different curves, so there
  is no system, only a picture.
- **Nothing is a file you own.** You cannot change the weight, strip a background, produce a mono
  version, or fix a kerning pair.

What already works, and is the right answer: **draw the logo in SVG, then rasterise it.** The existing
pipeline does exactly that, and it solved the two hard parts:

- **Fonts.** It inlines each SVG into a page that loads the real webfonts, because an externally
  referenced SVG cannot reach the host page's fonts and silently falls back to Arial, which is not the
  logo.
- **Verification.** `verify-pngs.py` measures every export, because geometry that overflows its canvas
  looks correct in code and wrong on a wall, and these files cannot be inspected by eye.

That is a professional logo pipeline. It has no AI in it and should not have.

## 3. Why photographic imagery does need a provider

There is no image model on this machine and no key to one. Nothing I write can change that: the skill
would be a wrapper around an HTTP call that authorises itself with a key you own.

So the honest requirement list is short:

1. **An account and an API key** with one provider.
2. **A thin adapter** so the skill is not welded to one vendor.
3. **An asset manifest** recording model, prompt, date and licence for every file, because a client
   will ask and a platform may require disclosure.
4. **A budget ceiling**, because image generation is per-call spend.

### Which provider, and why

| Provider | Strength | Weakness | Fits |
|---|---|---|---|
| **FLUX via fal.ai or Replicate** | Best quality per unit cost, one HTTP call, no SDK | Writes garbage text | **Recommended** for photographic and illustrative imagery |
| OpenAI `gpt-image-1` | Follows instructions most reliably, better at text | Needs organisation verification, costs more | Good if you already pay OpenAI |
| Ideogram | Best legible text in image | Weaker photographic realism | Ad creatives that must contain words |
| Google Imagen | Fine quality, natural if you already run Google Cloud | Less convenient API than fal | Only if the Google account already exists |

**Recommendation: FLUX via fal.ai for imagery, and PIL for every piece of text.** That deliberately
avoids the weakest area of every model. Text in an AI image is a liability: it is often subtly wrong,
and a wrong word in a client's ad is worse than no word. `social-cards` already composites text with
PIL, which renders your real fonts exactly.

**Do not trust a price quoted from memory.** Per-image rates move. Read the provider's current pricing
page before the first run and record it in the manifest.

---

## 4. The two skills worth building

Both in the house style: `SKILL.md` with matching directory, `scripts/` with `--selftest`, no dashes, no
invented numbers.

## 4.1 `logo-system`

**Job.** Turn a written identity into a complete, measured logo kit: the mark, the lockups, the mono
variants, the favicon sizes, and a provable check that each export fits its canvas.

**Why.** The RELCO Wheels kit took real work and produced a reusable method. Right now the method lives
in one project's `brand/tools/`, so the next property starts from nothing and will drift.

**Interface.**

```bash
node scripts/build.mjs <identity.json> [--out ./brand] [--sizes 16,32,64,128,512,1024] [--dry]
node scripts/verify.mjs <./brand>          # measures every raster against its canvas
node scripts/build.mjs --selftest
```

Reads the identity registry for colours and typefaces, so a kit cannot contradict the tokens. Emits SVG
first, then raster only where a raster is required.

**Rules.**

- **SVG is the deliverable.** PNG is an export, never the source.
- Colours and faces come from `identity.json`, cited. Never typed in twice.
- Every raster is measured: content must sit inside the canvas with the designed margin, and the check
  fails the build rather than warning.
- The family nod (the shared element across properties) is read from the registry, not hardcoded.
- Chrome renders, because it is the only thing present that resolves webfonts. If no Chrome, the SVG
  files are still complete and the script says so and exits without pretending it exported anything.

**Tests.** A fixture identity produces a kit; every emitted SVG parses; the mono variant contains no
non-mono colour; a deliberately overflowing SVG fails `verify`; a 16px favicon is legible by the
minimum-stroke check; running twice produces byte-identical output.

**Needs from you.** Nothing. It codifies a pipeline that already works.

## 4.2 `image-pipeline`

**Job.** One command from a written brief to a placed, optimised, provenance-recorded image, against
whichever provider is configured, and a dry mode that produces the prompts without spending anything.

**Why.** The two prompt-only skills in the library already know how to art-direct. Nothing turns that
into files with a licence attached, and without that the output is unusable for client work.

**Interface.**

```bash
node scripts/generate.mjs --brief <file.md> --count 4 --aspect 16:9 [--provider fal] [--dry]
node scripts/place.mjs <generated.json> --into <project> --as hero
node scripts/generate.mjs --selftest
```

- `--dry` writes the prompts, the negative prompts and the expected cost estimate shape, and calls
  nothing. **This is the default**, matching `sync.mjs`.
- `--provider` selects an adapter. fal first, Replicate second, OpenAI third. One interface:
  `{ generate(prompt, opts) -> { bytes, modelVersion } }`.
- Writes every asset beside a manifest row: file, provider, model version, prompt, seed, date, aspect,
  byte size, and **licence and permitted use**.

**Rules.**

- **Dry by default.** A live call needs `--live`, so an accidental run costs nothing.
- **A manifest or it did not happen.** An image without a provenance row is not written to the project.
- **Never overwrite.** Content-addressed filenames, so regenerating cannot destroy a chosen asset.
- **The brief decides the format.** It must state the intended use, because a 16:9 hero and a 1:1 card
  are different renders.
- **Cost is checked before the batch, not after.** Refuse a batch over a stated ceiling.

**Tests.** A stubbed provider records a manifest row with every required field; `--dry` makes zero calls
(asserted by a provider stub that throws if called); a missing key exits 2 with the variable named; a
duplicate generate does not overwrite; a batch over the ceiling is refused; an image generated for a use
that the rules forbid is refused.

**Needs from you.** One provider account and its key, stored with `read -rsp` so it never enters a chat.

---

## 5. What must never be generated, by any skill

These are the rules already enforced inside `social-cards`, and they extend to anything with a model
behind it.

| Never generate | Because |
|---|---|
| A listing photograph of a car | It must be the actual car. A generated car on a listing is the Mercedes-on-the-Civic fault turned into a policy |
| A person's face, or a testimonial | Invented people are fraud, and a generated face cannot consent |
| A screenshot, or a product UI | It will be subtly wrong and then quoted back at you |
| A client's logo | Section 2. Draw it |
| Text inside an image, where the text matters | Composite it with PIL so your real fonts are used and the words are yours |

Where AI imagery is legitimate: atmospheric backgrounds, textures, illustration, abstract brand
imagery, and moodboards that are explicitly labelled as such. Not evidence of anything.

---

## 6. Order, and the one decision

1. **`logo-system` first**, because it needs nothing from you and its method is already proven. Building
   it also retires the gap that `brandkit` pretends to fill.
2. **`image-pipeline` with `--dry` only**, so the briefs and the manifest shape exist before a key does.
3. **Connect a provider when you have decided which**, and run one live batch of four images as a
   calibration, not a campaign.

The decision that unblocks it all is one line: **which provider account you open first.** Everything
else in this plan is buildable today.

## 7. The uncomfortable part

`imagegen-frontend-web` and `brandkit` will keep appearing to be image skills. They are prompt libraries,
and a session that invokes them expecting files will produce prose about images and no images. That is
worth fixing by marking them in the registry as requiring a generator, or by pointing them at
`image-pipeline` once it exists, so nobody mistakes instructions for capability again.
