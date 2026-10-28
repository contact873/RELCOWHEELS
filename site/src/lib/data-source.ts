/**
 * Where the site is reading from, in one place.
 *
 * This exists because of a defect that only appeared once a real Supabase project existed. The
 * sample-content banner, the robots rule and the sitemap were all gated on "is a Supabase URL
 * configured". The moment a URL was set, all three flipped to production behaviour, while
 * `src/lib/queries.ts` was still returning the invented cars in `seed.ts`. The site would have
 * dropped its "these cars are not real" banner and started inviting search engines in, while showing
 * nothing but sample content.
 *
 * So the gate is not "is a database reachable". It is "is this build actually reading from one", and
 * that is a deliberate switch rather than an inference. Shipping an inference here means the two
 * things drift apart silently the next time either changes.
 *
 * To go live:
 *
 *   1. Point `src/lib/queries.ts` at Supabase. Until that is done, this flag must stay on "sample".
 *   2. Set NEXT_PUBLIC_DATA_SOURCE=database in `.env.local` and in Vercel.
 *
 * Both steps, not one. If only the second is done, the site will claim to be live while showing
 * placeholder content, and nothing will complain.
 */
export function isSampleData(): boolean {
  return process.env.NEXT_PUBLIC_DATA_SOURCE !== "database";
}
