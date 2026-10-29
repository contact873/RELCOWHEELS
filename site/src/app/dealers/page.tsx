import Link from "next/link";
import { PROSPECTS, isIndexable } from "@/lib/prospects";

/**
 * The index of dealer pages.
 *
 * Not linked from anywhere on the site and not in the sitemap: while any of these is an unapproved
 * preview carrying a real company's name, this page is an internal tool rather than a page of the
 * marketplace. Reach it by typing the address.
 *
 * It exists so there is one place to look when a page needs adding, checking or deleting, rather
 * than remembering a URL per prospect.
 */

export const metadata = {
  title: "Dealer pages",
  description: "Previews built for prospective dealerships. Not part of the public site.",
  robots: { index: false, follow: false },
};

const STATUS_LABEL: Record<string, string> = {
  sample: "Sample",
  preview: "Preview, not authorised",
  live: "Live and authorised",
};

export default function DealersPage() {
  return (
    <div className="wrap-x py-10">
      <nav aria-label="Breadcrumb" className="text-sm text-sold">
        <Link href="/" className="hover:text-brand">
          Home
        </Link>
        <span className="mx-2">/</span>
        <span className="text-heading">Dealers</span>
      </nav>

      <div className="mt-5 max-w-[70ch]">
        <h1 className="text-3xl md:text-4xl">Dealer pages</h1>

        <p className="mt-4 text-body">
          One page per dealership, built to be sent to them rather than found by them. Everything in
          this section is kept out of search results, and none of it is linked from the public site,
          until a dealership has authorised us in writing.
        </p>

        <ul className="mt-8">
          {PROSPECTS.map((prospect) => (
            <li key={prospect.slug} className="border-b border-border py-5">
              <div className="flex flex-wrap items-baseline justify-between gap-3">
                <Link
                  href={`/dealers/${prospect.slug}`}
                  className="text-lg font-semibold text-heading hover:text-brand"
                >
                  {prospect.name}
                </Link>
                <span
                  className={`data text-[11px] uppercase tracking-[0.08em] ${
                    isIndexable(prospect) ? "text-brand" : "text-sold"
                  }`}
                >
                  {STATUS_LABEL[prospect.status] ?? prospect.status}
                </span>
              </div>

              <p className="data mt-2 text-xs text-sold">
                {prospect.city}
                <span className="mx-2">/</span>
                {prospect.handle ? "we hold stock for them" : "we hold no stock for them"}
                {prospect.stockCount !== null && (
                  <>
                    <span className="mx-2">/</span>
                    {prospect.stockCount} cars, per their own site
                  </>
                )}
              </p>

              <ul className="mt-3 space-y-1 text-sm text-sold">
                {prospect.notes.map((note) => (
                  <li key={note}>{note}</li>
                ))}
              </ul>
            </li>
          ))}
        </ul>

        <p className="mt-8 text-sm text-sold">
          To add one, add an entry to <span className="data">src/lib/prospects.ts</span>. Leave the
          phone, the address and the stock count empty unless the dealership gave them to you; the
          page hides what it does not have rather than filling the gap.
        </p>
      </div>
    </div>
  );
}
