import Link from "next/link";

const NAV = [
  { href: "/cars", label: "Buy" },
  { href: "/sell", label: "Sell" },
  { href: "/forum", label: "Forum" },
  { href: "/blog", label: "Guides" },
];

/**
 * The mark is carried over unchanged from relco-digital-brand, orange node included, because
 * that node is the one element every RELCO property shares. Everything around it is unique to
 * this property.
 */
function Mark({ size = 30 }: { size?: number }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 64 64"
      aria-hidden="true"
      className="shrink-0"
      fill="none"
      stroke="currentColor"
      strokeWidth="5.5"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <g transform="translate(0.1, -0.4)">
        <path d="M22 46 V18" />
        <path d="M22 18 H33 a7.5 7.5 0 0 1 0 15 H22" />
        <path d="M29 33.5 L41 45.5" />
      </g>
      {/* the family signature: this node is the same orange on every RELCO property */}
      <circle cx="40" cy="45" r="4.6" fill="#C9541F" stroke="none" />
    </svg>
  );
}

export function SiteHeader() {
  return (
    <header className="sticky top-0 z-30 border-b border-border bg-bg-alt">
      <div className="wrap-x flex h-16 items-center justify-between gap-6">
        <Link href="/" className="flex items-center gap-2.5 text-heading">
          <Mark />
          <span className="leading-none">
            <span className="block text-[15px] font-bold tracking-tight" data-display>
              RELCO
            </span>
            <span className="mt-0.5 block text-[9px] font-semibold uppercase tracking-[0.28em] text-brand">
              Wheels
            </span>
          </span>
        </Link>

        <nav aria-label="Main" className="hidden items-center gap-6 md:flex">
          {NAV.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="text-[13px] font-semibold uppercase tracking-[0.08em] text-body hover:text-brand"
            >
              {item.label}
            </Link>
          ))}
        </nav>

        <div className="flex items-center gap-2">
          <Link href="/auth/sign-in" className="btn btn-ghost hidden sm:inline-flex">
            Sign in
          </Link>
          <Link href="/sell" className="btn btn-primary">
            Post an ad
          </Link>
        </div>
      </div>
    </header>
  );
}

export { Mark };
