# Six skills, specified to build

Revised from the A-to-Z map. The map's conclusion stands (the chain is built and unwired), so this
document does the only useful next thing: **specify the six missing skills well enough to build here**,
rather than to go and find.

Each specification is written to be handed to an implementer as-is: job, why now, interface, rules,
what it must never do, the tests that define done, and what it needs from you.

## House rules that apply to all six

From `PLAYBOOK.md` §8, and non-negotiable because they are how the existing 433 tests caught nine
real bugs.

1. `SKILL.md` with frontmatter whose `name` equals the directory, or the registry skips it silently.
2. Anything runnable goes in `scripts/` and **must have `--selftest`**. Write the test first.
3. Source lives at `~/Documents/apps/SKILLS/<name>/`, symlinked into `~/.commandcode/skills/<name>`.
4. **No em dashes or en dashes** anywhere, checked with Python rather than `sed`, because `LC_CTYPE=C`
   on macOS replaces bytes instead of characters and the counts lie.
5. **Never invent a number.** A missing price, a missing rate or a missing consent is an error that
   names what is missing.
6. **Dry run first**, fail closed, and never log a payload containing personal data.
7. Store before send. Bounded retries. A thing that is allowed to fail stops being read.

---

# 1. `privacy-by-design`

**Job.** Find personal data sitting where nobody designed for it, and report it with enough detail to
act on, without ever writing or exposing a full value.

**Why now.** The profile run on `relcoai/data/relco.db` found **IP addresses and user agents inside a
`metadata` column**. Every consent record, erasure path and retention rule in `lead-capture` is
undermined while personal data sits outside the model that governs it. This is the only one of the six
that is a live exposure rather than a missing capability.

**Interface.**

```bash
node scripts/scan.mjs <db-or-csv> [--json] [--min-confidence 0.6]
```

- Opens read-only. Never writes, migrates or vacuums. Same posture as `sql-analysis`.
- Enumerates every table and column, samples up to N values per column, and classifies each as:
  email, phone (E.164 and local Pakistani format), IP v4, IP v6, user agent, person name, postal
  address, CNIC, card-like (Luhn), coordinate pair, date of birth, free text containing any of these.
- Reports `table.column`, kind, count, confidence, and the example **masked**.
- Where a schema is available, adds whether that column is reachable by a role with no login, because
  a PII column inside the API's reach is the difference between a leak and a filing cabinet.
- Exit codes: `0` clean, `1` findings, `2` error.

**Rules.** Read-only, always. Confidence is reported, never implied certainty. A scan that cannot read
the file says so and exits 2 rather than reporting clean, because a false clean is worse than a failure.

**Must never.** Print a full phone number, IP, CNIC or email in any output mode. Modify the source.
Descend into a table it was told to skip.

**Tests (`--selftest`), on a fixture database built by the test:**

1. Detects a CNIC in either `12345-1234567-1` or `1234512345671` form.
2. Detects a local mobile `0300 123 4567` and an E.164 `+923004006000` as the same kind.
3. Detects IPv4 and IPv6, including the `::ffff:` form.
4. Does **not** flag a UUID, an SKU, a price in minor units, or an ISO date. These are the false
   positives that make a scanner ignored.
5. Every masked example contains no complete value: assert the output does not contain the fixture's
   full phone string.
6. Exits 1 with findings, 0 on a clean fixture, 2 on an unreadable path.
7. The source file is byte-identical before and after the scan.

**Needs from you.** Nothing to build. The remediation is a decision: the `metadata` column in
`relcoai` either loses those fields, or gains a retention rule and a reason to hold them.

**Lives at.** `~/Documents/apps/SKILLS/privacy-by-design/`, symlinked into the registry.

---

# 2. `unsubscribe` (a capability inside `lead-capture`)

**Job.** A one-click, per-channel unsubscribe that is honoured by every future export and send, with a
token that cannot be forged and an endpoint that cannot be used to discover who is in the database.

**Why now.** Erasure exists and unsubscribe does not. Without it the first marketing send is the first
complaint, which means **this blocks the entire automation chain**, because the chain ends in email.

**Interface.**

- `GET /u/:token`, no login, one click, idempotent. Returns a page that confirms the channel and
  states plainly what has and has not changed.
