import Link from "next/link";
import { notFound } from "next/navigation";
import { ShowcaseCard } from "@/components/showcase-card";
import { browseCars } from "@/lib/queries";
import { differingRows, getModelSheet, MODELS_WITH_SHEETS } from "@/lib/model-specs";
import { pkr } from "@/lib/format";

/**
 * A model page.
 *
 * The shape is taken from suzukipakistan.com, which does the one thing a buyer actually needs and
 * most classifieds do not: it puts the variants side by side so the difference between them is
 * visible rather than inferred. Everything on that page is reproduced from facts recorded in
 * src/lib/model-specs.ts, with the manufacturer's photographs, brochure and wording left alone.
 *
 * What is deliberately added, and is not on their site: the price difference between the cheapest and
 * dearest variant, stated as a number next to the one row that differs. A buyer should not have to do
 * that subtraction across a four column table.
 */

type Params = Promise<{ make: string; model: string }>;

export function generateStaticParams() {
  // Keys must match the dynamic segments, which are [make] and [model]. Returning makeSlug and
  // modelSlug produced no prerendered page at all and the page count silently stayed the same.
  return MODELS_WITH_SHEETS.map((s) => ({ make: s.makeSlug, model: s.modelSlug }));
}

export async function generateMetadata({ params }: { params: Params }) {
  const { make, model } = await params;
  const sheet = getModelSheet(make, model);
  if (!sheet) return {};

  return {
    title: `${sheet.make} ${sheet.model} specifications and variants`,
    description: `${sheet.make} ${sheet.model} variants compared on equipment, with the published specifications and the ${sheet.model} cars listed for sale.`,
    alternates: { canonical: `/cars/${sheet.makeSlug}/${sheet.modelSlug}` },
  };
}

