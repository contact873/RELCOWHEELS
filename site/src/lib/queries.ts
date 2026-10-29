import {
  BODY_BLURBS,
  BODY_TYPES,
  BUDGET_BANDS,
  countByBody,
  countByCity,
  countByMake,
  liveListings,
  seedArticles,
  seedCategories,
  seedListings,
  seedProfiles,
  seedThreads,
  soldListings,
} from "./seed";
import type { Article, ForumCategory, ForumThread, Listing, PublicProfile } from "./types";

/**
 * Every read the pages make goes through this file.
 *
 * Right now it reads the sample content in seed.ts. When Supabase exists, the bodies below become
 * queries and the pages do not change at all, which is the entire reason this layer is here rather
 * than importing seed data directly into components.
 *
 * One rule for whoever writes those queries: a function in this file must never return an email
 * address or a seller's unmasked phone number to a caller that renders HTML. Those exist only in
 * the lead and account flows.
 */

export interface BrowseFilters {
  make?: string;
  city?: string;
  body?: string;
  budget?: string;
  transmission?: string;
  fuel?: string;
  importOnly?: boolean;
  maxPrice?: number;
  minPrice?: number;
  q?: string;
  sort?: "recent" | "price-asc" | "price-desc" | "mileage-asc" | "year-desc";
}

export interface BrowseResult {
  listings: Listing[];
  total: number;
  /** How many were removed by each filter. Used to explain an empty result rather than shrug. */
  applied: { label: string; count: number }[];
}

export function browseCars(filters: BrowseFilters): BrowseResult {
  let rows = liveListings();
  const total = rows.length;
  const applied: { label: string; count: number }[] = [];

  const step = (label: string, predicate: (l: Listing) => boolean) => {
    const before = rows.length;
    rows = rows.filter(predicate);
    if (rows.length !== before) applied.push({ label, count: before - rows.length });
  };

  if (filters.make) step(`Make: ${filters.make}`, (l) => l.makeSlug === filters.make!);
  if (filters.city) step(`City: ${filters.city}`, (l) => l.citySlug === filters.city!);
  if (filters.body) {
    const body = filters.body.toLowerCase();
    step(`Body: ${filters.body}`, (l) => (l.bodyType ?? "").toLowerCase() === body);
  }
  if (filters.transmission) {
    step(`Gearbox: ${filters.transmission}`, (l) => l.transmission === filters.transmission);
  }
  if (filters.fuel) step(`Fuel: ${filters.fuel}`, (l) => l.fuel === filters.fuel);
  if (filters.importOnly) step("Imported only", (l) => l.assembly === "imported");

  if (filters.budget) {
    const band = BUDGET_BANDS.find((b) => b.slug === filters.budget);
    if (band) step(band.label, (l) => l.pricePkr !== null && l.pricePkr < band.under);
  }

  if (filters.minPrice !== undefined) {
    step(`From PKR ${filters.minPrice.toLocaleString("en-PK")}`, (l) => (l.pricePkr ?? 0) >= filters.minPrice!);
  }
  if (filters.maxPrice !== undefined) {
    step(`Up to PKR ${filters.maxPrice.toLocaleString("en-PK")}`, (l) => (l.pricePkr ?? 0) <= filters.maxPrice!);
  }

  if (filters.q) {
    const needle = filters.q.toLowerCase();
    step(`Matching "${filters.q}"`, (l) =>
      `${l.title} ${l.makeName} ${l.modelName} ${l.cityName} ${l.areaName ?? ""} ${l.bodyType ?? ""}`
        .toLowerCase()
        .includes(needle),
    );
  }

  switch (filters.sort) {
    case "price-asc":
      rows = [...rows].sort((a, b) => (a.pricePkr ?? Infinity) - (b.pricePkr ?? Infinity));
      break;
    case "price-desc":
      rows = [...rows].sort((a, b) => (b.pricePkr ?? -1) - (a.pricePkr ?? -1));
      break;
    case "mileage-asc":
      rows = [...rows].sort((a, b) => (a.mileageKm ?? Infinity) - (b.mileageKm ?? Infinity));
      break;
    case "year-desc":
      rows = [...rows].sort((a, b) => b.modelYear - a.modelYear);
      break;
    default:
      rows = [...rows].sort(
        (a, b) => new Date(b.publishedAt).getTime() - new Date(a.publishedAt).getTime(),
      );
  }

  return { listings: rows, total, applied };
}

export function getListing(slug: string): Listing | null {
  return seedListings.find((l) => l.slug === slug) ?? null;
}

export function allListingSlugs(): string[] {
  return seedListings.map((l) => l.slug);
}

/** Same make or model, near in price, excluding the car you are already looking at. */
export function similarListings(listing: Listing, limit = 4): Listing[] {
  const price = listing.pricePkr ?? 0;
  return liveListings()
    .filter((l) => l.id !== listing.id)
    .map((l) => {
      let score = 0;
      if (l.modelSlug === listing.modelSlug && l.makeSlug === listing.makeSlug) score += 100;
      else if (l.makeSlug === listing.makeSlug) score += 40;
      if (l.bodyType && l.bodyType === listing.bodyType) score += 20;
      if (l.citySlug === listing.citySlug) score += 10;
      if (price > 0 && l.pricePkr) {
        const gap = Math.abs(l.pricePkr - price) / price;
        score += Math.max(0, 30 - gap * 100);
      }
      return { l, score };
    })
    .sort((a, b) => b.score - a.score)
    .slice(0, limit)
    .map((x) => x.l);
}

export function getArticle(slug: string): Article | null {
  return seedArticles.find((a) => a.slug === slug && a.status === "published") ?? null;
}

export function publishedArticles(): Article[] {
  return seedArticles
    .filter((a) => a.status === "published")
    .sort((a, b) => new Date(b.publishedAt!).getTime() - new Date(a.publishedAt!).getTime());
}

export function getThread(slug: string): ForumThread | null {
  return seedThreads.find((t) => t.slug === slug) ?? null;
}

export function threadsInCategory(categorySlug: string): ForumThread[] {
  return seedThreads
    .filter((t) => t.categorySlug === categorySlug)
    .sort((a, b) => new Date(b.lastReplyAt ?? b.createdAt).getTime() - new Date(a.lastReplyAt ?? a.createdAt).getTime());
}

export function getCategory(slug: string): ForumCategory | null {
  return seedCategories.find((c) => c.slug === slug) ?? null;
}

export function getProfile(handle: string): PublicProfile | null {
  return seedProfiles.find((p) => p.handle === handle) ?? null;
}

export function dealerListings(handle: string): Listing[] {
  return seedListings.filter((l) => l.sellerHandle === handle && l.status === "live");
}

export {
  BODY_BLURBS,
  BODY_TYPES,
  BUDGET_BANDS,
  countByBody,
  countByCity,
  countByMake,
  liveListings,
  seedArticles,
  seedCategories,
  seedListings,
  seedProfiles,
  seedThreads,
  soldListings,
};
