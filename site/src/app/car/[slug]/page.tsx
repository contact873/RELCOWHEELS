import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import { PhotoPlaceholder } from "@/components/photo-placeholder";
import { ListingTile } from "@/components/listing-card";
import { allListingSlugs, getListing, similarListings } from "@/lib/queries";
import { groupFeatures } from "@/lib/features";
import { cc, km, pkr, pkrShort, titleCase, when } from "@/lib/format";

type Params = Promise<{ slug: string }>;

export function generateStaticParams() {
  return allListingSlugs().map((slug) => ({ slug }));
}

export async function generateMetadata({ params }: { params: Params }) {
  const { slug } = await params;
  const listing = getListing(slug);
  if (!listing) return { title: "Car not found" };

  const price = listing.priceOnCall ? "price on application" : pkrShort(listing.pricePkr);
  return {
    title: `${listing.title}, ${price}`,
    description: `${listing.title} in ${listing.cityName}. ${km(listing.mileageKm)}${listing.engineCc ? `, ${cc(listing.engineCc)}` : ""}${
      listing.inspection ? `, condition ${listing.inspection.overallScore}/10` : ""
    }. Reference ${listing.reference}.`,
    alternates: { canonical: `/car/${listing.slug}` },
    openGraph: {
      title: `${listing.title}, ${price}`,
      type: "website",
      images: listing.photos.length ? [listing.photos[0].path] : [],
    },
  };
}

