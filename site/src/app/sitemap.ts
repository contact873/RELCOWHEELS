import type { MetadataRoute } from "next";
import { isSampleData } from "@/lib/data-source";
import {
  liveListings,
  publishedArticles,
  seedCategories,
  seedThreads,
  soldListings,
} from "@/lib/queries";

const SITE = process.env.NEXT_PUBLIC_SITE_URL ?? "https://wheels.relcoai.com";

/**
 * The sitemap.
 *
 * Two decisions worth recording.
 *
 * Sold listings are included. They are the most valuable pages on the site, because what a car
 * actually fetched is the thing nobody else in Pakistan publishes. A sold page that resolves and
 * shows its final price is an asset; one that 404s throws away the traffic it already earned.
 *
 * Forum threads only appear once they have two or more replies. A forum generates thousands of
 * near-empty pages faster than anything else, and that is the fastest way to make a whole site look
 * low quality to a search engine. This mirrors the `robots` metadata on the thread page itself.
 *
 * While the site runs on sample content the sitemap is empty, matching the blanket disallow in
 * robots.ts. Both switch on together when a database is connected.
 */
export default function sitemap(): MetadataRoute.Sitemap {
  if (isSampleData()) return [];

  const now = new Date();

  const core: MetadataRoute.Sitemap = [
    { url: `${SITE}/`, lastModified: now, changeFrequency: "daily", priority: 1 },
    { url: `${SITE}/cars`, lastModified: now, changeFrequency: "hourly", priority: 0.9 },
    { url: `${SITE}/sell`, lastModified: now, changeFrequency: "monthly", priority: 0.7 },
    { url: `${SITE}/find-my-car`, lastModified: now, changeFrequency: "monthly", priority: 0.6 },
    { url: `${SITE}/forum`, lastModified: now, changeFrequency: "hourly", priority: 0.8 },
    { url: `${SITE}/blog`, lastModified: now, changeFrequency: "weekly", priority: 0.8 },
    { url: `${SITE}/write`, lastModified: now, changeFrequency: "monthly", priority: 0.4 },
    { url: `${SITE}/safety`, lastModified: now, changeFrequency: "yearly", priority: 0.5 },
    { url: `${SITE}/privacy`, lastModified: now, changeFrequency: "yearly", priority: 0.3 },
    { url: `${SITE}/terms`, lastModified: now, changeFrequency: "yearly", priority: 0.3 },
    { url: `${SITE}/cookies`, lastModified: now, changeFrequency: "yearly", priority: 0.3 },
  ];

  const listings: MetadataRoute.Sitemap = [...liveListings(), ...soldListings()].map((l) => ({
    url: `${SITE}/car/${l.slug}`,
    lastModified: new Date(l.updatedAt),
    changeFrequency: "daily",
    priority: 0.8,
  }));

  const articles: MetadataRoute.Sitemap = publishedArticles().map((a) => ({
    url: `${SITE}/blog/${a.slug}`,
    lastModified: new Date(a.updatedAt),
    changeFrequency: "monthly",
    priority: 0.7,
  }));

  const categories: MetadataRoute.Sitemap = seedCategories.map((c) => ({
    url: `${SITE}/forum/${c.slug}`,
    lastModified: now,
    changeFrequency: "daily",
    priority: 0.6,
  }));

  const threads: MetadataRoute.Sitemap = seedThreads
    .filter((t) => t.replyCount >= 2)
    .map((t) => ({
      url: `${SITE}/forum/t/${t.slug}`,
      lastModified: new Date(t.lastReplyAt ?? t.createdAt),
      changeFrequency: "weekly",
      priority: 0.6,
    }));

  return [...core, ...listings, ...articles, ...categories, ...threads];
}
