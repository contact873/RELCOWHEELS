import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import { getArticle, publishedArticles } from "@/lib/queries";
import { renderBody } from "@/lib/render";
import { when } from "@/lib/format";

type Params = Promise<{ slug: string }>;

export function generateStaticParams() {
  return publishedArticles().map((a) => ({ slug: a.slug }));
}

export async function generateMetadata({ params }: { params: Params }) {
  const { slug } = await params;
  const article = getArticle(slug);
  if (!article) return { title: "Article not found" };

  return {
    title: article.title,
    description: article.dek,
    alternates: { canonical: `/blog/${article.slug}` },
    openGraph: {
      type: "article",
      title: article.title,
      description: article.dek,
      publishedTime: article.publishedAt ?? undefined,
      modifiedTime: article.updatedAt,
      authors: [article.authorName],
      images: article.coverPath ? [article.coverPath] : [],
    },
  };
}

export default async function ArticlePage({ params }: { params: Params }) {
  const { slug } = await params;
  const article = getArticle(slug);
  if (!article) notFound();

  const SITE = process.env.NEXT_PUBLIC_SITE_URL ?? "https://wheels.relcoai.com";
  const related = publishedArticles().filter((a) => a.slug !== article.slug).slice(0, 3);

  const jsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "BlogPosting",
        headline: article.title,
        description: article.dek,
        datePublished: article.publishedAt,
        dateModified: article.updatedAt,
        inLanguage: "en-PK",
        author: { "@type": "Person", name: article.authorName },
        publisher: {
          "@type": "Organization",
          name: "RELCO Wheels",
          url: SITE,
        },
        mainEntityOfPage: { "@type": "WebPage", "@id": `${SITE}/blog/${article.slug}` },
        image: article.coverPath ? `${SITE}${article.coverPath}` : undefined,
        keywords: article.tags.join(", "),
        wordCount: article.bodyHtml.replace(/<[^>]+>/g, " ").split(/\s+/).filter(Boolean).length,
      },
      {
        "@type": "BreadcrumbList",
        itemListElement: [
          { "@type": "ListItem", position: 1, name: "Home", item: SITE },
          { "@type": "ListItem", position: 2, name: "Guides", item: `${SITE}/blog` },
          { "@type": "ListItem", position: 3, name: article.title, item: `${SITE}/blog/${article.slug}` },
        ],
      },
    ],
  };

  return (
    <div className="wrap-x py-10">
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />

      <nav aria-label="Breadcrumb" className="text-sm text-sold">
        <Link href="/" className="hover:text-brand">Home</Link>
        <span className="mx-2">/</span>
        <Link href="/blog" className="hover:text-brand">Guides</Link>
        <span className="mx-2">/</span>
        <span className="text-heading">{article.tags[0]}</span>
      </nav>

      <article className="mt-5 max-w-[72ch]">
        <p className="data text-xs uppercase tracking-[0.1em] text-brand">{article.tags.join(" / ")}</p>
        <h1 className="mt-3 text-3xl leading-tight md:text-4xl">{article.title}</h1>
        <p className="mt-4 text-lg text-body">{article.dek}</p>

        <p className="data mt-5 border-y border-border py-3 text-xs text-sold">
          {article.authorName}
          {article.isGuest && " (guest)"}
          <span className="mx-2">/</span>
          {article.publishedAt ? when(article.publishedAt) : ""}
          <span className="mx-2">/</span>
          {article.readingMinutes} min read
        </p>

        {article.coverPath && (
          <div className="mt-6 border border-border bg-bg-alt">
            <Image
              src={article.coverPath}
              alt=""
              width={1200}
              height={900}
              className="h-auto w-full"
              sizes="(max-width: 1024px) 100vw, 720px"
              priority
            />
          </div>
        )}

        {/* Body is authored by a person or a guest, then sanitised on the way out. See src/lib/render.ts. */}
        <div
          className="prose-relco mt-8 space-y-4 text-base leading-relaxed [&_h2]:mt-8 [&_h2]:text-xl [&_h2]:font-semibold [&_h2]:text-heading [&_p]:text-body"
          dangerouslySetInnerHTML={{ __html: renderBody(article.bodyHtml) }}
        />

        <div className="mt-10 border border-border bg-bg-alt p-6">
          <h2 className="text-base">{article.authorName}</h2>
          <p className="mt-1 text-sm text-sold">
            {article.authorHandle === "relco_editors" ? "Written by the RELCO Wheels desk." : "Writes here and on the forum."}
          </p>
          {article.authorHandle !== "relco_editors" && (
            <Link href={`/forum/u/${article.authorHandle}`} className="mt-2 inline-block text-sm text-brand underline">
              Their posts and listings
            </Link>
          )}
        </div>
      </article>

      {related.length > 0 && (
        <section className="mt-14 border-t border-border pt-8">
          <h2 className="text-xl">More guides</h2>
          <ul className="mt-5 grid gap-x-10 gap-y-6 md:grid-cols-3">
            {related.map((a) => (
              <li key={a.id} className="border-b border-border pb-4">
                <h3 className="text-base leading-snug">
                  <Link href={`/blog/${a.slug}`} className="text-heading hover:text-brand">
                    {a.title}
                  </Link>
                </h3>
                <p className="data mt-2 text-xs text-sold">{a.readingMinutes} min read</p>
              </li>
            ))}
          </ul>
        </section>
      )}
    </div>
  );
}
