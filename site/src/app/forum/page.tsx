import Link from "next/link";
import { seedCategories, seedThreads } from "@/lib/queries";
import { when } from "@/lib/format";

export const metadata = {
  title: "Forum: ask before you buy",
  description:
    "Post a listing and ask about it in public. Auction grades, landed cost, paperwork, and what a car is really worth, answered by people who deal in them.",
  alternates: { canonical: "/forum" },
};

export default function ForumIndex() {
  const recent = [...seedThreads].sort(
    (a, b) => new Date(b.lastReplyAt ?? b.createdAt).getTime() - new Date(a.lastReplyAt ?? a.createdAt).getTime(),
  );

  return (
    <div className="wrap-x py-10">
      <nav aria-label="Breadcrumb" className="text-sm text-sold">
        <Link href="/" className="hover:text-brand">Home</Link>
        <span className="mx-2">/</span>
        <span className="text-heading">Forum</span>
      </nav>

      <div className="mt-4 flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="text-3xl md:text-4xl">Ask before you buy</h1>
          <p className="mt-3 max-w-[64ch] text-body">
            Ask about a car in public and the answer stays where the next buyer can find it. Selling
            is welcome. Advertising is not.
          </p>
        </div>
        <Link href="/forum/new" className="btn btn-primary">
          Start a thread
        </Link>
      </div>

      <div className="mt-10 grid gap-12 lg:grid-cols-[1.1fr_0.9fr]">
        <section>
          <h2 className="text-lg">Categories</h2>
          <ul className="mt-4">
            {seedCategories.map((c) => (
              <li key={c.id} className="border-b border-border py-4">
                <div className="flex items-baseline justify-between gap-4">
                  <Link href={`/forum/${c.slug}`} className="text-base font-semibold text-heading hover:text-brand">
                    {c.name}
                  </Link>
                  <span className="data shrink-0 text-xs text-sold">{c.threadCount} threads</span>
                </div>
                <p className="mt-1 max-w-[62ch] text-sm text-sold">{c.description}</p>
              </li>
            ))}
          </ul>
        </section>

        <section>
          <h2 className="text-lg">Latest</h2>
          <ul className="mt-4 space-y-5">
            {recent.map((t) => (
              <li key={t.id} className="border-b border-border pb-4">
                <Link href={`/forum/t/${t.slug}`} className="text-base font-semibold text-heading hover:text-brand">
                  {t.title}
                </Link>
                <p className="data mt-2 text-xs text-sold">
                  {t.categoryName}
                  <span className="mx-2">/</span>
                  {t.replyCount} {t.replyCount === 1 ? "reply" : "replies"}
                  <span className="mx-2">/</span>
                  {when(t.lastReplyAt ?? t.createdAt)}
                </p>
              </li>
            ))}
          </ul>
        </section>
      </div>
    </div>
  );
}
