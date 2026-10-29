# Design craft: what we take from the two reference sites

Written after rebuilding the home page, so that the next page does not have to rediscover it.

Two references were studied. **sigmamotors.pk**, a Lahore Japanese-import dealer, for what a Pakistani
car buyer expects to find on a dealer site. **n8n.io**, a workflow automation platform, for how a
modern product page carries a claim. They are useful for different things and they are wrong about
different things.

One correction worth recording before anything else: the brief named `sigmamotors.com`, which is a
parked domain for sale with no content on it. The real site is `sigmamotors.pk`. A session spent
trying to design from the parked domain would have produced nothing.

---

## What the dealer site does well, and what it does badly

Its home page runs a utility bar of phone numbers, a header with a call number and a "Find a Car"
button, a hero, **body-type tiles**, a benefits trio, a phone call-to-action band, testimonials, a
team grid, a client logo wall and a contact-heavy footer, with a WhatsApp button floating over all
of it.

Worth taking:

| Device | Why it works here |
|---|---|
| Phone and WhatsApp in a utility bar | In this market buyers telephone. A marketplace with no number anywhere loses the buyer who is ready to talk. |
| Body-type tiles as the first browse step | "Sedan, SUV, Hatchback" is how somebody who does not know a model name thinks about the market. |
| A closing call to action | Captures the buyer who read the whole page and still has not decided. |
| A contact-heavy footer | Address, numbers, email, and links grouped by intent. |

Not worth taking, and it matters that the difference is visible in their own data. Their **inventory
filters are unmanaged**: the make list contains *Toyata* misspelled beside *Toyota*, *cultus* as a
make, *Swift GLX CVT* as a make, and *Luxury* listed twice as a body type. Twenty one makes including
a Ferrari and a Lamborghini, alongside a duplicate of one already in the list.

RELCO Wheels already holds 22 makes and 117 variants with derived counts and no duplicates. So the
differentiator is not that we have more cars. It is that our filters cannot return a car that does
not exist, and the same car cannot appear twice under two spellings of its own name. That claim is
now made explicitly in the numbers band, because it is checkable against the rest of the site.

## What the product page does well

- **Every claim carries a number.** "Saved 1,000 hours", "£2.2M", "250k+ developers". Not one
  adjective about being powerful or trusted.
- **The hero shows the product**, a workflow diagram, rather than describing it.
- **Section headings are two balanced clauses** joined by a plus sign.
- **Third-party credentials appear as a row**, SOC 2, GDPR, GitHub stars, a G2 score.

The transferable rule, and the single most useful idea taken from either site: **our product is not
cars, it is knowing what you are buying.** So the hero visual is a condition report, built from a
real listing's own score fields.

That choice also solved a problem it was not aiming at. We hold no verified photographs of the cars
in the catalogue, so any car photograph in the hero would be a picture of something else presented as
evidence, which is the exact fault that had a Honda Civic illustrating itself with a Mercedes.

---

## The rules this project now follows

1. **A photograph is evidence, or it is not shown.** On a listing it must depict that car. As a hero
   or an article cover it is illustration, so it must carry an empty `alt` and make no claim.
2. **Every number is derived or declared.** Counts come from listings or from a generated file. If a
   figure describes the catalogue rather than the stock, the sentence around it has to say so.
3. **A count on a tile must equal what clicking returns.** Tiles count listings, never catalogue size,
   because the catalogue holds eight body types and only five have cars listed against them.
4. **No invented experience, customers, reviews or team.** The dealer site's trust devices are mostly
   unverifiable claims. Ours are the 22 makes, the five scored parts, and the sold-price record.
5. **Unknown is not zero.** A condition part that was not scored reads "Not scored", never 0, because
   on a condition report those are different statements.
6. **No dead links.** Six footer links used to 404, because `/cars/lahore` was written as if browsing
   used nested routes when it uses query parameters on one page.
7. **Every link points at an address that resolves.** Check it, do not assume it.

## What we deliberately do not copy

- Their three competing phone numbers in three places. Ours is one number, in one bar, plus a float.
- Their round WhatsApp button. This identity is crisp 2px and never uses a circle, so ours is squared.
- Their round decade count. We have no decade, so the numbers band carries catalogue facts instead.
- Their testimonial and team blocks, which we cannot fill with anything true yet.

## Identity constraints that survive any redesign

Enforced by `tools/check-site.mjs` and the portfolio gate, so breaking one fails the build rather than
producing a bad page:

- The brand hex `#0E5C4A`, Archivo, Public Sans and IBM Plex Mono are portfolio-unique. Two RELCO
  properties may not share a display face, a body face or a brand hex at all.
- The orange node `#C9541F` in the mark is the one element shared across every property. Do not
  change it and do not remove it.
- Exactly one `h1` per page. Every new section heading is `h2` or below.
- No em dashes and no en dashes anywhere under `site/src`, including CSS and Markdown comments.
- No shadows. This identity reads as documentation, not as a consumer app.
- `data-display` and `data-surface="ink"` are load-bearing attribute hooks, not decoration.

## Before shipping a page

1. `npm run build` then `npm run check:site`, for one `h1` per page and the six other checks.
2. `node ../tools/check-identity.mjs`, for portfolio collisions.
3. Load it on the production server, not just the build, because the browse page is server rendered
   and never appears as a file.
4. Click every link you added.
5. Read every number and ask where it comes from. If the answer is "I wrote it", derive it instead.
