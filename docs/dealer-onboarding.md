# Onboarding a real dealer

**Read this before adding any stock that is not your own.**

---

## Why this document exists

The fastest way to fill an empty marketplace is to copy listings from somewhere that already has
them. It is also the fastest way to end the project.

PakWheels' Terms of Service, effective 1 January 2021, state three things that matter here:

1. Accessing their site "through automated means including robot, deep link, page scrape" is
   prohibited.
2. They claim ownership of "the design, text, graphics, ads, user uploaded pictures, vehicle
   description, vehicle inspection reports" and the selection and arrangement of it.
3. A breach makes you liable for their costs "including reasonable legal fees", and disputes are
   heard in the courts of Lahore.

So the rule for this project is simple:

> **Stock enters RELCO Wheels only from the person who owns the car, or from a dealer who has
> authorised us in writing to list their stock.**

That is not a formality. It is the difference between a business and a lawsuit.

## What is perfectly fine

- Browsing PakWheels to understand what the market is asking. That is just reading.
- Noticing that a dealer has stock and **calling that dealer** to invite them onto RELCO Wheels.
  Their showroom address and phone number are their own business information.
- A dealer handing you their own stock list, in a file, with permission.
- Photographing a dealer's cars yourself, standing in their showroom, with their permission.
- Importing a feed that a dealer provides and stands behind.

## What is not

- Copying listing text, photographs or inspection reports from any other site.
- Hotlinking another site's photographs.
- Automated collection from any site whose terms prohibit it.
- Importing a dealer's file that is itself copied from another marketplace. The dealer must warrant
  that the content is theirs. If it is not, the liability lands on us, not on them.

---

## The four steps

### 1. Approach

Walk in. You are in Gulberg III with showrooms along Main Boulevard and Johar Town twenty minutes
away. Do not send an email first.

What to say, in one breath: **"I am building a car site for Lahore. Listing is free. What I need is
permission to photograph your cars and put them up, and I will send every enquiry straight to your
WhatsApp. If it brings you nothing, it has cost you nothing."**

The three things that make a dealer say yes:

- It is free, and there is no listing fee and no commission.
- The enquiries come to them **directly**, on WhatsApp, not through a portal they have to check.
- They keep their own phone number on the ad. We do not hide it behind a gate and resell it back to
  them, which is what they are used to.

### 2. Authorise

Get it in writing, even if it is a WhatsApp message. Record it in `dealer_authorisations`. The
minimum content:

- Who the dealer is, and their NTN or CNIC
- That they authorise RELCO Wheels to publish their stock, photographs and descriptions
- That they confirm the content is theirs to publish
- That they will tell us when a car is sold
- A date, and a name against it

One message, kept, beats a contract nobody signs.

### 3. Photograph

Use the phone. Four angles plus the interior, in daylight, with the car clean. Do not crop to a
fixed ratio: the photographs go on the listing at their own proportions so a buyer can see the
whole car.

Twenty photographs per listing maximum, enforced by the database. That is a storage ceiling, not a
style choice, and it is what keeps the free tier free.

### 4. Import

Either the dealer types their stock in through `/sell`, or they hand you a file and you import it:

```bash
cd ~/Documents/apps/RELCOWHEELS

# 1. Give them this template to fill
open templates/dealer-stock-template.csv

# 2. Check the file without writing anything
node tools/import-dealer-stock.mjs stock/zahid-autos.csv --dealer zahid_autos --dry-run

# 3. If it is clean, produce the SQL and run it in Supabase
node tools/import-dealer-stock.mjs stock/zahid-autos.csv --dealer zahid_autos --out stock/zahid-autos.sql
```

The importer refuses the whole file if any row fails, rather than importing the good rows and
silently dropping the bad ones. A half imported stock list is worse than none, because nobody
notices the missing cars.

---

## Who to approach first

| Dealer | Where | Why them |
|---|---|---|
| **Zahid Autos** | Existing relationship | Already a client. You built their site. They will say yes. |
| **Ibrar Hussain** | Existing relationship | Already named as a partner |
| **Sigma Motors** | 22 Khyaban-e-Jinnah, opposite UCP, Johar Town. sigmamotors.pk | Japanese car exporter with auction sourcing. Two possible conversations in one visit. |
| **Zulfiqar Motors** | 871-C, Faisal Town, Main Maulana Shaukat Ali Road | Listed in business directories as a Japanese used car exporter. Verify in person. |
| ~~Car Fort~~ | ~~Maulana Shaukat Ali Road, Akbar Chowk, Faisal Town~~ | **Deferred on request.** Not to be approached for now. |
| **Main Boulevard showrooms** | Gulberg III, walking distance from 31/FF | Do them ten at a time, on foot |

Two notes on the visits.

**Sigma Motors and Zulfiqar Motors are both in the Japanese import trade, which is Maqsood's trade.**
So there are two conversations available: a dealer account on RELCO Wheels, and a sourcing or trading
relationship with M.RAIKOU. Do not lead with the second. Get the listing permission, prove that the
enquiries arrive, and the trading conversation follows on its own.

