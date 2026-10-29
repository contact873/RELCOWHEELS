"use client";

import Link from "next/link";
import { CONTACT, displayPhone, hasContact, hasEmail, hasPhone, telHref } from "@/lib/contact";

/**
 * The footer.
 *
 * Fixed in this pass: every link here used to 404. The four /cars/... paths were written as if
 * this site had nested routes under /cars, which it does not, because browsing is done with query
 * parameters on a single page. /account/listings and /dealers pointed at pages nobody has built.
 * Six dead links in the footer of a live site is the sort of thing that makes a whole project look
 * unfinished, so they now point at addresses that resolve.
 */

const COLUMNS = [
  {
    heading: "Buy",
    links: [
      { href: "/cars", label: "All cars" },
      { href: "/cars?body=sedan", label: "Sedans" },
      { href: "/cars?body=suv", label: "SUVs" },
      { href: "/cars?body=hatchback", label: "Hatchbacks" },
      { href: "/cars?city=lahore", label: "In Lahore" },
      { href: "/cars?budget=under-20-lakh", label: "Under 20 lakh" },
      { href: "/cars?transmission=automatic", label: "Automatic" },
    ],
  },
  {
    heading: "Sell",
    links: [
      { href: "/sell", label: "Post an ad" },
      { href: "/find-my-car", label: "Find my car" },
      { href: "/auth/sign-in", label: "Sign in" },
      { href: "/safety", label: "Staying safe" },
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
  const columns = hasContact()
    ? [...COLUMNS, { heading: "Contact", links: [] as { href: string; label: string }[] }]
    : COLUMNS;

  return (
    <footer data-surface="ink" className="mt-16 bg-bg text-body">
      <div className="wrap-x py-12">
        <div className={`grid gap-10 md:grid-cols-2 ${hasContact() ? "lg:grid-cols-5" : "lg:grid-cols-4"}`}>
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

          {columns.map((col) => (
            <div key={col.heading}>
              <h3 className="text-[11px] font-semibold uppercase tracking-[0.2em] text-heading">
                {col.heading}
              </h3>

              {col.heading === "Contact" ? (
                <ul className="mt-4 space-y-2 text-sm">
                  {CONTACT.addressLines.map((line) => (
                    <li key={line}>{line}</li>
                  ))}
                  {hasPhone() && (
                    <li>
                      <a href={telHref(CONTACT.phone)} className="data hover:text-brand">
                        {displayPhone(CONTACT.phone)}
                      </a>
                    </li>
                  )}
                  {hasEmail() && (
                    <li>
                      <a href={`mailto:${CONTACT.email}`} className="hover:text-brand">
                        {CONTACT.email}
                      </a>
                    </li>
                  )}
                </ul>
              ) : (
                <ul className="mt-4 space-y-2 text-sm">
                  {col.links.map((l) => (
                    <li key={l.href}>
                      <Link href={l.href} className="hover:text-brand">
                        {l.label}
                      </Link>
                    </li>
                  ))}
                </ul>
              )}
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
