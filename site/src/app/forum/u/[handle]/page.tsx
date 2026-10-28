import Link from "next/link";
import { notFound } from "next/navigation";
import { ListingTile } from "@/components/listing-card";
import { dealerListings, getProfile, seedProfiles, seedThreads } from "@/lib/queries";
import { when } from "@/lib/format";

type Params = Promise<{ handle: string }>;

export function generateStaticParams() {
  return seedProfiles.map((p) => ({ handle: p.handle }));
}

export async function generateMetadata({ params }: { params: Params }) {
  const { handle } = await params;
  const profile = getProfile(handle);
  if (!profile) return { title: "Member not found" };
  return {
    title: profile.displayName,
    description:
      profile.bio ??
      `${profile.displayName} on RELCO Wheels. ${profile.listingCount} listings, ${profile.postCount} forum posts.`,
    alternates: { canonical: `/forum/u/${profile.handle}` },
  };
}

export default async function ProfilePage({ params }: { params: Params }) {
  const { handle } = await params;
  const profile = getProfile(handle);
  if (!profile) notFound();

  const listings = dealerListings(profile.handle);
  const threads = seedThreads.filter(
    (t) => t.authorHandle === profile.handle || t.posts.some((p) => p.authorHandle === profile.handle),
  );

  const SITE = process.env.NEXT_PUBLIC_SITE_URL ?? "https://wheels.relcoai.com";
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Person",
    name: profile.displayName,
    description: profile.bio ?? undefined,
    url: `${SITE}/forum/u/${profile.handle}`,
    memberOf: { "@type": "Organization", name: "RELCO Wheels" },
  };

  return (
    <div className="wrap-x py-10">
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />

      <nav aria-label="Breadcrumb" className="text-sm text-sold">
        <Link href="/" className="hover:text-brand">Home</Link>
        <span className="mx-2">/</span>
        <Link href="/forum" className="hover:text-brand">Forum</Link>
        <span className="mx-2">/</span>
        <span className="text-heading">{profile.displayName}</span>
      </nav>

      <header className="mt-5 border-b border-border pb-8">
        <div className="flex flex-wrap items-center gap-3">
          <h1 className="text-3xl md:text-4xl">{profile.displayName}</h1>
          <span className="badge">{profile.role === "dealer" ? "Dealer" : "Member"}</span>
        </div>

        {profile.bio && <p className="mt-3 max-w-[64ch] text-body">{profile.bio}</p>}

        <dl className="data mt-5 flex flex-wrap gap-x-8 gap-y-2 text-sm">
          <div className="flex gap-2">
            <dt className="text-sold">Joined</dt>
            <dd className="m-0 text-heading">{when(profile.joinedAt)}</dd>
          </div>
          {profile.cityName && (
            <div className="flex gap-2">
              <dt className="text-sold">City</dt>
              <dd className="m-0 text-heading">{profile.cityName}</dd>
            </div>
          )}
          <div className="flex gap-2">
            <dt className="text-sold">Listings</dt>
            <dd className="m-0 text-heading">{profile.listingCount}</dd>
          </div>
          <div className="flex gap-2">
            <dt className="text-sold">Posts</dt>
            <dd className="m-0 text-heading">{profile.postCount}</dd>
          </div>
          <div className="flex gap-2">
            <dt className="text-sold">Accepted answers</dt>
            <dd className="m-0 text-heading">{profile.acceptedAnswers}</dd>
          </div>
        </dl>
      </header>

      {listings.length > 0 && (
        <section className="mt-10">
          <h2 className="text-xl">
            {profile.role === "dealer" ? "Their stock" : "Their listings"}
          </h2>
          <div className="mt-5 grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
            {listings.map((l) => (
              <ListingTile key={l.id} listing={l} />
            ))}
          </div>
        </section>
      )}

      <section className="mt-12">
        <h2 className="text-xl">On the forum</h2>
        {threads.length === 0 ? (
          <p className="mt-3 text-sm text-sold">Nothing posted yet.</p>
        ) : (
          <ul className="mt-4">
            {threads.map((t) => (
              <li key={t.id} className="border-b border-border py-4">
                <Link href={`/forum/t/${t.slug}`} className="text-base font-semibold text-heading hover:text-brand">
                  {t.title}
                </Link>
                <p className="data mt-1 text-xs text-sold">
                  {t.categoryName}
                  <span className="mx-2">/</span>
                  {t.replyCount} replies
                  <span className="mx-2">/</span>
                  {when(t.createdAt)}
                </p>
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  );
}
