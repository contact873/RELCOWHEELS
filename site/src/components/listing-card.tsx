import Image from "next/image";
import Link from "next/link";
import { PhotoPlaceholder } from "@/components/photo-placeholder";
import type { Listing } from "@/lib/types";
import { km, pkr, pkrShort, when } from "@/lib/format";

/**
 * A listing row: photograph, then the facts in the order a buyer reads them.
 *
 * Deliberately not a floating card. At this density the skill's rule applies: elevation is not
 * communicating anything here, so rows are separated by a hairline instead. The photograph is
 * uncropped at its own proportions, because cropping a car to a fixed ratio hides the thing the
 * buyer came to look at.
 *
 * Listings with no photograph render a labelled panel rather than a stock picture. A stock photo
 * of something that is not the car is worse than an honest gap.
 */
export function ListingRow({ listing }: { listing: Listing }) {
  const sold = listing.status === "sold";
  const hero = listing.photos[0];

  return (
    <article
      className={`group grid gap-5 border-b border-border py-6 md:grid-cols-[260px_1fr_auto] md:items-start ${
        sold ? "is-sold" : ""
      }`}
    >
      <Link href={`/car/${listing.slug}`} className="block overflow-hidden bg-subtle">
        {hero ? (
          <Image
            src={hero.path}
            alt={hero.alt}
            width={520}
            height={390}
            className="h-auto w-full object-cover"
            sizes="(max-width: 768px) 100vw, 260px"
          />
        ) : (
          <PhotoPlaceholder reference={listing.reference} />
        )}
      </Link>

      <div className="min-w-0">
        <div className="flex flex-wrap items-center gap-2">
          {sold && <span className="badge badge-sold">Sold</span>}
          {listing.inspection && !sold && <span className="badge badge-verified">Inspected</span>}
          {listing.hasAuctionSheet && !sold && <span className="badge badge-verified">Auction sheet</span>}
          {listing.sellerIsDealer && (
            <span className="text-xs text-sold">Dealer</span>
          )}
        </div>

        <h3 className="mt-2 text-lg leading-snug">
          <Link href={`/car/${listing.slug}`} className="text-heading hover:text-brand">
            {listing.title}
          </Link>
        </h3>

        {/* The four facts a buyer scans before anything else. */}
        <dl className="mt-3 flex flex-wrap gap-x-6 gap-y-1 text-sm">
          <div className="flex gap-2">
            <dt className="text-sold">Mileage</dt>
            <dd className="data m-0 text-heading">{km(listing.mileageKm)}</dd>
          </div>
          <div className="flex gap-2">
            <dt className="text-sold">Engine</dt>
            <dd className="data m-0 text-heading">
              {listing.engineCc ? `${listing.engineCc} cc` : "Not stated"}
            </dd>
          </div>
          <div className="flex gap-2">
            <dt className="text-sold">Gearbox</dt>
            <dd className="m-0 capitalize text-heading">{listing.transmission ?? "Not stated"}</dd>
          </div>
          <div className="flex gap-2">
            <dt className="text-sold">Owners</dt>
            <dd className="data m-0 text-heading">{listing.ownerCount ?? "Not stated"}</dd>
          </div>
        </dl>

        <p className="mt-3 text-sm text-sold">
          {listing.areaName ? `${listing.areaName}, ` : ""}
          {listing.cityName}
          <span className="mx-2">/</span>
          Listed {when(listing.publishedAt)}
          {listing.inspection && (
            <>
              <span className="mx-2">/</span>
              Condition {listing.inspection.overallScore}/10
            </>
          )}
        </p>
      </div>

      <div className="md:text-right">
        <p className="price text-xl">{pkr(listing.pricePkr, listing.priceOnCall)}</p>
        <p className="mt-1 text-sm text-sold">{pkrShort(listing.pricePkr, listing.priceOnCall)}</p>
        <Link
          href={`/car/${listing.slug}`}
          className="btn btn-ghost mt-4 inline-flex w-full justify-center md:w-auto"
        >
          {sold ? "See the record" : "View car"}
        </Link>
      </div>
    </article>
  );
}

/**
 * The browse tile. A grid of these is the right component for scanning a filtered result set,
 * which is why the browse pages use this and the home page uses rows.
 */
export function ListingTile({ listing }: { listing: Listing }) {
  const sold = listing.status === "sold";
  const hero = listing.photos[0];

  return (
    <article className={`border border-border bg-bg-alt ${sold ? "is-sold" : ""}`}>
      <Link href={`/car/${listing.slug}`} className="block">
        {hero ? (
          <Image
            src={hero.path}
            alt={hero.alt}
            width={520}
            height={390}
            className="h-auto w-full"
            sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 380px"
          />
        ) : (
          <PhotoPlaceholder reference={listing.reference} />
        )}
      </Link>
      <div className="p-4">
        <div className="flex items-center gap-2">
          {sold && <span className="badge badge-sold">Sold</span>}
          {listing.inspection && !sold && <span className="badge badge-verified">Inspected</span>}
        </div>
        <h3 className="mt-2 text-base leading-snug">
          <Link href={`/car/${listing.slug}`} className="text-heading hover:text-brand">
            {listing.modelYear} {listing.makeName} {listing.modelName}
          </Link>
        </h3>
        <p className="price mt-2 text-lg">{pkr(listing.pricePkr, listing.priceOnCall)}</p>
        <p className="data mt-1 text-xs text-sold">
          {listing.mileageKm?.toLocaleString("en-PK")} km
          {listing.engineCc ? ` / ${listing.engineCc} cc` : ""}
        </p>
        <p className="mt-2 text-xs text-sold">
          {listing.cityName} <span className="mx-1">/</span> {when(listing.publishedAt)}
        </p>
      </div>
    </article>
  );
}
