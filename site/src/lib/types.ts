// Types mirroring supabase/migrations/0001_init.sql and 0002_blog_forum.sql.
// Kept hand written rather than generated, because at this size a generated file is more
// machinery than the problem needs. Regenerate with `supabase gen types` once the schema settles.

export type Vertical = "car" | "bike" | "parts";
export type ListingStatus = "draft" | "pending" | "live" | "sold" | "rejected" | "expired";
export type UserRole = "member" | "dealer" | "admin";
export type Fuel = "petrol" | "diesel" | "hybrid" | "electric" | "cng" | "lpg";
export type Transmission = "manual" | "automatic";

export interface City {
  id: number;
  name: string;
  slug: string;
  province: string;
  isPopular: boolean;
}

export interface Make {
  id: number;
  name: string;
  slug: string;
  listingCount?: number;
}

export interface Model {
  id: number;
  makeId: number;
  name: string;
  slug: string;
  listingCount?: number;
}

export interface Inspection {
  overallScore: number | null;
  exterior: number | null;
  engine: number | null;
  suspension: number | null;
  interior: number | null;
  ac: number | null;
  inspectedOn: string;
}

export interface Listing {
  id: number;
  reference: string;
  vertical: Vertical;
  slug: string;
  title: string;
  description: string | null;

  makeName: string;
  makeSlug: string;
  modelName: string;
  modelSlug: string;
  variantName: string | null;
  modelYear: number;

  pricePkr: number | null;
  priceOnCall: boolean;
  mileageKm: number | null;
  engineCc: number | null;
  transmission: Transmission | null;
  fuel: Fuel | null;
  bodyType: string | null;
  color: string | null;
  assembly: "local" | "imported" | null;
  seats: number | null;

  cityName: string;
  citySlug: string;
  areaName: string | null;
  registeredIn: string | null;

  status: ListingStatus;
  ownerCount: number | null;
  isAccidental: boolean | null;
  hasAuctionSheet: boolean;

  photos: { path: string; alt: string }[];
  featureKeys: string[];
  inspection: Inspection | null;

  sellerName: string;
  sellerHandle: string;
  sellerRole: UserRole;
  sellerIsDealer: boolean;

  publishedAt: string;
  updatedAt: string;
  viewCount: number;
  phoneRevealCount: number;
}

export interface PublicProfile {
  handle: string;
  displayName: string;
  role: UserRole;
  bio: string | null;
  cityName: string | null;
  avatarPath: string | null;
  joinedAt: string;
  listingCount: number;
  threadCount: number;
  postCount: number;
  acceptedAnswers: number;
}

// ---------------------------------------------------------------------------
// Blog and forum
// ---------------------------------------------------------------------------

export type ArticleStatus = "draft" | "submitted" | "in_review" | "published" | "rejected";

export interface Article {
  id: number;
  slug: string;
  title: string;
  dek: string;
  bodyHtml: string;
  status: ArticleStatus;
  coverPath: string | null;
  tags: string[];
  authorHandle: string;
  authorName: string;
  isGuest: boolean;
  publishedAt: string | null;
  updatedAt: string;
  viewCount: number;
  readingMinutes: number;
}

export type ThreadKind = "discussion" | "question";
export type PostStatus = "visible" | "held" | "flagged" | "hidden";

export interface ForumCategory {
  id: number;
  name: string;
  slug: string;
  description: string;
  threadCount: number;
  position: number;
}

export interface ForumPost {
  id: number;
  threadId: number;
  parentPostId: number | null;
  bodyHtml: string;
  authorHandle: string;
  authorName: string;
  authorRole: UserRole;
  authorPostCount: number;
  isAcceptedAnswer: boolean;
  status: PostStatus;
  editedAt: string | null;
  editCount: number;
  createdAt: string;
}

export interface ForumThread {
  id: number;
  slug: string;
  title: string;
  kind: ThreadKind;
  categorySlug: string;
  categoryName: string;
  bodyHtml: string;
  authorHandle: string;
  authorName: string;
  authorRole: UserRole;
  listingRef: string | null;
  listingSlug: string | null;
  listingTitle: string | null;
  replyCount: number;
  viewCount: number;
  isPinned: boolean;
  isLocked: boolean;
  posts: ForumPost[];
  createdAt: string;
  lastReplyAt: string | null;
}
