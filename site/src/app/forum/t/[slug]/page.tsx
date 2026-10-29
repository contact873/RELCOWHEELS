import Link from "next/link";
import { notFound } from "next/navigation";
import { getThread, threadsInCategory, seedThreads } from "@/lib/queries";
import { renderBody, plainText } from "@/lib/render";
import { titleCase, when } from "@/lib/format";

type Params = Promise<{ slug: string }>;

export function generateStaticParams() {
  return seedThreads.map((t) => ({ slug: t.slug }));
}

export async function generateMetadata({ params }: { params: Params }) {
  const { slug } = await params;
  const thread = getThread(slug);
  if (!thread) return { title: "Thread not found" };

  return {
    title: thread.title,
    description: plainText(thread.bodyHtml).slice(0, 155),
    alternates: { canonical: `/forum/t/${thread.slug}` },
    /*
      A thread with fewer than two replies is a thin page. Google reads a site that generates
      thousands of those as low quality, so they stay out of the index until somebody answers.
      This is the same crawl-budget discipline PakWheels applies with its parameter disallows.
    */
    robots: { index: thread.replyCount >= 2, follow: true },
  };
}

export default async function ThreadPage({ params }: { params: Params }) {
  const { slug } = await params;
  const thread = getThread(slug);
  if (!thread) notFound();

  const SITE = process.env.NEXT_PUBLIC_SITE_URL ?? "https://wheels.relcoai.com";
  const others = threadsInCategory(thread.categorySlug).filter((t) => t.id !== thread.id).slice(0, 4);

  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "DiscussionForumPosting",
    headline: thread.title,
    text: plainText(thread.bodyHtml),
    datePublished: thread.createdAt,
    dateModified: thread.lastReplyAt ?? thread.createdAt,
    inLanguage: "en-PK",
    author: { "@type": "Person", name: thread.authorName },
    commentCount: thread.replyCount,
    isPartOf: { "@type": "WebSite", name: "RELCO Wheels", url: SITE },
  };

  return (
    <div className="wrap-x py-10">
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />

      <nav aria-label="Breadcrumb" className="text-sm text-sold">
        <Link href="/" className="hover:text-brand">Home</Link>
        <span className="mx-2">/</span>
        <Link href="/forum" className="hover:text-brand">Forum</Link>
        <span className="mx-2">/</span>
        <Link href={`/forum/${thread.categorySlug}`} className="hover:text-brand">{thread.categoryName}</Link>
      </nav>

      <div className="mt-4 grid gap-12 lg:grid-cols-[1.4fr_0.6fr]">
        <article>
          <div className="flex flex-wrap items-center gap-2">
            {thread.isPinned && <span className="badge">Pinned</span>}
            <span className="badge">{thread.kind === "question" ? "Question" : "Discussion"}</span>
            {thread.replyCount < 2 && <span className="badge badge-held">Not indexed yet</span>}
          </div>

          <h1 className="mt-3 text-2xl leading-tight md:text-3xl">{thread.title}</h1>

          <p className="data mt-3 text-xs text-sold">
            {thread.authorName}
            {thread.authorRole === "dealer" && " (dealer)"}
            <span className="mx-2">/</span>
            {when(thread.createdAt)}
            <span className="mx-2">/</span>
            {thread.replyCount} {thread.replyCount === 1 ? "reply" : "replies"}
          </p>

          {thread.listingRef && (
            <div className="mt-5 border border-border bg-bg-alt p-4">
              <p className="text-xs uppercase tracking-[0.1em] text-sold">About this car</p>
              <Link
                href={`/car/${thread.listingSlug}`}
                className="mt-1 inline-block text-base font-semibold text-brand hover:underline"
              >
                {thread.listingTitle}
              </Link>
              <p className="data mt-1 text-xs text-sold">Reference {thread.listingRef}</p>
            </div>
          )}

          <div
            className="mt-6 space-y-3 text-base text-body [&_p]:leading-relaxed"
            dangerouslySetInnerHTML={{ __html: renderBody(thread.bodyHtml) }}
          />

          <ol className="mt-10 space-y-6">
            {thread.posts.map((post, index) => (
              <li
                key={post.id}
                className={`border-l-2 pl-5 ${
                  post.isAcceptedAnswer ? "border-brand" : "border-border"
                }`}
              >
                <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1">
                  <Link href={`/forum/u/${post.authorHandle}`} className="text-sm font-semibold text-heading hover:text-brand">
                    {post.authorName}
                  </Link>
                  {post.authorRole === "dealer" && <span className="text-xs text-sold">Dealer</span>}
                  <span className="data text-xs text-sold">{when(post.createdAt)}</span>
                  {post.isAcceptedAnswer && <span className="badge badge-verified">Accepted answer</span>}
                  {post.editCount > 0 && (
                    <span className="data text-xs text-sold">
                      edited {post.editCount === 1 ? "once" : `${post.editCount} times`}
                    </span>
                  )}
                </div>

                <div
                  className="mt-2 space-y-2 text-sm text-body [&_p]:leading-relaxed"
                  dangerouslySetInnerHTML={{ __html: renderBody(post.bodyHtml) }}
                />

                <p className="mt-2 text-xs text-sold">
                  {index === 0 ? "First reply" : `Reply ${index + 1}`}
                  <span className="mx-2">/</span>
                  {post.authorPostCount} posts
                </p>
              </li>
            ))}
          </ol>

          <section className="mt-10 border border-border bg-bg-alt p-5">
            <h2 className="text-base">Reply</h2>
            <p className="mt-1 text-sm text-sold">
              Sign in to reply. A first post is held for review, everything after it publishes straight
              away.
            </p>
            <div className="mt-4 space-y-3">
              <textarea
                rows={4}
                placeholder="What do you want to add?"
                className="w-full border border-border bg-bg px-3 py-2 text-sm text-heading placeholder:text-sold focus:border-brand focus:outline-none"
              />
              <button type="button" className="btn btn-primary">
                Post reply
              </button>
            </div>
          </section>
        </article>

        <aside>
          <h2 className="text-sm font-semibold uppercase tracking-[0.12em] text-heading">
            More in {titleCase(thread.categoryName.toLowerCase())}
          </h2>
          <ul className="mt-4 space-y-4">
            {others.map((t) => (
              <li key={t.id} className="border-b border-border pb-3">
                <Link href={`/forum/t/${t.slug}`} className="text-sm font-semibold text-heading hover:text-brand">
                  {t.title}
                </Link>
                <p className="data mt-1 text-xs text-sold">{t.replyCount} replies</p>
              </li>
            ))}
            {others.length === 0 && (
              <li className="text-sm text-sold">Nothing else here yet. This is the first thread.</li>
            )}
          </ul>
        </aside>
      </div>
    </div>
  );
}