export default async function ModelPage({ params }: { params: Params }) {
  const { make, model } = await params;
  const sheet = getModelSheet(make, model);
  if (!sheet) notFound();

  const { listings, total } = browseCars({ make: sheet.makeSlug });
  const ofModel = listings.filter((l) => l.modelSlug === sheet.modelSlug);

  const prices = ofModel.map((l) => l.pricePkr).filter((p): p is number => p !== null);
  const low = prices.length ? Math.min(...prices) : null;
  const high = prices.length ? Math.max(...prices) : null;

  const newPrices = Object.values(sheet.newPricesPkr);
  const spread = newPrices.length ? Math.max(...newPrices) - Math.min(...newPrices) : 0;
  const differences = differingRows(sheet);

  return (
    <div className="wrap-x py-10">
      <nav aria-label="Breadcrumb" className="text-sm text-sold">
        <Link href="/" className="hover:text-brand">
          Home
        </Link>
        <span className="mx-2">/</span>
        <Link href="/cars" className="hover:text-brand">
          Cars
        </Link>
        <span className="mx-2">/</span>
        <Link href={`/cars?make=${sheet.makeSlug}`} className="hover:text-brand">
          {sheet.make}
        </Link>
        <span className="mx-2">/</span>
        <span className="text-heading">{sheet.model}</span>
      </nav>

      <header className="mt-5 border-b border-border pb-8">
        <h1 className="text-3xl md:text-4xl">
          {sheet.make} {sheet.model}
        </h1>
        <p className="mt-3 max-w-[62ch] text-body">
          What the variants actually differ in, the published specifications, and every{" "}
          {sheet.model} listed here with its price and condition.
        </p>

        <dl className="mt-5 flex flex-wrap gap-x-8 gap-y-3 text-sm">
          <div className="flex gap-2">
            <dt className="text-sold">Listed now</dt>
            <dd className="data m-0 text-heading">{ofModel.length}</dd>
          </div>
          {low !== null && (
            <div className="flex gap-2">
              <dt className="text-sold">Asking</dt>
              <dd className="data m-0 text-heading">
                {pkr(low)} to {pkr(high)}
              </dd>
            </div>
          )}
        </dl>
      </header>

      {/* The section that earns the page. */}
      <section className="py-12">
        <h2 className="text-2xl md:text-3xl">What the variants differ in</h2>
        <p className="mt-3 max-w-[64ch] text-body">
          Across the {sheet.columns.length} variants on the published sheet, only{" "}
          {differences.length === 1 ? "one line" : `${differences.length} lines`} actually changes.
          The dearest variant costs {pkr(spread)} more than the cheapest.
        </p>

        <div
          className="mt-6 overflow-x-auto"
          role="region"
          aria-label="Variant differences"
          tabIndex={0}
        >
          <table className="w-full min-w-[34rem] text-sm">
            <thead>
              <tr className="border-b border-border text-left">
                <th className="py-2 pr-4 font-semibold text-heading">What changes</th>
                {sheet.columns.map((c) => (
                  <th key={c} className="py-2 pr-4 text-right font-semibold text-heading">
                    {c}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {differences.map((row) => (
                <tr key={row.feature} className="border-b border-border">
                  <td className="py-2 pr-4 text-body">{row.feature}</td>
                  {row.values.map((v, i) => (
                    <td key={`${row.feature}-${i}`} className="data py-2 pr-4 text-right text-heading">
                      {typeof v === "boolean" ? (v ? "Yes" : "No") : v}
                    </td>
                  ))}
                </tr>
              ))}
              <tr>
                <td className="py-3 pr-4 font-semibold text-heading">List price</td>
                {sheet.columns.map((c) => (
                  <td key={c} className="data py-3 pr-4 text-right text-heading">
                    {pkr(sheet.newPricesPkr[c] ?? null)}
                  </td>
                ))}
              </tr>
            </tbody>
          </table>
        </div>

        <p className="mt-3 text-xs text-sold">
          New list prices, as published by the manufacturer on {sheet.asOf}. They are context for the
          used market, not a quote.
        </p>
      </section>

      {/* The full sheet, for anyone who wants it. */}
      <section className="border-t border-border py-12">
        <h2 className="text-2xl md:text-3xl">The full comparison</h2>
        <p className="mt-3 max-w-[64ch] text-body">
          Everything the published sheet lists, so the one difference above can be checked rather than
          taken on trust.
        </p>

        <div className="mt-6 overflow-x-auto" role="region" aria-label="Full variant comparison" tabIndex={0}>
          <table className="w-full min-w-[40rem] text-sm">
            <thead>
              <tr className="border-b border-border text-left">
                <th className="py-2 pr-4 font-semibold text-heading">Feature</th>
                {sheet.columns.map((c) => (
                  <th key={c} className="py-2 pr-4 text-right font-semibold text-heading">
                    {c.replace(`${sheet.make} `, "")}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {sheet.comparison.map((row) => (
                <tr key={`${row.group}-${row.feature}`} className="border-b border-border">
                  <td className="py-2 pr-4 text-body">
                    <span className="text-sold">{row.group}</span>
                    <span className="mx-2">/</span>
                    {row.feature}
                  </td>
                  {row.values.map((v, i) => (
                    <td key={`${row.feature}-${i}`} className="py-2 pr-4 text-right text-heading">
                      {typeof v === "boolean" ? (v ? "Yes" : "No") : <span className="data">{v}</span>}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      {/* Specifications, grouped, from the published sheet. */}
      <section className="border-t border-border py-12">
        <h2 className="text-2xl md:text-3xl">Specifications</h2>
        <div className="mt-7 grid gap-10 md:grid-cols-2">
          {sheet.specs.map((group) => (
            <div key={group.group}>
              <h3 className="text-base">{group.group}</h3>
              <dl className="mt-3">
                {group.rows.map((row) => (
                  <div
                    key={row.label}
                    className="flex items-baseline justify-between gap-4 border-b border-border py-2 text-sm"
                  >
                    <dt className="text-sold">{row.label}</dt>
                    <dd className="data m-0 text-right text-heading">{row.value}</dd>
                  </div>
                ))}
              </dl>
            </div>
          ))}
        </div>
        <p className="mt-6 text-xs text-sold">
          Manufacturer figures, read on {sheet.asOf} from {sheet.source}. These describe the car as it
          left the factory. They are not an inspection, and they do not tell you anything about the
          condition of a particular used car.
        </p>
      </section>

      {/* The actual stock, which is the point of a marketplace. */}
      <section className="border-t border-border py-12">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <h2 className="text-2xl md:text-3xl">{sheet.model} cars listed here</h2>
          <Link
            href={`/cars?make=${sheet.makeSlug}`}
            className="text-sm font-semibold text-brand hover:underline"
          >
            All {sheet.make} ({total})
          </Link>
        </div>

        {ofModel.length > 0 ? (
          <div className="mt-7 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {ofModel.map((listing) => (
              <ShowcaseCard key={listing.id} listing={listing} />
            ))}
          </div>
        ) : (
          <div className="mt-7 border border-border bg-bg-subtle p-8">
            <h3 className="text-base">Nothing listed right now</h3>
            <p className="mt-2 max-w-[58ch] text-sm text-body">
              Nobody is selling a {sheet.model} here today. The specifications above still apply, but a
              price only means something when there is a car behind it.
            </p>
          </div>
        )}
      </section>
    </div>
  );
}
