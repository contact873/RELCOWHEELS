/**
 * The stand-in for a photograph that does not exist yet.
 *
 * Rewritten for the bright identity, because the old version was honest and looked broken. It said
 * "Photograph pending" in a small grey line inside a dashed box, which is correct and reads as a
 * site that failed to load.
 *
 * This is still not a stock photograph. A picture of a different car on a listing is a lie, and a
 * grey rectangle reads as a bug. What is here is a composed panel: a car in outline, drawn rather
 * than photographed, carrying the reference number. It reads as a deliberate diagram, which is what
 * it is, and it keeps the grid's proportions honest while there is no photography to judge them
 * against.
 *
 * When real photographs arrive these disappear on their own, because the components that use them
 * only reach for one when the listing has none.
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
      className={`flex aspect-[4/3] w-full flex-col items-center justify-center gap-3 border border-border bg-bg-subtle px-4 text-center ${className}`}
    >
      <svg
        width="78"
        height="42"
        viewBox="0 0 74 40"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.6"
        strokeLinecap="round"
        strokeLinejoin="round"
        className="text-brand opacity-40"
        aria-hidden="true"
      >
        {/* A side profile, drawn rather than shot. Deliberately a diagram: nobody mistakes an
            outline for evidence about a particular car. */}
        <path d="M3 27h68" />
        <path d="M8 27v-5.5a3 3 0 0 1 1.6-2.6l9-4.6 6.4-6.1A4 4 0 0 1 28 7h17a4 4 0 0 1 3 1.3L55 15l10.4 3.2A3 3 0 0 1 67.5 21V27" />
        <path d="M24 8.5h22" />
        <circle cx="19" cy="27" r="4.6" />
        <circle cx="55" cy="27" r="4.6" />
      </svg>

      <span className="text-[11px] font-semibold uppercase tracking-[0.14em] text-sold">
        {label}
      </span>
      <span className="data text-[11px] text-sold opacity-80">{reference}</span>
    </div>
  );
}
