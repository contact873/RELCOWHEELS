import { CONDITION_PARTS } from "@/lib/condition";
import type { Listing } from "@/lib/types";

/**
 * A condition report, rendered from a real listing.
 *
 * This is the hero visual, and it is deliberately not a photograph of a car. Two reasons.
 *
 * The first is craft. The product here is not cars, it is knowing what you are buying, and a hero
 * that shows the actual document is doing what a stock photograph of a bonnet cannot.
 *
 * The second is honesty. We hold no verified photographs of the cars in this catalogue, so any car
 * photograph in the hero would be a picture of something else dressed up as evidence. A report
 * built from the listing's own score fields cannot mislead, because every number on it comes from
 * the listing it names.
 */
export function ConditionPanel({ listing }: { listing: Listing }) {
  const report = listing.inspection;
  if (!report) return null;

  // Nullable on purpose, and a null is never rendered as a zero. A part that was not scored would
  // otherwise read as a part that scored nothing, which on a condition report is the difference
  // between an unknown and a write off.
  const scores: Record<string, number | null> = {
    exterior: report.exterior,
    engine: report.engine,
    suspension: report.suspension,
    interior: report.interior,
    ac: report.ac,
  };

  const unscored = "Not scored";

  return (
    <div className="border border-border bg-bg-alt">
      <div className="flex items-center justify-between gap-3 border-b border-border px-5 py-3">
        <p className="eyebrow">Condition report</p>
        <p className="data text-[11px] text-sold">{listing.reference}</p>
      </div>

      <div className="px-5 py-5">
        <p className="data text-xs text-sold">
          {listing.modelYear} {listing.makeName} {listing.modelName}
        </p>
        <p className="mt-1 text-sm text-heading">{listing.variantName}</p>

        <div className="mt-5 flex items-end justify-between gap-3 border-b border-border pb-4">
          <span className="text-sm text-sold">Overall</span>
          <span className="price text-3xl leading-none">
            {report.overallScore === null ? (
              <span className="text-base font-normal text-sold">{unscored}</span>
            ) : (
              <>
                {report.overallScore.toFixed(1)}
                <span className="ml-1 text-sm font-normal text-sold">/ 10</span>
              </>
            )}
          </span>
        </div>

        <dl className="mt-4 space-y-3.5">
          {CONDITION_PARTS.map((part) => {
            const value = scores[part.key] ?? null;
            return (
              <div key={part.key}>
                <div className="flex items-baseline justify-between gap-3">
                  <dt className="text-xs text-sold">{part.label}</dt>
                  <dd className="data m-0 text-xs text-heading">
                    {value === null ? unscored : value}
                  </dd>
                </div>
                <div className="mt-1.5 h-1 w-full bg-bg-subtle" role="presentation">
                  {value !== null && (
                    <div
                      className="h-1 bg-brand"
                      style={{ width: `${Math.max(0, Math.min(100, value))}%` }}
                    />
                  )}
                </div>
              </div>
            );
          })}
        </dl>
      </div>

      <p className="border-t border-border px-5 py-3 text-xs text-sold">
        Inspected {report.inspectedOn}. The full sheet stays on the listing, including after the car
        sells.
      </p>
    </div>
  );
}
