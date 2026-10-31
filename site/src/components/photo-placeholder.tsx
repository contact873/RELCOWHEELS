/**
 * The stand-in for a photograph that does not exist yet.
 *
 * Rewritten twice. The first version said "Photograph pending" in small grey type inside a dashed box:
 * honest, and it read as a site that failed to load. The second drew one car in outline, which was
 * better but drew the same shape for a van, an SUV and a hatchback, so a grid of them still read as
 * "no pictures at all".
 *
 * This version draws the body type. A hatchback, a sedan, an SUV, a crossover and a van get visibly
 * different silhouettes, because the shape is real information about the car and it is the one thing a
 * photograph would have told you at a glance. It is still a diagram, not evidence: nothing here claims
 * to be the car for sale, and the reference number under it says which listing it belongs to.
 *
 * When real photographs arrive these disappear on their own, because the components that use them only
 * reach for one when the listing has none.
 */

type Body = "hatchback" | "sedan" | "suv" | "crossover" | "van";

/**
 * Silhouettes on a 74 x 40 grid. The differences are deliberate and exaggerated enough to survive a
 * 260px card: roof height, how the rear falls away, and how much nose there is ahead of the screen.
 */
const SILHOUETTES: Record<Body, string> = {
  // Short, steep rear. The most common shape in this market.
  hatchback:
    "M8 27v-5.5a3 3 0 0 1 1.6-2.6l9-4.6 6.4-6.1A4 4 0 0 1 28 7h16a4 4 0 0 1 3.2 1.6L53 15.5l9.6 3.4A3 3 0 0 1 64.5 22V27",
  // Three boxes: bonnet, cabin, boot. The boot is the difference.
  sedan:
    "M5 27v-4.4a3 3 0 0 1 1.4-2.5l9.6-4.6 6-6.4A4 4 0 0 1 25 7.4h18a4 4 0 0 1 3 1.4l8.6 9.4 8.4 2.4 2 3.8V27",
  // Tall and upright, with the high roofline carried almost to the tail.
  suv:
    "M7 27v-7.5a3 3 0 0 1 1.5-2.6l8.5-4.4 5.6-5.6A4 4 0 0 1 25.6 5.6h20a4 4 0 0 1 3 1.4l8 9.2 5.4 2.6a3 3 0 0 1 1.7 2.7V27",
  // Car platform with a raised body and a falling rear line.
  crossover:
    "M10 27v-6.2a3 3 0 0 1 1.5-2.6l8.4-4.3 6.2-6.3A4 4 0 0 1 29 6.2h15a4 4 0 0 1 3.1 1.5L54 15l8.8 3.8A3 3 0 0 1 64.8 21.6V27",
  // Long, flat roof, near vertical tail, short nose.
  van:
    "M12 27v-9a3 3 0 0 1 1.8-2.7L20 13l4.6-5.4A3.6 3.6 0 0 1 27.4 6h24a4 4 0 0 1 4 4v10.6l1.6 2.6a3 3 0 0 1 .5 1.7V27",
};

/** Wheel positions per shape, so the axles do not drift away from the body they sit under. */
const WHEELS: Record<Body, [number, number]> = {
  hatchback: [20, 54],
  sedan: [18, 56],
  suv: [21, 52],
  crossover: [20, 55],
  van: [24, 54],
};

export function PhotoPlaceholder({
  reference,
  label = "Photograph pending",
  body,
  className = "",
}: {
  reference: string;
  label?: string;
  /** The listing's body type. Chooses the silhouette; unknown or absent falls back to a hatchback. */
  body?: string | null;
  className?: string;
}) {
  const raw = String(body ?? "").toLowerCase();
  const shape: Body = raw in SILHOUETTES ? (raw as Body) : "hatchback";
  const [front, rear] = WHEELS[shape];

  return (
    <div
      role="img"
      aria-label={`${label}. No photograph supplied for listing ${reference}.`}
      className={`flex aspect-[4/3] w-full flex-col items-center justify-center gap-3 border border-border bg-bg-subtle px-4 text-center ${className}`}
    >
      <svg
        width="84"
        height="46"
        viewBox="0 0 74 40"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.6"
        strokeLinecap="round"
        strokeLinejoin="round"
        className="text-brand opacity-40"
        aria-hidden="true"
      >
        <path d="M3 27h68" />
        <path d={SILHOUETTES[shape]} />
        <circle cx={front} cy="27" r="4.6" />
        <circle cx={rear} cy="27" r="4.6" />
      </svg>

      <span className="text-[11px] font-semibold uppercase tracking-[0.14em] text-sold">
        {label}
      </span>
      <span className="data text-[11px] text-sold opacity-80">{reference}</span>
    </div>
  );
}
