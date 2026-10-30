# Signing in with Google, Apple or a phone

Status: **the database side is built and tested. Nothing is wired up in the app yet, and no provider
is configured.**

## What is already done

Migration `0006_signup.sql` closes the gap that would have blocked every provider at once. The
schema's `profiles.id` references `auth.users`, and every row level security policy compares a column
to `auth.uid()`, but nothing created the profile. A sign-up would have produced an auth user that the
rest of the database did not acknowledge.

It now has a trigger on `auth.users` that creates, in one transaction:

- the `profiles` row, with a display name repaired to fit the table's own rules rather than rejected
- the `private.profile_contacts` row, because `profiles.email` was deliberately dropped in `0003`
- the `private.user_identities` row, recording which provider it came through

It also adds `apple` to the `auth_provider` enum, which had only email, google, facebook and mobile.

Three behaviours worth knowing, all tested in `tools/dbcheck`:

| Case | What happens |
|---|---|
| Name contains punctuation, digits or a hyphen | Repaired to letters, sign-up succeeds. "O'Brien-Smith 3rd" would otherwise be a support ticket for every fifth user. |
| Name impersonates the platform ("RELCO Admin") | Replaced with a neutral name, sign-up succeeds. The table's guard still refuses the write, so the name cannot survive. |
| Two people with the same name | Both get an account, with distinct display names and handles. |

## What is not done

- No Supabase client in the app. `@supabase/ssr` is a declared dependency that nothing imports.
- No callback route, no session handling, no middleware.
- The two buttons on `/auth/sign-in` are hardcoded `disabled`, and the page currently claims social
  sign-in is "configuration rather than code". **That is wrong** and contradicts the above.

## Google: free, and about thirty minutes

1. Google Cloud Console, create an OAuth 2.0 Client ID of type Web application.
2. Authorised redirect URI, exactly:
   `https://ecjyqamcegxbnpidrfqb.supabase.co/auth/v1/callback`
   Add the staging ref too once it has migrations.
3. Supabase, Authentication, Providers, Google: enable it and paste the Client ID and secret.
4. Supabase, Authentication, URL Configuration: Site URL plus an allowlist entry for every origin,
   including `https://relcowheels.vercel.app` and `http://localhost:3000`.
5. Then the app code: client helpers, a `/auth/callback` route, session refresh middleware, and
   buttons that read from an environment variable rather than being hardcoded off.

## Apple: needs money, and needs the domain first

1. **Apple Developer Program, 99 USD a year.** There is no free route. This is the whole obstacle.
2. A Services ID for the web, a Team ID, a Key ID and the `.p8` private key.
3. **Domain verification.** Apple verifies the domain the redirect lives on, and it expects a domain
   you control. A `*.vercel.app` subdomain cannot satisfy that, because you cannot serve Apple's
   verification file from the root of vercel.app.
4. Then enable the Apple provider in Supabase with those four values.

**So Apple is blocked behind the domain decision**, which is the same one that gates email and the
canonical URL. It is also the same decision that gates being taken seriously as a property rather
than a preview deployment.

## Phone: possible, and second on purpose

Supabase supports one-time codes over SMS, which needs an SMS provider (Twilio, MessageBird, Vonage)
and costs per message. Deliverability into Pakistan is its own work. It stays second because most
buyers here have a phone and many have no email, so it belongs, but nothing about it is free.

## What I cannot verify

**An OAuth round trip cannot be tested without real credentials.** I can build the code path and prove
it compiles, that the buttons gate correctly when unconfigured, and that anonymous browsing is
unaffected. I cannot prove a sign-in works end to end until a Google client ID exists. Given how the
`is_admin` fault in `0005` behaved, that distinction is worth keeping: built and compiling is not the
same as working.

## Facebook

Already on the page as a second option. Also possible, and also gated by Meta's App Review for any
non-tester user, which took a different shape earlier in this project when the Facebook Page question
came up. Lower priority than Google, which covers the same need with none of the review.