**Zulfiqar Motors Pakistan is a directory listing, not a confirmed fact.** Faisal Town address, listed
as a Japanese used car exporter. Confirm the address and the contact in person before putting them in
a plan, and if "Zulfiqar Motors Japan" is a separate Japan-side entity, ask which one holds title to
the cars.

## Dealers whose stock only exists on Facebook

Car Fort is not alone in this. A large number of small Lahore dealers have a Facebook page and no
website, so it is tempting to read their page and lift the inventory.

**You cannot do it by scraping.** Meta's platform terms prohibit automated collection from Facebook
products without permission, and Meta enforces that far harder than any classifieds site in
Pakistan: it detects the traffic, and it bans the account. The account at risk would be yours, and
it would be the one tied to your real identity.

**There is a compliant version, and it is worth understanding even if we do not use it yet.** If the
dealer owns their Page, they can grant your app access to it through Facebook Login for Business.
You then read their posts through the Graph API using their Page access token. That is authorised
access, not collection. Two things it requires:

- A Facebook developer app, and App Review for the Page permissions, because you are reading pages
  you do not administer. That is a process measured in weeks.
- A Page access token per dealer, stored server side. Never in the browser.

**Why it is usually not worth it for a small dealer.** Three reasons:

1. **The captions are not listings.** A Facebook post is written to catch the eye, not to record a
   model year, mileage and asking price. Every imported post has to be enriched by hand anyway, so
   the integration saves less time than it looks like it will.
2. **The photographs have to be downloaded and re-hosted.** Facebook image URLs are signed and
   expire, so hotlinking is not an option. Storing them requires the right to store them, which is
   the same authorisation question as everywhere else in this document.
3. **For a page with 122 followers, walking over with a phone is faster.** You will also get better
   photographs than whatever they posted: four angles, the interior, the odometer, the engine bay.
   That is an afternoon for one dealer.

**The rule that follows:** use the Graph API only for a dealer with real volume who refuses to fill
in a spreadsheet. For everyone else, photograph it yourself. And in every case, the written
authorisation must name the photographs explicitly, whether they came from a showroom floor, a CSV
file, or the dealer's own Facebook page.

## The opening this actually suggests

Three of these four relationships are in the **Japanese import** trade. That is not a coincidence, it
is a position, and it is a much better one than a general marketplace.

PakWheels covers Japanese imports as one facet among dozens, and sells an auction sheet verification
service. Nobody in Pakistan runs a marketplace where the Japanese import is the *subject* rather than
a filter. And it happens to be exactly what this identity was built for: the inspection sheet, the
verified green, the auction sheet badge, the condition score out of ten.

So the sharper plan is:

- **Own the Japanese import segment first.** Ten to thirty importers and a few hundred real imported
  cars, with the auction sheet attached and the grade shown.
- **Then widen to general used cars** once the segment is credible and the leads are proving out.
- The general market is where PakWheels is unbeatable. The import segment is where they are merely
  present.

If you would rather go general from the start, say so and I will adjust. But the network you already
have points one way.

## The preview page, for step 1

There is a page per dealership at `/dealers/<slug>`, built to be sent to them rather than found by
them. It carries their name, their city, what a dealership gets, and their stock if we hold it.

The pages are listed at **`/dealers`**. Reach it by typing the address: it is not linked from
anywhere on the site and it is not in the sitemap, because while any of these carries a real
company's name it is a sales document rather than a page of the marketplace.

Adding one is a single entry in `site/src/lib/prospects.ts`. Three rules govern that file, and they
are the same rules as everywhere else in this project:

| Field | Rule |
|---|---|
| `phone`, `whatsapp` | Empty unless **they** gave us the number. Their number being on their own site is not permission to put it on ours, because that routes their callers somewhere they did not choose. |
| `addressLines` | Their published address is fine. Cited in `notes` so it is clear where it came from. |
| `stockCount` | `null` until somebody counts. A guess here is a number we would have to defend. |

**A page stays out of search until `status` is `"live"` and `authorisedOn` holds a date.** That is
enforced in `isIndexable()` rather than left to discipline, and it renders a loud banner at the top
of anything that is not authorised. The failure this prevents is specific and expensive: a dealer
finding their own name on our site, in Google, before we have spoken to them.

**The empty state is the honest state.** A prospect page with no authorised stock says so and shows
the four steps above, rather than filling the space with plausible-looking cars. Inventing stock for
a real business is the Mercedes-on-the-Honda mistake at the scale of a whole company.

Once they authorise, the sequence is: set `authorisedOn` and `status: "live"`, fill `handle` so the
page can find their listings, and import. The banner disappears on its own, because it renders
nothing for an authorised dealership.

## Target

Two hundred to three hundred real Lahore cars before the site is shown to anybody. That is roughly
fifteen dealers at twenty cars each, or ten afternoons of photography.

An empty marketplace is worth nothing to a buyer, and a seller will not list into an empty
marketplace. This is the part of the project that decides whether it works, and it is fieldwork
rather than code.
