import Link from "next/link";
import { notFound } from "next/navigation";
import { PhotoPlaceholder } from "@/components/photo-placeholder";
import { PreviewNotice } from "@/components/preview-notice";
import { ShowcaseCard } from "@/components/showcase-card";
import { dealerListings } from "@/lib/queries";
import { PROSPECTS, getProspect, isIndexable } from "@/lib/prospects";

/**
 * A dealership's own page.
 *
 * Built as a sales document first and a real page second. The shape is the pitch: a dealer who is
 * deciding whether to work with a marketplace wants to see their own name on it, their own cars,
 * and where the enquiries end up. Everything else is noise.
 *
 * The honest parts are the empty ones. No phone number appears because we hold none. No car appears
 * under a real business's name because no car of theirs has been given to us. A proto-page that
 * filled those gaps with plausible-looking content would be the same mistake as the photograph of
 * the Mercedes on the Honda, at the scale of a whole company.
 */

type Params = Promise<{ slug: string }>;

export function generateStaticParams() {
  return PROSPECTS.map((p) => ({ slug: p.slug }));
}

export async function generateMetadata({ params }: { params: Params }) {
  const { slug } = await params;
  const prospect = getProspect(slug);
  if (!prospect) return {};

  return {
    title: `${prospect.name}, ${prospect.city}`,
    description:
      prospect.status === "live"
        ? `Cars listed by ${prospect.name} in ${prospect.city}, with the price and the condition shown.`
        : `An unapproved preview page for ${prospect.name}. Not a listing page, not a partnership, and not in search results.`,
    // A preview carrying a real company's name stays out of search until they have seen it and
    // authorised it. See src/lib/prospects.ts.
    robots: isIndexable(prospect) ? undefined : { index: false, follow: false },
  };
}

const WHAT_YOU_GET: [string, string][] = [
  [
    "Enquiries come straight to you",
    "A buyer reveals their number, it reaches you on WhatsApp, and you keep the conversation. There is no portal to log into and no inbox to check.",
  ],
  [
    "Your cars, on your own page",
    "Your stock sits on this page and on the browse pages, each car with its asking price, mileage, engine, gearbox and how many owners it has had.",
  ],
  [
    "We are a venue, not a dealer",
    "We never own the cars, never hold a payment and never take part in the sale. The buyer deals with you, and the money never touches us.",
  ],
];

export default async function DealerPage({ params }: { params: Params }) {
  const { slug } = await params;
  const prospect = getProspect(slug);
  if (!prospect) notFound();

  const stock = prospect.handle ? dealerListings(prospect.handle) : [];
  const where = [prospect.city, ...prospect.addressLines].filter(Boolean);

  return (
    <>
      <PreviewNotice prospect={prospect} />

      <div className="wrap-x py-10">
        <nav aria-label="Breadcrumb" className="text-sm text-sold">
          <Link href="/" className="hover:text-brand">
            Home
          </Link>
          <span className="mx-2">/</span>
          <span className="text-heading">Dealers</span>
          <span className="mx-2">/</span>
          <span className="text-heading">{prospect.name}</span>
        </nav>

        <header className="mt-5 border-b border-border pb-8">
          <h1 className="text-3xl md:text-4xl">{prospect.name}</h1>
          {where.length > 0 && <p className="mt-3 text-body">{where.join(", ")}</p>}

          <dl className="mt-5 flex flex-wrap gap-x-8 gap-y-3 text-sm">
            <div className="flex gap-2">
              <dt className="text-sold">Cars listed here</dt>
              <dd className="data m-0 text-heading">{stock.length}</dd>
            </div>
            {prospect.stockCount !== null && (
              <div className="flex gap-2">
                <dt className="text-sold">Cars they hold</dt>
                <dd className="data m-0 text-heading">{prospect.stockCount}</dd>
              </div>
            )}
          </dl>
        </header>

        <section className="py-12">
          <h2 className="text-2xl md:text-3xl">What a dealership gets</h2>
          <div className="mt-7 grid gap-px border border-border bg-border md:grid-cols-3">
            {WHAT_YOU_GET.map(([title, body]) => (
              <div key={title} className="bg-bg-alt p-6">
                <h3 className="text-base">{title}</h3>
                <p className="mt-2 text-sm text-body">{body}</p>
              </div>
            ))}
          </div>
        </section>

        <section className="border-t border-border pt-12">
          <div className="flex flex-wrap items-end justify-between gap-4">
            <h2 className="text-2xl md:text-3xl">Their cars</h2>
            {stock.length > 0 && (
              <Link href="/cars" className="text-sm font-semibold text-brand hover:underline">
                See the whole market
              </Link>
            )}
          </div>

          {stock.length > 0 ? (
            <div className="mt-7 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
              {stock.map((listing) => (
                <ShowcaseCard key={listing.id} listing={listing} />
              ))}
            </div>
          ) : (
            <div className="mt-7 grid gap-8 lg:grid-cols-[minmax(0,1fr)_320px]">
              <div className="border border-dashed border-border bg-bg-subtle p-8">
                <h3 className="text-base">No stock loaded yet</h3>
                <p className="mt-3 max-w-[58ch] text-sm text-body">
                  This is the empty frame, and it is empty on purpose. No car appears under a real
                  business's name until they have given us one and told us, in writing, that we may
                  publish it.
                </p>
                <ol className="mt-5 space-y-3 text-sm">
                  {[
                    "Their written authorisation, on one page. docs/dealer-onboarding.md has the wording.",
                    "A stock list, filled into the CSV template. One row per car.",
                    "Their photographs, one folder per car.",
                    "One command loads all of it, and every car appears here with its own page.",
                  ].map((line, i) => (
                    <li key={line} className="flex gap-3">
                      <span className="data shrink-0 text-brand">{String(i + 1).padStart(2, "0")}</span>
                      <span className="text-body">{line}</span>
                    </li>
                  ))}
                </ol>
              </div>

              <div>
                <PhotoPlaceholder reference={prospect.slug} label="Their photographs go here" />
                <p className="mt-3 text-xs text-sold">
                  Three or four per car, at the car's own proportions. Photographs are uploaded to
                  their own folder, so a picture can never end up on somebody else's car.
                </p>
              </div>
            </div>
          )}
        </section>

        <section data-surface="ink" className="mt-12 bg-bg">
          <div className="px-6 py-10 md:px-10">
            <h2 className="max-w-[30ch] text-2xl md:text-3xl">
              Nothing is published until it is agreed in writing.
            </h2>
            <p className="mt-3 max-w-[64ch] text-sm">
              Not a single car, price or photograph. That is the rule this project was built around,
              and it is why this page shows fewer cars than it could. It also means a dealership can
              see exactly what they are agreeing to before they agree to it.
            </p>
          </div>
        </section>
      </div>
    </>
  );
}