- `POST /api/unsubscribe` accepts the same token, for clients that cannot follow a link.
- `node scripts/lead-store.mjs unsubscribe <db> --identity <kind:value> | --token <t>`
- `node scripts/lead-store.mjs sendable <db> --channel email` returns only consented AND not
  unsubscribed AND not erased.

**Rules.**

- Token is an HMAC over (identity id, channel, issue timestamp) with the session secret. **No personal
  data in the URL**, because a URL ends up in mail logs, proxies and screenshots.
- Unsubscribe is **per channel**. Unsubscribing from email must leave SMS and WhatsApp sendable.
- It sets a flag and a timestamp. It does **not** delete: that is erasure and a different request.
- Every response for an unknown, expired, erased or valid-but-already-unsubscribed token is the
  **same shape and status**. Otherwise the endpoint becomes an oracle for who is in the database.
- `export` and `sync` both honour it. A marketing export that still contains an unsubscribed address
  is the defect this skill exists to prevent.

**Must never.** Require a login. Send a confirmation email as a precondition (one click means one
click). Unsubscribe a person from a channel they did not use. Return a different response that reveals
whether an address exists.

**Tests:**

1. A valid token sets the flag and records the timestamp.
2. A forged token is refused, with the same response shape as a valid one.
3. An already-unsubscribed token is a no-op success, not an error.
4. A token for a person who does not exist returns the same success shape.
5. Email unsubscribe leaves `sendable --channel phone` unchanged.
6. `export --purpose marketing` excludes them.
7. `sync` excludes them.
8. Token contains no email address or phone number, asserted against the token string itself.

**Needs from you.** Nothing to build. The consent wording that the unsubscribe page quotes needs your
approval, and it is the same sign-off already outstanding in PLAYBOOK §6.1 item 7.

**Lives at.** New module inside `~/Documents/apps/SKILLS/lead-capture/`, plus two routes in
`reference-implementation/server.mjs` and a method in `lead-store.mjs`.

---

# 3. `email-retry-worker`

**Job.** Drain the queued mail log with bounded retries, backoff, a lease so two workers cannot
double-send, and a dead-letter state that is surfaced rather than silent.

**Why now.** "Store before send" is already the design and `email_log` already writes `queued`. Nothing
drains it. So today a failed send is a lead that stops, which is the exact failure the queue exists to
prevent.

**Interface.**

```bash
node scripts/drain.mjs <db> [--limit 50] [--live] [--json]
```

Dry by default, matching `sync.mjs`. The scheduler passes `--live` explicitly, so an accidental manual
run sends nothing.

**Rules.**

- **Re-check at send time**, not at queue time: consent still given, still unsubscribed, still not
  erased. A person who opted out after queueing must not receive it.
- **One send per message.** An idempotency key per queued row, and the provider id stored on success,
  so a provider-side retry cannot produce two emails.
- **Lease, not a lock.** `claimed_at` and `claimed_by` per row, with the claim expiring, so a worker
  that dies does not strand the queue.
- Bounded: exponential backoff with jitter, and after N attempts the row goes `dead`. Dead is counted
  and reported, never silent.
- Transport is pluggable, Resend first, because the sending path already exists there.

**Must never.** Send a message whose consent changed after queueing. Retry forever. Mark a row `sent`
when the provider returned an error. Log the message body.

**Tests:**

1. A queued row is sent once, and marked `sent` with a provider id.
2. A transport failure increments attempts and sets a future `next_attempt_at`, and does **not** mark
   sent.
3. The Nth consecutive failure moves the row to `dead`.
4. Two drains run against the same queue send each row exactly once (lease).
5. A row whose person unsubscribed after queueing is not sent, and is marked `cancelled` with a reason.
6. A row whose consent was withdrawn is not sent.
7. Backoff is monotonic and within the jitter bounds: assert the range, never an exact timestamp.
8. Without `--live`, nothing is sent and the report states what it would have done.

**Needs from you.** A **Full access Resend key** (the current one is sending-only, and returns
`401 restricted_api_key` on `/contacts`), stored with `read -rsp` so it never enters a chat. And SPF
and DMARC on the sending domain before the first live drain.

