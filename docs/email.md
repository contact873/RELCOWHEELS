# Email: what it is for, and why none of it is built yet

Status: **decided, not built.** Resend is the intended provider. Nothing is wired up, and this note
exists so the decision and its reasons survive.

The prompt for writing this was Resend's Inboxes announcement on 22 October 2026. The conclusion was
that it is the wrong half of the product to adopt first, and that the right half is not needed until
there is mail worth sending.

## There is no email in this project at all

No dependency, no code, no address. Verified rather than assumed: no `resend`, `nodemailer`,
`sendgrid`, `postmark`, `mailgun` or `smtp` anywhere in `site/src`, `tools`, `supabase` or the
manifests.

But the schema was written expecting a notifier that was never built:

| Where | What it already assumes |
|---|---|
| `saved_searches.frequency` | `instant`, `daily` or `weekly`, plus `last_sent_at` |
| `saved_searches.filters` | The stored query, as jsonb |
| `follows` | `entity_type` of `make`, `model`, `seller`, `thread` or `city` |
| `profiles.notify_on_reply` | A preference that currently does nothing |
| `profiles.notify_on_lead` | The same |
| `profiles.email_verified_at` | Email was always intended as a real channel |
| `leads.forwarded_at`, `leads.forward_channel` | When and how we told the seller, never written |
| `leads.outcome` | `new`, `contacted`, `sold`, `lost`, `invalid` |

There is a comment in `0001_init.sql` above `follows` that says the table exists "so the notification
worker has one query". That worker is the thing email is actually for.

Note that `profiles.email` moved to `private.profile_contacts` in migration `0003`. A notifier has to
read from the private schema, through the service role, which is correct and worth remembering.

## Leads do not go by email

`docs/dealer-onboarding.md` already decided that dealer enquiries arrive **directly on WhatsApp, not
through a portal they have to check**. It also says to get authorisation in writing even if that
writing is a WhatsApp message.

So email is not the lead transport, and a shared inbox is not a portal to route leads into. Adopting
one would quietly reverse a decision that was made deliberately, for the reason that a dealer who has
to check a second place will not check it.

## Where email does belong, in order

1. **Saved-search alerts.** "Tell me when a Corolla 2018 appears in Lahore." Batched, not urgent, and
   exactly the shape of mail. `saved_searches` and `follows` exist for it.
2. **Forum reply notifications.** `notify_on_reply` exists and does nothing.
3. **Account and moderation mail.** Listing approved, listing rejected, listing expired, sign-in.
4. **Dealer stock intake.** A dealer emails a CSV rather than filling in a spreadsheet and sending it
   by WhatsApp. `tools/import-dealer-stock.mjs` already exists to receive one.

## The caveat that matters more than the tooling

Buyer phone numbers live in `private.leads` on purpose, out of the API's reach, because a harvestable
list of buyers who are actively shopping is the most valuable and most abusable asset this business
will hold. That decision cost real work in migration `0003`.

**Resend Inboxes with its agent layer would send that data to a third party and an LLM that can draft
replies.** That is a reversal of posture, not an increment on it. If inboxes are ever adopted, the
agent must not be given access to lead records, and the enquiry text must be treated as containing
personal data.

## What has to happen first

A domain with DNS the owner controls. Inboxes, and Resend generally, sends and receives at an address
on a domain you own, which means SPF, DKIM and DMARC records.

The site currently runs at `relcowheels.vercel.app`, which is not a domain anybody controls. The
intended domain in `identity.json` is `wheels.relcoai.com`, which does not resolve. **Settling the
domain is therefore a prerequisite for email, and it is also a prerequisite for a real canonical URL
and for Vercel to stop serving a `*.vercel.app` address.** One decision, three problems.

## If it is adopted later

- Use Resend for **sending only** to begin with. Transactional mail from the notifier above.
- Keep it out of the lead path. Leads go to the dealer on WhatsApp.
- Create the first address as something ordinary, `hello@` or `support@`, not `leads@`. An address
  that invites lead data is an address that will collect personal data that then has to be managed.
- The free tier covers 3 inboxes, which is more than this business needs, and $1 per inbox beyond
  that. Cost is not the reason to defer; the absence of anything to send is.

## Revisit when

The first real dealer stock is loaded. At that point listing approval mail, saved-search alerts and
reply notifications all become worth building, in that order, and the notifier the schema anticipates
can finally be written.