export default async function ListingPage({ params }: { params: Params }) {
  const { slug } = await params;
  const listing = getListing(slug);
  if (!listing) notFound();

  const sold = listing.status === "sold";
  const featureGroups = groupFeatures(listing.featureKeys);
  const similar = similarListings(listing);

  const SITE = process.env.NEXT_PUBLIC_SITE_URL ?? "https://wheels.relcoai.com";

  /**
   * Vehicle, not the bare Product that PakWheels emits. Vehicle inherits from Product and carries
   * the fields Google's vehicle guidance actually reads. Two rules: mileage is a QuantitativeValue
   * in kilometres rather than a formatted string, and no VIN is ever invented for a car we have not
   * physically identified.
   */
  const jsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "Vehicle",
        name: `${listing.title} for sale in ${listing.cityName}`,
        brand: { "@type": "Brand", name: listing.makeName },
        model: listing.modelName,
        vehicleConfiguration: listing.variantName ?? undefined,
        vehicleModelDate: listing.modelYear,
        bodyType: listing.bodyType ?? undefined,
        color: listing.color ?? undefined,
        fuelType: listing.fuel ?? undefined,
        vehicleTransmission: listing.transmission ?? undefined,
        numberOfDoors: undefined,
        itemCondition: "https://schema.org/UsedCondition",
        mileageFromOdometer: listing.mileageKm
          ? { "@type": "QuantitativeValue", value: listing.mileageKm, unitCode: "KMT" }
          : undefined,
        vehicleEngine: listing.engineCc
          ? {
              "@type": "EngineSpecification",
              engineDisplacement: { "@type": "QuantitativeValue", value: listing.engineCc, unitCode: "CMQ" },
            }
          : undefined,
        image: listing.photos.length ? listing.photos.map((p) => `${SITE}${p.path}`) : undefined,
        offers: {
          "@type": "Offer",
          priceCurrency: "PKR",
          ...(listing.pricePkr !== null ? { price: listing.pricePkr } : {}),
          availability: sold ? "https://schema.org/SoldOut" : "https://schema.org/InStock",
          url: `${SITE}/car/${listing.slug}`,
          seller: {
            "@type": listing.sellerIsDealer ? "AutoDealer" : "Person",
            name: listing.sellerName,
          },
        },
      },
      {
        "@type": "BreadcrumbList",
        itemListElement: [
          { "@type": "ListItem", position: 1, name: "Home", item: SITE },
          { "@type": "ListItem", position: 2, name: "Cars", item: `${SITE}/cars` },
          {
            "@type": "ListItem",
            position: 3,
            name: listing.cityName,
            item: `${SITE}/cars?city=${listing.citySlug}`,
          },
          { "@type": "ListItem", position: 4, name: listing.title, item: `${SITE}/car/${listing.slug}` },
        ],
      },
    ],
  };

  // Three clusters, not one long ruled table. A spec sheet with a hairline under every row is the
  // laziest possible layout and it buries the two or three numbers a buyer actually cares about.
  const dateRow: [string, string] = sold
    ? ["Sold on", when(listing.updatedAt)]
    : ["Last updated", when(listing.updatedAt)];

  const specClusters: { heading: string; rows: [string, string][] }[] = [
    {
      heading: "The car",
      rows: [
        ["Model year", String(listing.modelYear)],
        ["Make and model", `${listing.makeName} ${listing.modelName}`],
        ["Variant", listing.variantName ?? "Not stated"],
        ["Body", titleCase(listing.bodyType) || "Not stated"],
        ["Assembly", listing.assembly ? titleCase(listing.assembly) : "Not stated"],
      ],
    },
    {
      heading: "Condition and use",
      rows: [
        ["Mileage", km(listing.mileageKm)],
        ["Engine", cc(listing.engineCc)],
        ["Gearbox", listing.transmission ? titleCase(listing.transmission) : "Not stated"],
        ["Fuel", listing.fuel ? titleCase(listing.fuel) : "Not stated"],
        ["Owners", listing.ownerCount ? String(listing.ownerCount) : "Not stated"],
        ["Accident history", listing.isAccidental === null ? "Not stated" : listing.isAccidental ? "Repaired, declared" : "None declared"],
        ["Auction sheet", listing.hasAuctionSheet ? "Held with the car" : "Not applicable"],
      ],
    },
    {
      heading: "Where it is",
      rows: [
        ["City", listing.cityName],
        ["Area", listing.areaName ?? "Not stated"],
        ["Registered in", listing.registeredIn ?? "Not stated"],
        ["Reference", listing.reference],
        ["Listed", when(listing.publishedAt)],
        dateRow,
      ],
    },
  ];

  return (
    <div className="wrap-x py-8">
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />

      <nav aria-label="Breadcrumb" className="text-sm text-sold">
        <Link href="/" className="hover:text-brand">Home</Link>
        <span className="mx-2">/</span>
        <Link href="/cars" className="hover:text-brand">Cars</Link>
        <span className="mx-2">/</span>
        <Link href={`/cars?city=${listing.citySlug}`} className="hover:text-brand">{listing.cityName}</Link>
        <span className="mx-2">/</span>
        <span className="text-heading">{listing.makeName} {listing.modelName}</span>
      </nav>

      <div className="mt-4 grid gap-10 lg:grid-cols-[1.35fr_1fr]">
        {/* ---------------------------------------------------------------- */}
        <div>
          <div className="flex flex-wrap items-center gap-2">
            {sold && <span className="badge badge-sold">Sold</span>}
            {listing.inspection && !sold && <span className="badge badge-verified">Inspected</span>}
            {listing.hasAuctionSheet && <span className="badge badge-verified">Auction sheet</span>}
            {listing.sellerIsDealer && <span className="badge">Dealer</span>}
          </div>

          <h1 className="mt-3 text-3xl leading-tight md:text-4xl">{listing.title}</h1>

          <p className="mt-3 text-body">
            {listing.areaName ? `${listing.areaName}, ` : ""}{listing.cityName}
            <span className="mx-2 text-sold">/</span>
            Reference <span className="data">{listing.reference}</span>
          </p>

          {listing.photos.length > 0 ? (
            <div className="mt-6">
              <div className="border border-border bg-bg-alt">
                <Image
                  src={listing.photos[0].path}
                  alt={listing.photos[0].alt}
                  width={1200}
                  height={900}
                  priority
                  className="h-auto w-full"
                  sizes="(max-width: 1024px) 100vw, 760px"
                />
              </div>
              {listing.photos.length > 1 && (
                <ul className="mt-3 grid grid-cols-3 gap-3 sm:grid-cols-4">
                  {listing.photos.slice(1).map((p) => (
                    <li key={p.path} className="border border-border bg-bg-alt">
                      <Image
                        src={p.path}
                        alt={p.alt}
                        width={300}
                        height={225}
                        className="h-auto w-full"
                        sizes="180px"
                      />
                    </li>
                  ))}
                </ul>
              )}
            </div>
          ) : (
            <div className="mt-6">
              <PhotoPlaceholder
                reference={listing.reference}
                label="No photograph supplied for this car"
                className="aspect-[4/3]"
              />
              <p className="mt-3 text-sm text-sold">
                This listing has no photographs yet. Ask for some before you travel to see the car,
                and treat a listing with no pictures as a question rather than an offer.
              </p>
            </div>
          )}

          {/* ------------------------------------------------------------ */}
          {/* The condition panel. Numbers, no progress bars and no gauge. */}
          {/* ------------------------------------------------------------ */}
          {listing.inspection && (
            <section className="mt-10 border border-border bg-bg-alt p-6">
              <div className="flex flex-wrap items-baseline justify-between gap-3">
                <h2 className="text-lg">Condition</h2>
                <p className="data text-sm text-sold">
                  Inspected {new Date(listing.inspection.inspectedOn).toLocaleDateString("en-GB", {
                    day: "numeric", month: "short", year: "numeric",
                  })}
                </p>
              </div>

              <p className="mt-4 flex items-baseline gap-2">
                <span className="data text-4xl text-heading">{listing.inspection.overallScore}</span>
                <span className="text-sold">out of 10</span>
              </p>

              <ul className="mt-6 grid grid-cols-2 gap-x-8 gap-y-4 sm:grid-cols-5">
                {[
                  ["Exterior", listing.inspection.exterior],
                  ["Engine", listing.inspection.engine],
                  ["Suspension", listing.inspection.suspension],
                  ["Interior", listing.inspection.interior],
                  ["Air conditioning", listing.inspection.ac],
                ].map(([label, value]) => (
                  <li key={String(label)}>
                    <p className="data text-xl text-heading">{value}</p>
                    <p className="mt-1 text-xs text-sold">{label}</p>
                  </li>
                ))}
              </ul>

              <p className="mt-6 max-w-[62ch] text-sm text-body">
                A condition score is one inspector&rsquo;s opinion, recorded on one afternoon, across five
                areas. It compares cars against each other. It is not a warranty, and you should still look
                at the car yourself before you pay.{" "}
                <Link href="/blog/what-we-do-not-claim" className="underline">
                  What we do not claim
                </Link>
                .
              </p>
            </section>
          )}

          {/* ------------------------------------------------------------ */}
          {/* The specification, in three clusters.                        */}
          {/* ------------------------------------------------------------ */}
          <section className="mt-10">
            <h2 className="text-lg">Specification</h2>
            <div className="mt-5 space-y-8">
              {specClusters.map((cluster) => (
                <div key={cluster.heading}>
                  <h3 className="text-sm font-semibold uppercase tracking-[0.12em] text-sold">
                    {cluster.heading}
                  </h3>
                  <dl className="mt-3 grid gap-x-10 sm:grid-cols-2">
                    {cluster.rows.map(([label, value]) => (
                      <div key={label} className="flex items-baseline justify-between gap-4 py-1.5">
                        <dt className="text-sm text-sold">{label}</dt>
                        <dd className="data m-0 text-right text-sm text-heading">{value}</dd>
                      </div>
                    ))}
                  </dl>
                </div>
              ))}
            </div>
          </section>

          {featureGroups.length > 0 && (
            <section className="mt-10">
              <h2 className="text-lg">Equipment</h2>
              <div className="mt-5 space-y-6">
                {featureGroups.map((group) => (
                  <div key={group.label}>
                    <h3 className="text-sm font-semibold uppercase tracking-[0.12em] text-sold">
                      {group.label}
                    </h3>
                    <ul className="mt-2 flex flex-wrap gap-x-6 gap-y-2 text-sm text-body">
                      {group.items.map((item) => (
                        <li key={item}>{item}</li>
                      ))}
                    </ul>
                  </div>
                ))}
              </div>
            </section>
          )}
        </div>

        {/* ---------------------------------------------------------------- */}
        {/* The sidebar: price, the two actions, and the seller.             */}
        {/* ---------------------------------------------------------------- */}
        <aside className="lg:sticky lg:top-20 lg:self-start">
          <div className="border border-border bg-bg-alt p-6">
            <p className="price text-3xl">{pkr(listing.pricePkr, listing.priceOnCall)}</p>
            <p className="mt-1 text-sm text-sold">{pkrShort(listing.pricePkr, listing.priceOnCall)}</p>

            {sold ? (
              <div className="mt-6">
                <p className="badge badge-sold">Sold</p>
                <p className="mt-3 text-sm text-body">
                  This car has sold. We keep sold listings up with their final price, because what a car
                  actually fetched is more useful than what somebody once asked for it.
                </p>
              </div>
            ) : (
              <div className="mt-6 space-y-3">
                <button type="button" className="btn btn-primary w-full">
                  Show the seller&rsquo;s number
                </button>
                <button type="button" className="btn btn-ghost w-full">
                  Send a message
                </button>
                <p className="text-xs text-sold">
                  Showing the number shares your own number with this seller so they can call you back.
                  Nothing else is shared, and you can ask us to delete it at any time.{" "}
                  <Link href="/privacy" className="underline">
                    How enquiries work
                  </Link>
                  .
                </p>
              </div>
            )}

            <dl className="mt-6 space-y-1 border-t border-border pt-5">
              {[
                ["Mileage", km(listing.mileageKm)],
                ["Engine", cc(listing.engineCc)],
                ["Gearbox", listing.transmission ? titleCase(listing.transmission) : "Not stated"],
                ["Year", String(listing.modelYear)],
              ].map(([label, value]) => (
                <div key={label} className="flex items-baseline justify-between gap-4">
                  <dt className="text-sm text-sold">{label}</dt>
                  <dd className="data m-0 text-sm text-heading">{value}</dd>
                </div>
              ))}
            </dl>
          </div>

          <div className="mt-6 border border-border bg-bg-alt p-6">
            <h2 className="text-sm font-semibold uppercase tracking-[0.12em] text-sold">Seller</h2>
            <p className="mt-3 text-base text-heading">{listing.sellerName}</p>
            <p className="mt-1 text-sm text-sold">
              {listing.sellerIsDealer ? "Dealer" : "Private seller"} in {listing.cityName}
            </p>
            <Link href={`/forum/u/${listing.sellerHandle}`} className="mt-3 inline-block text-sm text-brand underline">
              Their other listings and posts
            </Link>
          </div>

          {!sold && (
            <div className="mt-6 border border-border bg-bg-subtle p-6">
              <h2 className="text-sm font-semibold text-heading">Before you pay anyone</h2>
              <ul className="mt-3 space-y-2 text-sm text-body">
                <li>Meet in a public place, in daylight, and take somebody with you.</li>
                <li>Never send a deposit before you have seen the car and the documents.</li>
                <li>Check the engine and chassis numbers against the registration book.</li>
                <li>Nobody legitimate needs a payment today.</li>
              </ul>
              <Link href="/safety" className="mt-3 inline-block text-sm text-brand underline">
                Full safety advice
              </Link>
            </div>
          )}
        </aside>
      </div>

      {similar.length > 0 && (
        <section className="mt-14 border-t border-border pt-10">
          <h2 className="text-xl">Similar cars</h2>
          <div className="mt-6 grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
            {similar.map((l) => (
              <ListingTile key={l.id} listing={l} />
            ))}
          </div>
        </section>
      )}
    </div>
  );
}