**Lives at.** `~/Documents/apps/SKILLS/email-retry-worker/`, or as `scripts/drain.mjs` inside
`lead-capture` if you would rather keep the mail path in one place. **Recommendation: inside
`lead-capture`**, because it shares the schema, the consent rules and the transport with `sync.mjs`,
and two copies of a consent check will drift.

---

# 4. `double-opt-in-and-captcha`

**Job.** Gate the public forms against bots without blocking a real enquiry, and require a confirmed
double opt-in before anybody is treated as a marketing subscriber.

**Why now.** Currently deferred until the first spam arrives. That is a defensible position for the
bot half. It is **not** defensible for double opt-in, because consent quality is retroactive and
cannot be fixed after a list exists.

**Interface.**

- A signed form token: HMAC over (form id, issued-at, hashed client fingerprint). Verified server side.
- A provider adapter for Turnstile or hCaptcha, plus a **no-provider fallback** of three local
  signals: time-to-submit, honeypot, and duplicate-content hash.
- Double opt-in: consent to marketing writes `pending`; a confirm link with a single-use signed token
  flips it to `confirmed`.

**Rules.**

- **A captcha outage must not stop a real enquiry.** When the provider fails, fall back to the local
  signals and record which gate let the submission through, so the fallback is visible rather than
  silent.
- The consent record distinguishes `single` from `double`, and stores the wording version for each.
- The honeypot must be safe for assistive technology and real people: `aria-hidden`, `tabindex="-1"`,
  positioned off-screen. Not a visible field labelled "leave blank", which catches humans.
- A confirm link expires and is single-use.

**Must never.** Reject a valid enquiry because a third-party script did not load. Treat a pending
double opt-in as consent. Send marketing to `pending`.

**Tests:**

1. A submission under two seconds old is refused as bot-like; the same form after ten seconds passes.
2. A filled honeypot is refused.
3. A missing or forged form token is refused.
4. With the captcha provider stubbed to throw, a valid enquiry **still succeeds**, and the record says
   it passed on the fallback.
5. Double opt-in: the person is `pending` until confirmed; the first confirm flips it; the second is a
   no-op.
6. A reused confirmation token is refused.
7. Marketing export excludes `pending` and includes `confirmed`.
8. An existing `confirmed` person who submits again does not become `pending` again.

**Needs from you.** Whether you want a captcha provider at all (Turnstile is free and no-script for
most visitors), and approval of the confirmation email wording.

**Lives at.** `~/Documents/apps/SKILLS/double-opt-in-and-captcha/`, with the consent half wired into
`lead-capture` so there is one place that knows what consent means.

---

# 5. `website-quote`

**Job.** Produce a priced quote from the service catalogue, with ranges, assumptions and exclusions,
and refuse to produce one when a price is missing.

**Why now.** `flowscale/catalog/services.yaml` has empty placeholders, so the existing quote path cannot
compute anything. The first client who asks for a number is the day this is needed.

**Interface.**

```bash
node scripts/quote.mjs <catalog.yaml> --service <id> --options <json> [--currency PKR] [--json]
```

Output is a markdown block ready to paste or convert: scope, line items, total, timeline, assumptions,
exclusions, validity.

**Rules.**

- **Refuse to quote on a missing price.** Exit 2, name every missing key, produce no partial quote. A
  total that silently treats a blank as zero is the most expensive kind of wrong in a proposal.
- Money as **integer minor units** with a per-currency exponent: 2 for PKR, and **3 for KWD, BHD and
  OMR**. PLAYBOOK §4.1 exists because assuming 2 is a factor-of-ten error on every Gulf price.
- Every line item traces to a catalogue key, so a quote can be audited back to the price list.
- Exclusions are mandatory. A quote without them is an invitation to argue scope later.
- No em dashes in the rendered output.

**Must never.** Invent a price, a rate or a timeline. Produce a total when an input is unknown. Put a
timestamp inside the quote body, because the same inputs must render the same bytes.

**Tests:**

