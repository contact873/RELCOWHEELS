import type { MetadataRoute } from "next";

const SITE = process.env.NEXT_PUBLIC_SITE_URL ?? "https://wheels.relcoai.com";
const HAS_DATABASE = Boolean(process.env.NEXT_PUBLIC_SUPABASE_URL);

/**
 * Crawl discipline.
 *
 * Stolen from what PakWheels does well, and tightened. A marketplace generates an enormous number of
 * near-duplicate URLs, and a crawler that wanders into them spends its budget on pages that should
 * not rank rather than on the ones that should.
 *
 * While the site is running on sample content, everything is disallowed. That is deliberate: a page
 * of invented cars ranking for a real model name would be actively harmful, and it would compete with
 * the real listing once it exists. The moment NEXT_PUBLIC_SUPABASE_URL is set, the blanket rule
 * disappears on its own and the discipline list takes over.
 *
 * Once live, three groups are blocked:
 *
 *   1. Endpoints and private areas. A crawler has no business in /auth or /account, and a signed out
 *      bot sees a redirect or an empty page, both of which read as thin content. Those pages also
 *      carry noindex in their own metadata, as a second line of defence.
 *   2. Parameterised duplicates. Sorting and tracking parameters multiply every listing into a dozen
 *      variants of the same page. Canonical tags cover it, but blocking it is cheaper.
 *
 * Deliberately left crawlable: /sell, /find-my-car, /write and every legal page. Those are real pages
 * that should rank.
 */
export default function robots(): MetadataRoute.Robots {
  if (!HAS_DATABASE) {
    return {
      rules: [{ userAgent: "*", disallow: "/" }],
    };
  }

  return {
    rules: [
      {
        userAgent: "*",
        allow: "/",
        disallow: [
          "/api/",
          "/auth/",
          "/account/",
          "/admin/",
          "/report/",
          "/*?sortby=",
          "/*?utm_",
          "/*?ref=",
          "/*&sortby=",
        ],
      },
    ],
    sitemap: `${SITE}/sitemap.xml`,
    host: SITE,
  };
}
