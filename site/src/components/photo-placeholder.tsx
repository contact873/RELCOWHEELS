/**
 * The stand-in for a photograph that does not exist yet.
 *
 * Deliberately not a stock photograph and deliberately not a coloured rectangle. A grey box reads
 * as a broken image; a stock photo of something that is not a car reads as a lie. A ruled panel
 * carrying the reference number reads as what it is, a listing waiting for its pictures, and it
 * keeps the grid's proportions honest so the layout is not being validated against content that
 * will never exist.
 *
 * When real stock arrives, these disappear on their own.
 */
export function PhotoPlaceholder({
  reference,
  label = "Photograph pending",
  className = "",
}: {
  reference: string;
  label?: string;
  className?: string;
}) {
  return (
    <div
      role="img"
      aria-label={`${label}. No photograph supplied for listing ${reference}.`}
      className={`flex aspect-[4/3] w-full flex-col items-center justify-center gap-2 border border-dashed border-border bg-bg-subtle px-4 text-center ${className}`}
    >
      <svg
        width="34"
        height="34"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.5"
        className="text-sold"
        aria-hidden="true"
      >
        <rect x="3" y="5" width="18" height="14" rx="1" />
        <circle cx="9" cy="10.5" r="1.6" />
        <path d="M4 17l4.6-4.6a1.4 1.4 0 0 1 2 0L15 17" />
        <path d="M14.5 15.5l2-2a1.4 1.4 0 0 1 2 0l1.5 1.5" />
      </svg>
      <span className="text-xs text-sold">{label}</span>
      <span className="data text-[11px] text-sold">{reference}</span>
    </div>
  );
}
