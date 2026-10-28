import Image from "next/image";
import Link from "next/link";
import { ListingRow } from "@/components/listing-card";
import { countByCity, countByMake, liveListings, soldListings } from "@/lib/queries";
import { seedArticles, seedCategories, seedThreads } from "@/lib/seed";
import { when } from "@/lib/format";

export const metadata = {
  title: "Cars for sale in Pakistan, with the price and the condition shown",
  description:
    "Used cars in Pakistan with the real asking price, verified mileage, engine capacity and an inspection result on every listing. Know what you're buying before you call the seller.",
  alternates: { canonical: "/" },
};

const BUDGETS: [string, string][] = [
  ["Under 20 lakh", "/cars?budget=under-20-lakh"],
  ["Under 30 lakh", "/cars?budget=under-30-lakh"],
  ["Under 50 lakh", "/cars?budget=under-50-lakh"],
  ["Under 1 crore", "/cars?budget=under-1-crore"],
  ["Automatic only", "/cars?transmission=automatic"],
  ["Imported, with sheet", "/cars?imported=1"],
];

export default function HomePage() {
  // Derived from the data, never written by hand. A count on screen that the listings do not
  // support is the fastest way to make a marketplace look invented.
  const live = liveListings();
  const sold = soldListings();
  const makes = countByMake().slice(0, 8);
  const cities = countByCity().slice(0, 6);

  return (
    <>
      {/* ------------------------------------------------------------------ */}
      {/* Hero. Asymmetric split, real photograph, three text elements only. */}
      {/* ------------------------------------------------------------------ */}
      <section className="border-b border-border bg-bg-alt">
        <div className="wrap-x grid items-center gap-10 py-14 lg:grid-cols-[1.05fr_0.95fr] lg:py-20">
          <div>
            <h1 className="text-4xl leading-[1.05] md:text-5xl lg:text-[3.4rem]">
              Every car here shows
              <br />
              what it is worth and
              <br />
              what is wrong with it.
            </h1>

            <p className="mt-5 max-w-[46ch] text-lg text-body">
              Real asking prices, verified mileage and an inspection result, on every listing.
            </p>

            <form action="/cars" className="mt-8 grid gap-3 sm:grid-cols-[1fr_auto]">
              <label className="sr-only" htmlFor="q">
                Make, model or city
              </label>
              <input
                id="q"
                name="q"
                type="search"
                placeholder="Corolla, Alto, Lahore"
                className="w-full border border-border bg-bg px-4 py-3 text-base text-heading placeholder:text-sold focus:border-brand focus:outline-none"
              />
              <button type="submit" className="btn btn-primary">
                Search
              </button>
            </form>

            <div className="mt-6 flex flex-wrap items-center gap-x-6 gap-y-2 text-sm text-sold">
              <Link href="/sell" className="font-semibold text-brand hover:underline">
                Sell your car
              </Link>
              <Link href="/find-my-car" className="hover:text-brand">
                Tell us what you want and we will find it
              </Link>
            </div>
          </div>

          <div className="order-first lg:order-none">
            {/*
              A hero photograph is illustration, so it may show a car that is not for sale here. A
              listing photograph is evidence, so it may not. That is why this one stays while every
              listing currently renders a labelled panel: this image claims nothing about any car.
              The alt is empty on purpose, which marks it decorative and stops it asserting that it
              is a photograph of something on this site.
            */}
            <Image
              src="/cars/11-2.jpg"
              alt=""
              width={900}
              height={675}
              priority
              className="h-auto w-full"
              sizes="(max-width: 1024px) 100vw, 560px"
            />
          </div>
        </div>
      </section>

      {/* ------------------------------------------------------------------ */}
      {/* Latest listings, as rows. One eyebrow for the whole page, here.    */}
      {/* ------------------------------------------------------------------ */}
      <section className="wrap-x py-14">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <h2 className="text-2xl md:text-3xl">Cars listed this week</h2>
          <Link href="/cars" className="text-sm font-semibold text-brand hover:underline">
            All cars
          </Link>
        </div>

        <div className="mt-6">
          {live.map((listing) => (
            <ListingRow key={listing.id} listing={listing} />
          ))}
        </div>
      </section>

      {/* ------------------------------------------------------------------ */}
      {/* Browse by make, city and budget. Compact link grids, not cards.    */}
      {/* ------------------------------------------------------------------ */}
      <section className="border-y border-border bg-bg-alt">
        <div className="wrap-x grid gap-10 py-14 md:grid-cols-3">
          <div>
            <h2 className="text-lg">By make</h2>
            <ul className="mt-4">
              {makes.map((m) => (
                <li key={m.slug} className="flex items-baseline justify-between border-b border-border py-2 text-sm">
                  <Link href={`/cars?make=${m.slug}`} className="text-body hover:text-brand">
                    {m.name}
                  </Link>
                  <span className="data text-xs text-sold">{m.count}</span>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h2 className="text-lg">By city</h2>
            <ul className="mt-4">
              {cities.map((c) => (
                <li key={c.slug} className="flex items-baseline justify-between border-b border-border py-2 text-sm">
                  <Link href={`/cars?city=${c.slug}`} className="text-body hover:text-brand">
                    {c.name}
                  </Link>
                  <span className="data text-xs text-sold">{c.count}</span>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h2 className="text-lg">By budget</h2>
            <ul className="mt-4">
              {BUDGETS.map(([label, href]) => (
                <li key={href} className="border-b border-border py-2 text-sm">
                  <Link href={href} className="text-body hover:text-brand">
                    {label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </section>

      {/* ------------------------------------------------------------------ */}
      {/* How a listing gets its numbers. Ink band, numbered, four steps.     */}
      {/* ------------------------------------------------------------------ */}
      <section data-surface="ink" className="bg-bg">
        <div className="wrap-x py-14">
          <h2 className="max-w-[24ch] text-2xl md:text-3xl">
            Where the condition score on a listing comes from
          </h2>

          <ol className="mt-8 grid gap-8 md:grid-cols-4">
            {[
              ["Mileage is checked", "Against the service record and the odometer, not taken from the seller."],
              ["The car is inspected", "Exterior, engine, suspension, interior and air conditioning, each scored separately."],
              ["The sheet is attached", "The full result goes on the listing. Buyers get the same document we do, not a summary."],
              ["The price stays public", "Including after the sale, so what a car actually fetched stays on the record."],
            ].map(([title, body], i) => (
              <li key={title}>
                <p className="data text-sm text-brand">{String(i + 1).padStart(2, "0")}</p>
                <h3 className="mt-2 text-base">{title}</h3>
                <p className="mt-2 text-sm">{body}</p>
              </li>
            ))}
          </ol>
        </div>
      </section>

      {/* ------------------------------------------------------------------ */}
      {/* Sold record. The one number a competitor does not publish.          */}
      {/* ------------------------------------------------------------------ */}
      <section className="wrap-x py-14">
        <h2 className="text-2xl md:text-3xl">What cars actually sold for</h2>
        <p className="mt-3 max-w-[62ch] text-body">
          Asking prices are everywhere. Sale prices are not. Every car that sells here keeps its
          final price and the number of days it took to move.
        </p>

        <div className="mt-6">
          {sold.map((listing) => (
            <ListingRow key={listing.id} listing={listing} />
          ))}
        </div>
      </section>

      {/* ------------------------------------------------------------------ */}
      {/* Two editorial teasers. Different layout family from everything above. */}
      {/* ------------------------------------------------------------------ */}
      <section className="border-t border-border bg-bg-alt">
        <div className="wrap-x grid gap-10 py-14 lg:grid-cols-2">
          <div>
            <h2 className="text-xl">From the forum</h2>
            <ul className="mt-5 space-y-5">
              {seedThreads.map((thread) => (
                <li key={thread.id} className="border-b border-border pb-5">
                  <Link
                    href={`/forum/t/${thread.slug}`}
                    className="text-base font-semibold text-heading hover:text-brand"
                  >
                    {thread.title}
                  </Link>
                  <p className="data mt-2 text-xs text-sold">
                    {thread.categoryName}
                    <span className="mx-2">/</span>
                    {thread.replyCount} replies
                    <span className="mx-2">/</span>
                    {thread.lastReplyAt ? when(thread.lastReplyAt) : when(thread.createdAt)}
                  </p>
                </li>
              ))}
            </ul>
            <Link href="/forum" className="mt-5 inline-block text-sm font-semibold text-brand hover:underline">
              All categories
            </Link>
          </div>

          <div>
            <h2 className="text-xl">Guides</h2>
            <ul className="mt-5 space-y-5">
              {seedArticles.map((article) => (
                <li key={article.id} className="border-b border-border pb-5">
                  <Link
                    href={`/blog/${article.slug}`}
                    className="text-base font-semibold text-heading hover:text-brand"
                  >
                    {article.title}
                  </Link>
                  <p className="mt-2 text-sm text-body">{article.dek}</p>
                  <p className="data mt-2 text-xs text-sold">
                    {article.authorName}
                    <span className="mx-2">/</span>
                    {article.readingMinutes} min read
                  </p>
                </li>
              ))}
            </ul>
            <Link href="/blog" className="mt-5 inline-block text-sm font-semibold text-brand hover:underline">
              All guides
            </Link>
          </div>
        </div>
      </section>

      {/* ------------------------------------------------------------------ */}
      {/* Forum categories. A plain index, so the section reads differently.  */}
      {/* ------------------------------------------------------------------ */}
      <section className="wrap-x py-14">
        <h2 className="text-2xl md:text-3xl">Ask before you buy</h2>
        <p className="mt-3 max-w-[62ch] text-body">
          Post a listing and ask about it in public. The answer stays where the next buyer can find it.
        </p>
        <ul className="mt-6 grid gap-x-10 md:grid-cols-2">
          {seedCategories.map((category) => (
            <li key={category.id} className="border-b border-border py-4">
              <div className="flex items-baseline justify-between gap-4">
                <Link
                  href={`/forum/${category.slug}`}
                  className="text-base font-semibold text-heading hover:text-brand"
                >
                  {category.name}
                </Link>
                <span className="data shrink-0 text-xs text-sold">{category.threadCount} threads</span>
              </div>
              <p className="mt-1 text-sm text-sold">{category.description}</p>
            </li>
          ))}
        </ul>
      </section>
    </>
  );
}
