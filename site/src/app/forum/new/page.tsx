import Link from "next/link";
import { seedCategories } from "@/lib/queries";
import { getListing } from "@/lib/queries";

type SearchParams = Promise<{ [key: string]: string | string[] | undefined }>;

function one(v: string | string[] | undefined) {
  return Array.isArray(v) ? v[0] : v;
}

export const metadata = {
  title: "Start a thread",
  description: "Ask about a car in public. The answer stays where the next buyer can find it.",
  alternates: { canonical: "/forum/new" },
  robots: { index: false, follow: true },
};

export default async function NewThread({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const category = one(sp.category);
  const listingSlug = one(sp.listing);
  const listing = listingSlug ? getListing(listingSlug) : null;

  return (
    <div className="wrap-x py-10">
      <nav aria-label="Breadcrumb" className="text-sm text-sold">
        <Link href="/" className="hover:text-brand">Home</Link>
        <span className="mx-2">/</span>
        <Link href="/forum" className="hover:text-brand">Forum</Link>
        <span className="mx-2">/</span>
        <span className="text-heading">New thread</span>
      </nav>

      <div className="mt-5 max-w-[72ch]">
        <h1 className="text-3xl md:text-4xl">Start a thread</h1>
        <p className="mt-3 text-body">
          Ask in public. A question answered in a thread helps everybody who arrives after you, which a
          private message does not.
        </p>

        {listing && (
          <div className="mt-6 border border-border bg-bg-alt p-4">
            <p className="text-xs uppercase tracking-[0.1em] text-sold">Asking about</p>
            <p className="mt-1 text-base font-semibold text-heading">{listing.title}</p>
            <p className="data mt-1 text-xs text-sold">Reference {listing.reference}</p>
          </div>
        )}

        <form className="mt-8 grid gap-4">
          <div className="grid gap-1.5">
            <label htmlFor="t-category" className="text-xs uppercase tracking-[0.08em] text-sold">Category</label>
            <select
              id="t-category"
              name="category"
              defaultValue={category ?? "buying-advice"}
              className="w-full border border-border bg-bg-alt px-3 py-2.5 text-sm text-heading"
            >
              {seedCategories.map((c) => (
                <option key={c.slug} value={c.slug}>{c.name}</option>
              ))}
            </select>
          </div>

          <div className="grid gap-1.5">
            <label htmlFor="t-kind" className="text-xs uppercase tracking-[0.08em] text-sold">Type</label>
            <select id="t-kind" name="kind" defaultValue="question" className="w-full border border-border bg-bg-alt px-3 py-2.5 text-sm text-heading">
              <option value="question">Question, one accepted answer</option>
              <option value="discussion">Discussion</option>
            </select>
          </div>

          <div className="grid gap-1.5">
            <label htmlFor="t-title" className="text-xs uppercase tracking-[0.08em] text-sold">Title</label>
            <input
              id="t-title"
              name="title"
              placeholder="Alto VXL 2019 at 23.45 lakh, is that fair for Johar Town?"
              className="w-full border border-border bg-bg-alt px-3 py-2.5 text-sm text-heading placeholder:text-sold focus:border-brand focus:outline-none"
            />
            <p className="text-xs text-sold">Say the car and the question. A vague title gets no answers.</p>
          </div>

          <div className="grid gap-1.5">
            <label htmlFor="t-body" className="text-xs uppercase tracking-[0.08em] text-sold">Your question</label>
            <textarea
              id="t-body"
              name="body"
              rows={8}
              placeholder="What you have seen, what you are being asked, and what you are unsure about."
              className="w-full border border-border bg-bg-alt px-3 py-2.5 text-sm text-heading placeholder:text-sold focus:border-brand focus:outline-none"
            />
          </div>

          <div>
            <p className="text-xs text-sold">
              A first post is held for review, usually for a few hours. Everything you post after that
              publishes immediately. Links are not permitted in a first post.
            </p>
            <button type="submit" className="btn btn-primary mt-4" disabled>
              Post the thread
            </button>
            <p className="mt-3 text-xs text-sold">
              Posting is disabled while the site runs on sample content. The flow is built and needs the
              database connected.
            </p>
          </div>
        </form>
      </div>
    </div>
  );
}
