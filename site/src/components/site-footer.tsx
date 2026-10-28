"use client";

import Link from "next/link";

const COLUMNS = [
  {
    heading: "Buy",
    links: [
      { href: "/cars", label: "All cars" },
      { href: "/cars/lahore", label: "In Lahore" },
      { href: "/cars/suzuki", label: "By make" },
      { href: "/cars/under-20-lakh", label: "Under 20 lakh" },
      { href: "/cars/automatic", label: "Automatic" },
    ],
  },
  {
    heading: "Sell",
    links: [
      { href: "/sell", label: "Post an ad" },
      { href: "/account/listings", label: "My ads" },
      { href: "/dealers", label: "Dealer accounts" },
      { href: "/find-my-car", label: "Find my car" },
    ],
  },
  {
    heading: "Community",
    links: [
      { href: "/forum", label: "Forum" },
      { href: "/forum/buying-advice", label: "Buying advice" },
      { href: "/forum/inspection", label: "Inspection and condition" },
      { href: "/blog", label: "Guides and articles" },
      { href: "/write", label: "Write for us" },
    ],
  },
];

export function SiteFooter() {
  return (
    <footer data-surface="ink" className="mt-16 bg-bg text-body">
      <div className="wrap-x py-12">
        <div className="grid gap-10 md:grid-cols-4">
          <div>
            <p className="text-[15px] font-bold tracking-tight text-heading" data-display>
              RELCO WHEELS
            </p>
            <p className="mt-3 max-w-[26ch] text-sm">
              Cars for sale in Pakistan with the price and the condition shown.
            </p>
            <p className="mt-4 text-sm" data-display>
              Know what you&rsquo;re buying.
            </p>
          </div>

          {COLUMNS.map((col) => (
            <div key={col.heading}>
              <h3 className="text-[11px] font-semibold uppercase tracking-[0.2em] text-heading">
                {col.heading}
              </h3>
              <ul className="mt-4 space-y-2 text-sm">
                {col.links.map((l) => (
                  <li key={l.href}>
                    <Link href={l.href} className="hover:text-brand">
                      {l.label}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        <div className="mt-10 flex flex-wrap items-center justify-between gap-4 border-t border-border pt-5 text-xs">
          <p>
            RELCO Wheels is a venue. We do not own the cars, hold any payment, or take part in any
            sale.{" "}
            <Link href="/safety" className="underline">
              Safety advice
            </Link>
          </p>
          <nav aria-label="Legal" className="flex flex-wrap gap-4">
            <Link href="/terms">Terms</Link>
            <Link href="/privacy">Privacy</Link>
            <Link href="/cookies">Cookies</Link>
            <button
              type="button"
              className="underline"
              onClick={() => window.dispatchEvent(new Event("relwheels:cookie-settings"))}
            >
              Cookie settings
            </button>
          </nav>
        </div>
      </div>
    </footer>
  );
}