1. A missing price exits 2 and names the key, with no quote in the output.
2. A known fixture produces the expected total, to the minor unit.
3. A KWD quote uses three decimals.
4. Exclusions are present in every rendered quote.
5. Rendering twice with identical inputs produces byte-identical output.
6. Every line item names a key that exists in the fixture catalogue.
7. An unknown `--service` exits 2 and lists the available ids.

**Needs from you.** Real numbers in `services.yaml`: what each service actually costs, and which
currencies you sell in. Nothing else blocks it.

**Lives at.** `~/Documents/apps/SKILLS/website-quote/`.

---

# 6. `accessibility-audit` and `performance-audit`

Two thin skills rather than one, because they answer different questions and fail for different
reasons. Both are cheaper than they look: most of the accessibility half already exists as the browser
pass built for RELCO Wheels, and `agent-browser` is already installed on this machine.

## 6a. `accessibility-audit`

**Job.** Find the accessibility defects a build cannot see, in a real browser, at real widths.

**Interface.** `node scripts/audit.mjs <url> [--widths 320,375,768,1440] [--json] [--fail-on any|serious]`

Checks, per route and width: horizontal overflow, exactly one `h1`, one `main`, `lang`, heading level
skips, links and buttons with no accessible name, images missing `alt`, form fields without a label
(hidden inputs exempt), and computed contrast for the text and background pairs actually in use.

**Rules.** Report the element and the measured value, never a verdict like "needs improvement". A
contrast finding must name both colours and the ratio. Network access is not required for the DOM half,
which is what makes it testable.

**Tests.** Two local fixture pages, one clean and one with a known defect each: a 400px block at 320,
an unlabelled input, a bare `<a>` around an empty-alt image, an `h1` to `h3` jump, and a 3.1:1 text
pair. Assert every one is caught on the bad fixture and nothing is reported on the clean one.

## 6b. `performance-audit`

**Job.** Measure the metrics, report them with their source, and analyse what is heavy.

**Interface.** `node scripts/audit.mjs <url> [--runs 3] [--json]`

Uses `agent-browser vitals --json` for LCP, CLS, TTFB, FCP and INP, plus a resource pass for total
bytes by type and render-blocking requests.

**Rules.** **Never print a Lighthouse score.** It was not measured, and a borrowed number is exactly
the invention this library forbids. Report each metric, the median of N runs, and the tool that
produced it. State the variance: one run of LCP is not a measurement.

**Tests.** Against a local fixture with one deliberately huge blocking script and one lazy image,
assert the blocking resource is identified, the byte total is reported by type, and the output names
its source. Assert no field is labelled as a Lighthouse score.

**Needs from you.** Nothing. `agent-browser` is installed, and Chrome is present so no Chromium
download is required.

**Lives at.** `~/Documents/apps/SKILLS/accessibility-audit/` and
`~/Documents/apps/SKILLS/performance-audit/`.

---

# Order, and why this order

| Order | Skill | Reason |
|---|---|---|
| 1 | `privacy-by-design` | It is a live exposure, and every other control rests on it. |
| 2 | `unsubscribe` | It blocks every marketing send, so it blocks the chain. |
| 3 | `email-retry-worker` | Without it the wire appears to work and silently drops mail. |
| 4 | `double-opt-in-and-captcha` | Consent quality cannot be repaired retroactively. |
| 5 | `website-quote` | Blocked on your prices, not on code. |
| 6 | the two audits | Genuinely deferrable, and mostly already written. |

Build 1 to 4 before wiring the five `relco-ai-systems` into the website. Wiring first would put an
unproven reply loop behind a consent model that cannot honour an unsubscribe, which is the one sequence
that turns an automation success into a complaint.

# How to prove each one

- `node scripts/<name>.mjs --selftest` passes, and **fails when the rule it protects is broken**. Break
  one check deliberately, confirm the test fails, then restore it. A test that cannot fail is not a
  test, and this library has caught a false pass before.
- Write the tests before the implementation, as PLAYBOOK §8 says, because that is the mechanism that
  found nine real defects.
- For 1, run it against `relcoai/data/relco.db` and confirm it finds the IP addresses and user agents
  in `metadata`. If it does not, the scanner is wrong, not the database.
- For 3, prove idempotency by running two drains concurrently against one queue.
- For 4, prove the fallback by stubbing the captcha provider to throw.
