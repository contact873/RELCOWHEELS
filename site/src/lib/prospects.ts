/**
 * Dealer previews.
 *
 * A page per dealership, so a prospect can see their own cars in this frame before they have agreed
 * to anything. Two rules govern the whole file.
 *
 * Nothing here is invented. An address appears because the dealership publishes it. A phone number
 * appears only once we hold it from them. A stock count appears only once somebody has counted. The
 * empty strings are not laziness, they are the same rule as src/lib/contact.ts: publishing a
 * number that nobody answers is worse than publishing none.
 *
 * And a page stays out of search until `status` is "live". A preview carrying a real company's name
 * is a sales document, not a page of the site, and it must not turn up in Google under their name
 * before they have seen it.
 */

export type ProspectStatus =
  /** Our own sample content, for showing the shape of a populated dealer page. */
  | "sample"
  /** A real business we are pitching. Not authorised, not indexed. */
  | "preview"
  /** They have authorised us in writing. Indexed. */
  | "live";

export interface Prospect {
  slug: string;
  name: string;
  city: string;
  /**
   * The seller handle in the listing data, when we hold stock for them. Underscores, not hyphens,
   * because it has to match `profiles.handle` and `listings.sellerHandle`.
   */
  handle?: string;
  /** As the dealership publishes it. Empty until we have it from them or from their own site. */
  addressLines: string[];
  phone: string;
  whatsapp: string;
  /** Cars they hold. null until somebody counts, rather than a guess. */
  stockCount: number | null;
  status: ProspectStatus;
  /** ISO date of their written authorisation. null means we hold nothing. */
  authorisedOn: string | null;
  /** Why the fields above are what they are. Read this before filling one in. */
  notes: string[];
}

export const PROSPECTS: Prospect[] = [
  {
    slug: "sigma-motors",
    name: "Sigma Motors",
    city: "Lahore",
    addressLines: ["22 Khyaban-e-Jinnah, opposite UCP, Johar Town"],
    phone: "",
    whatsapp: "",
    stockCount: 83,
    status: "preview",
    authorisedOn: null,
    notes: [
      "Not authorised. Nothing on this page is theirs and no listing belongs to them.",
      "The address and the stock count come from their own public inventory page, which listed 83 cars.",
      "Their phone is deliberately blank. It is on their site, but putting it on ours would route their callers somewhere they did not choose.",
      "Delete this page the moment the pitch is decided either way.",
    ],
  },
  {
    slug: "zahid-autos",
    name: "Zahid Autos",
    city: "Lahore",
    handle: "zahid_autos",
    addressLines: [],
    phone: "",
    whatsapp: "",
    stockCount: null,
    status: "sample",
    authorisedOn: null,
    notes: [
      "Invented, like every other listing in src/lib/seed.ts. It exists so a dealer page can be seen with stock on it.",
      "Never show this one to a prospect as if it were a real dealership.",
    ],
  },
];

export function getProspect(slug: string): Prospect | null {
  return PROSPECTS.find((p) => p.slug === slug) ?? null;
}

/** Only an authorised dealership may be indexed. Everything else stays out of search. */
export function isIndexable(p: Prospect): boolean {
  return p.status === "live" && p.authorisedOn !== null;
}
