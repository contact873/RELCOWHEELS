import Link from "next/link";
import { notFound } from "next/navigation";
import { getCategory, seedCategories, threadsInCategory } from "@/lib/queries";
import { excerpt } from "@/lib/render";
import { when } from "@/lib/format";

type Params = Promise<{ category: string }>;

export function generateStaticParams() {
  return seedCategories.map((c) => ({ category: c.slug }));
}

export async function generateMetadata({ params }: { params: Params }) {
  const { category } = await params;
  const cat = getCategory(category);
  if (!cat) return { title: "Category not found" };
  return {
    title: `${cat.name} forum`,
    description: cat.description,
    alternates: { canonical: `/forum/${cat.slug}` },
  };
}

export default async function CategoryPage({ params }: { params: Params }) {
  const { category } = await params;
  const cat = getCategory(category);
  if (!cat) notFound();

  const threads = threadsInCategory(cat.slug);

  return (
    <div className="wrap-x py-10">
      <nav aria-label="Breadcrumb" className="text-sm text-sold">
        <Link href="/" className="hover:text-brand">Home</Link>
        <span className="mx-2">/</span>
        <Link href="/forum" className="hover:text-brand">Forum</Link>
        <span className="mx-2">/</span>
        <span className="text-heading">{cat.name}</span>
      </nav>

      <div className="mt-4 flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="text-3xl md:text-4xl">{cat.name}</h1>
          <p className="mt-3 max-w-[64ch] text-body">{cat.description}</p>
        </div>
        <Link href={`/forum/new?category=${cat.slug}`} className="btn btn-primary">
          Start a thread
        </Link>
      </div>

      {threads.length === 0 ? (
        <div className="mt-10 border border-border bg-bg-alt p-8">
          <h2 className="text-lg">No threads here yet</h2>
          <p className="mt-2 max-w-[58ch] text-sm text-body">
            A forum is worth nothing until somebody asks the first question. If you have one, this is
            the cheapest place to put it.
          </p>
          <Link href={`/forum/new?category=${cat.slug}`} className="btn btn-primary mt-4">
            Ask the first question
          </Link>
        </div>
      ) : (
        <ul className="mt-10">
          {threads.map((t) => (
            <li key={t.id} className="border-b border-border py-5">
              <div className="flex flex-wrap items-baseline gap-2">
                {t.isPinned && <span className="badge">Pinned</span>}
                <Link href={`/forum/t/${t.slug}`} className="text-lg font-semibold text-heading hover:text-brand">
                  {t.title}
                </Link>
              </div>

              {/* Stripped to text then truncated. The previous version sliced the HTML string, which
                  can cut mid tag and leave an unclosed element on the page. */}
              <p className="mt-2 max-w-[74ch] text-sm text-body">{excerpt(t.bodyHtml, 240)}</p>

              <p className="data mt-3 text-xs text-sold">
                {t.authorName}
                {t.authorRole === "dealer" && " (dealer)"}
                <span className="mx-2">/</span>
                {t.replyCount} {t.replyCount === 1 ? "reply" : "replies"}
                <span className="mx-2">/</span>
                {when(t.lastReplyAt ?? t.createdAt)}
              </p>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
