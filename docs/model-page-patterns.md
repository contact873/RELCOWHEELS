# Model page patterns, from suzukipakistan.com

Studied 2026-10-31, as a reference for the vehicle pages on RELCO Wheels. What follows is a
description of patterns, not a copy of their design: their site is a manufacturer brochure, ours is a
marketplace, and their layout serves a different job.

## What their site actually is

| Observed | Detail |
|---|---|
| Framework | Next.js, App Router, with a catch-all route `app/(frontend)/[...slug]/page.tsx` |
| Content | CMS-driven. Media served from `/api/media/file/...`, the Payload CMS media route |
| Styling | Bootstrap 5 grid (`container-fluid`, `col-xl-8`, `d-flex`), plus custom CSS. Not Tailwind |
| Motion | AOS scroll animations (`data-aos="fade-right"`), Swiper carousels, React Bootstrap tabs |
| Hero | A `<video autoplay loop muted playsinline>` with a `.webm`, no poster image |
| Weight | Eight separate stylesheets, and roughly 50 KB of inline SVG for one gauge illustration |
| Built by | Convex Interactive Pvt. Ltd., per the `author` meta tag |

## Six patterns worth taking

**1. The variant comparison table with ticks per column.** The best thing on their site. Rows are
features, columns are variants, cells are a tick, and it answers the only question a buyer of a new
Alto actually has, which is what the VXL adds over the VXR. **This maps directly onto our schema:**
`variants` holds the trim, `features` holds the equipment keys, `listing_features` holds what a
particular car has. We can render this for any model, from our own data.

**2. Colour gallery with swatches.** A row of colour chips, each swapping the photograph. Persuasive
and cheap. For a marketplace the honest version is different, because a real car has one colour and
that colour is a fact about the listing rather than a configurator choice. The useful transfer is the
**swatch as a filter**: show the colour as a chip on the card, and let it filter.

**3. Price with a monthly figure underneath.** `PKR 2,994,861` and `as low as PKR 49,095/month`. A
marketplace can do this honestly only if the arithmetic is shown and the assumptions (deposit, tenure,
markup) are stated on the page. A monthly number with no assumptions is a marketing figure.

**4. Spec tables grouped by category**, not one long list: Safety, Comfort, Instrument Panel. That
matches the three-cluster decision already made for our listing pages, and it is why our spec table
does not put a hairline on every row.

**5. A brochure download as the lead magnet.** Their "Download Brochure" is a PDF behind a click. For
us the equivalent is a **condition sheet download** on a listing, which is a genuinely better lead
magnet because it is specific to the car and nobody else publishes it.

**6. Two CTAs, ranked.** "Explore" primary, "Book Now" secondary, on every product. Ours already has
primary and ghost buttons; the pattern worth keeping is that a secondary action is never the same
weight as the primary.

## Five things not to copy

**1. Their empty states are visibly broken.** The "Our Journey" figures render as **0** for outlets,
dealership cities, vehicles sold and years in operation. The four "Certified Used Car" boxes render
"Loading..." and "No cars available in this region". A visitor sees four zeros and three loading
skeletons. Whatever else this site does well, **it demonstrates the cost of shipping placeholder states
to production**, which is the exact thing our sample banner and placeholder panels exist to avoid.

**2. The video hero has no poster.** On a slow Pakistani mobile connection that is a blank rectangle
until the video starts. We use no background video anywhere, deliberately.

**3. Eight stylesheets and a 50 KB inline SVG gauge.** Their homepage ships CSS in eight requests and
one decorative illustration larger than our entire component budget. We have one stylesheet, a token
contract, and a build gate that fails on a second source of colour truth.

**4. Bootstrap grid classes with no design system behind them.** Class soup is not a design system, and
it is why three of their sections look like three different sites. Our tokens and the identity registry
are the opposite approach and should stay.

**5. Their photographs.** See below.

## The photographs are not ours to take

The exterior and interior photography on suzukipakistan.com belongs to Pak Suzuki Motor Company and to
the agency that produced the site. It is product photography for a manufacturer's own marketing.
Republishing it on a commercial classifieds site is not fair use, and the fact that a page is publicly
readable is not a licence.

There is a second reason that has nothing to do with law. **A listing photograph is evidence about the
specific car for sale.** A manufacturer's studio shot of a new Alto, placed on a listing for a 2019
used Alto, is the Mercedes-on-the-Civic fault committed deliberately. It would also put a
manufacturer's promotional image next to a seller's asking price, which is the fastest way to get a
complaint from the manufacturer.

**What is legitimately usable from their material, and from the spec sheet:**

| Usable | Why |
|---|---|
| Dimensional and mechanical specifications | Facts about a product: length, wheelbase, engine code, displacement, torque, tyre size. Facts are not protected expression |
| Variant names and the structure of the range | The Alto is sold as VXR, VXR-AGS and VXL-AGS. That is a fact about the product range |
| Public list prices, if dated and sourced | A price is a fact on a date. Record the date and the source, or do not record it |

**What is not usable:** the photographs, the brochure PDF, their descriptive copy, and their spec table
as a layout. Facts may be re-expressed in our own schema, which is what a catalogue is for. Their table
arrangement and wording are theirs.

## Concrete corrections this study produced

Our catalogue currently lists the Alto as **VXR, VXL, VXL AGS**. The published range on
suzukipakistan.com is:

| Variant | List price | Transmission |
|---|---|---|
| Alto VXR | PKR 2,994,861 | 5MT |
| Alto VXR-AGS | PKR 3,166,480 | AGS |
| Alto VXL-AGS | PKR 3,326,446 | AGS |

So our catalogue is **missing VXR-AGS** and carries a **VXL that is not in the current range**. Any
listing that names a variant should use the published name, or a buyer searching for "VXR AGS" will not
find the car. Prices are recorded with a date, or not at all.

## The one pattern to build next

**The variant comparison table, from our own data.** It is the highest-value thing their site does, it
needs no photography, and we already hold every fact it needs. A model page that answers "what does the
VXL add" is worth more than any hero image.
