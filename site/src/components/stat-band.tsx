import { CATALOGUE_FACTS } from "@/lib/catalogue-facts";
import { CONDITION_PARTS } from "@/lib/condition";

/**
 * The numbers band.
 *
 * This is the section that replaces the reference site's "20 years of experience". Their trust
 * devices are unverifiable claims: a decade count, testimonials, a client wall. This one shows four
 * facts that a reader can check against the rest of the site, and it says which of them describe
 * the catalogue rather than the listings, because a count that quietly changes meaning is worse
 * than no count.
 *
 * No number here is typed into the markup. The three catalogue figures are generated, and the
 * fourth is the length of the list the condition panel renders.
 */
export function StatBand() {
  const items: { value: number; label: string }[] = [
    { value: CATALOGUE_FACTS.makes, label: "makes, each with a page of its own" },
    { value: CATALOGUE_FACTS.models, label: "models kept apart, not merged" },
    { value: CATALOGUE_FACTS.variants, label: "engine and trim combinations" },
    { value: CONDITION_PARTS.length, label: "parts scored on every condition report" },
  ];

  return (
    <section className="border-y border-border bg-subtle">
      <div className="wrap-x py-12">
        <p className="eyebrow">The catalogue</p>
        <h2 className="mt-3 max-w-[34ch] text-2xl md:text-3xl">
          Assembled as data, not assembled as a guess.
        </h2>
        <p className="mt-3 max-w-[62ch] text-body">
          Every make, model and variant is a row with an identifier, so a filter cannot return a car
          that does not exist and the same car cannot appear twice under two spellings of its own
          name.
        </p>

        <dl className="mt-9 grid gap-x-8 gap-y-7 sm:grid-cols-2 lg:grid-cols-4">
          {items.map((item) => (
            <div key={item.label} className="border-t border-border pt-4">
              <dd className="data m-0 text-3xl leading-none text-heading">{item.value}</dd>
              <dt className="mt-2 text-sm text-sold">{item.label}</dt>
            </div>
          ))}
        </dl>
      </div>
    </section>
  );
}
