import Link from "next/link";
import { ListingTile } from "@/components/listing-card";
import { browseCars, countByCity, countByMake, BODY_TYPES, BUDGET_BANDS } from "@/lib/queries";

type SearchParams = Promise<{ [key: string]: string | string[] | undefined }>;

function one(v: string | string[] | undefined): string | undefined {
  return Array.isArray(v) ? v[0] : v;
}

export async function generateMetadata({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const make = one(sp.make);
  const city = one(sp.city);
  const bits = [make, city].filter(Boolean).join(" in ");
  return {
    title: bits ? `Used ${bits}` : "Used cars for sale in Pakistan",
    description:
      "Every listing shows its asking price, mileage, engine capacity and condition result. Filter by make, city, body type and budget.",
    alternates: {
      canonical: `/cars${make ? `?make=${make}` : ""}${city ? `${make ? "&" : "?"}city=${city}` : ""}`,
    },
  };
}

const SORTS: { value: string; label: string }[] = [
  { value: "recent", label: "Most recent" },
  { value: "price-asc", label: "Price, low to high" },
  { value: "price-desc", label: "Price, high to low" },
  { value: "mileage-asc", label: "Mileage, lowest first" },
  { value: "year-desc", label: "Newest model year" },
];

export default async function CarsPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;

  const filters = {
    make: one(sp.make),
    city: one(sp.city),
    body: one(sp.body),
    budget: one(sp.budget),
    transmission: one(sp.transmission),
    fuel: one(sp.fuel),
    importOnly: one(sp.imported) === "1",
    q: one(sp.q),
    sort: (one(sp.sort) as "recent" | undefined) ?? "recent",
  };

  const { listings, total, applied } = browseCars(filters);
  const makes = countByMake();
  const cities = countByCity();

  // Build the query string for a facet link without losing the existing filters.
  const withParam = (key: string, value: string | undefined) => {
    const p = new URLSearchParams();
    for (const [k, v] of Object.entries(filters)) {
      if (v && k !== key && k !== "sort") p.set(k, String(v));
    }
    if (value) p.set(key, value);
    const s = p.toString();
    return `/cars${s ? `?${s}` : ""}`;
  };

  const active: { key: string; value: string; label: string }[] = [];
  if (filters.make) active.push({ key: "make", value: filters.make, label: makes.find((m) => m.slug === filters.make)?.name ?? filters.make });
  if (filters.city) active.push({ key: "city", value: filters.city, label: cities.find((c) => c.slug === filters.city)?.name ?? filters.city });
  if (filters.body) active.push({ key: "body", value: filters.body, label: filters.body });
  if (filters.budget) active.push({ key: "budget", value: filters.budget, label: BUDGET_BANDS.find((b) => b.slug === filters.budget)?.label ?? filters.budget });
  if (filters.transmission) active.push({ key: "transmission", value: filters.transmission, label: filters.transmission === "automatic" ? "Automatic" : "Manual" });
  if (filters.fuel) active.push({ key: "fuel", value: filters.fuel, label: filters.fuel });
  if (filters.importOnly) active.push({ key: "imported", value: "1", label: "Imported" });
  if (filters.q) active.push({ key: "q", value: filters.q, label: `"${filters.q}"` });

  return (
    <div className="wrap-x py-10">
      <nav aria-label="Breadcrumb" className="text-sm text-sold">
        <Link href="/" className="hover:text-brand">
          Home
        </Link>
        <span className="mx-2">/</span>
        <span className="text-heading">Cars</span>
      </nav>

      <div className="mt-4 flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="text-3xl md:text-4xl">
            {active.length ? "Cars matching your filters" : "Cars for sale"}
          </h1>
          <p className="data mt-2 text-sm text-sold">
            {listings.length} of {total} live listings
          </p>
        </div>

        <form action="/cars" method="get" className="flex items-end gap-2">
          {active
            .filter((a) => a.key !== "sort")
            .map((a) => (
              <input key={a.key} type="hidden" name={a.key} value={a.value} />
            ))}
          <div className="grid gap-1">
            <label htmlFor="sort" className="text-xs text-sold">
              Sort
            </label>
            <select
              id="sort"
              name="sort"
              defaultValue={filters.sort}
              className="border border-border bg-bg-alt px-3 py-2 text-sm text-heading"
            >
              {SORTS.map((s) => (
                <option key={s.value} value={s.value}>
                  {s.label}
                </option>
              ))}
            </select>
          </div>
          <button type="submit" className="btn btn-ghost">
            Apply
          </button>
        </form>
      </div>

      {active.length > 0 && (
        <ul className="mt-5 flex flex-wrap items-center gap-2">
          {active.map((a) => (
            <li key={a.key}>
              <Link
                href={withParam(a.key, undefined)}
                className="inline-flex items-center gap-2 border border-border bg-bg-alt px-3 py-1.5 text-sm text-heading hover:border-brand"
              >
                {a.label}
                <span aria-hidden="true" className="text-sold">
                  x
                </span>
                <span className="sr-only">Remove this filter</span>
              </Link>
            </li>
          ))}
          <li>
            <Link href="/cars" className="text-sm text-brand underline">
              Clear all
            </Link>
          </li>
        </ul>
      )}

      <div className="mt-8 grid gap-10 lg:grid-cols-[240px_1fr]">
        {/* Facets. Compact link lists with derived counts, no cards. */}
        <aside className="space-y-8">
          <div>
            <h2 className="text-sm font-semibold uppercase tracking-[0.12em] text-heading">Make</h2>
            <ul className="mt-3">
              {makes.map((m) => (
                <li key={m.slug} className="flex items-baseline justify-between border-b border-border py-1.5 text-sm">
                  <Link
                    href={withParam("make", m.slug === filters.make ? undefined : m.slug)}
                    className={m.slug === filters.make ? "font-semibold text-brand" : "text-body hover:text-brand"}
                  >
                    {m.name}
                  </Link>
                  <span className="data text-xs text-sold">{m.count}</span>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h2 className="text-sm font-semibold uppercase tracking-[0.12em] text-heading">City</h2>
            <ul className="mt-3">
              {cities.map((c) => (
                <li key={c.slug} className="flex items-baseline justify-between border-b border-border py-1.5 text-sm">
                  <Link
                    href={withParam("city", c.slug === filters.city ? undefined : c.slug)}
                    className={c.slug === filters.city ? "font-semibold text-brand" : "text-body hover:text-brand"}
                  >
                    {c.name}
                  </Link>
                  <span className="data text-xs text-sold">{c.count}</span>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h2 className="text-sm font-semibold uppercase tracking-[0.12em] text-heading">Budget</h2>
            <ul className="mt-3">
              {BUDGET_BANDS.map((b) => (
                <li key={b.slug} className="border-b border-border py-1.5 text-sm">
                  <Link
                    href={withParam("budget", b.slug === filters.budget ? undefined : b.slug)}
                    className={b.slug === filters.budget ? "font-semibold text-brand" : "text-body hover:text-brand"}
                  >
                    {b.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h2 className="text-sm font-semibold uppercase tracking-[0.12em] text-heading">Body</h2>
            <ul className="mt-3">
              {BODY_TYPES.map((b) => (
                <li key={b} className="border-b border-border py-1.5 text-sm">
                  <Link
                    href={withParam("body", b.toLowerCase() === filters.body ? undefined : b.toLowerCase())}
                    className={b.toLowerCase() === filters.body ? "font-semibold text-brand" : "text-body hover:text-brand"}
                  >
                    {b}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h2 className="text-sm font-semibold uppercase tracking-[0.12em] text-heading">Gearbox</h2>
            <ul className="mt-3">
              {["automatic", "manual"].map((t) => (
                <li key={t} className="border-b border-border py-1.5 text-sm">
                  <Link
                    href={withParam("transmission", t === filters.transmission ? undefined : t)}
                    className={t === filters.transmission ? "font-semibold text-brand" : "text-body hover:text-brand"}
                  >
                    {t === "automatic" ? "Automatic" : "Manual"}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h2 className="text-sm font-semibold uppercase tracking-[0.12em] text-heading">Also</h2>
            <ul className="mt-3">
              <li className="border-b border-border py-1.5 text-sm">
                <Link
                  href={withParam("imported", filters.importOnly ? undefined : "1")}
                  className={filters.importOnly ? "font-semibold text-brand" : "text-body hover:text-brand"}
                >
                  Imported, with auction sheet
                </Link>
              </li>
            </ul>
          </div>
        </aside>

        {/* Results */}
        <div>
          {listings.length === 0 ? (
            <div className="border border-border bg-bg-alt p-8">
              <h2 className="text-lg">Nothing matches those filters</h2>
              <p className="mt-2 max-w-[58ch] text-sm text-body">
                {/* Explaining what removed the most results is more useful than an apology. */}
                {applied.length > 0 && (
                  <>
                    The filter that cut the most was {applied.sort((a, b) => b.count - a.count)[0].label}, which
                    removed {applied.sort((a, b) => b.count - a.count)[0].count} listings.{" "}
                  </>
                )}
                We are Lahore first and the stock is deliberately small while we onboard dealers, so a narrow
                filter will often come back empty.
              </p>
              <div className="mt-4 flex flex-wrap gap-3">
                <Link href="/cars" className="btn btn-primary">
                  Clear the filters
                </Link>
                <Link href="/find-my-car" className="btn btn-ghost">
                  Tell us what you want
                </Link>
              </div>
            </div>
          ) : (
            <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-3">
              {listings.map((listing) => (
                <ListingTile key={listing.id} listing={listing} />
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
