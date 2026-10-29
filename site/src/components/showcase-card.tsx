import Image from "next/image";
import Link from "next/link";
import { PhotoPlaceholder } from "@/components/photo-placeholder";
import type { Listing } from "@/lib/types";
import { km, pkr, pkrShort, when } from "@/lib/format";

/**
 * The showcase card.
 *
 * Built to persuade, which the ledger row deliberately does not. A row is for scanning a result set
 * once you already know what you are looking for; this is for the visitor who has not decided
 * whether the site is worth their time, so it leads with the two things that decide that in a
 * glance: the price, and whether anybody has checked the car.
 *
 * The price sits in the amber slot and not in the accent, so money reads as money rather than as
 * brand. The condition score sits on the photograph area as a chip, because "somebody inspected
 * this" is the claim this site exists to make and it should not be a line of small grey text.
 *
 * One link, not three. The whole card is clickable, which avoids the duplicate tab stops that three
 * links to the same car create for anybody using a keyboard.
 */
export function ShowcaseCard({ listing }: { listing: Listing }) {
  const sold = listing.status === "sold";
  const hero = listing.photos[0];
  const score = listing.inspection?.overallScore ?? null;

  return (
    <article className="h-full">
      <Link
        href={`/car/${listing.slug}`}
        className="group flex h-full flex-col border border-border bg-bg-alt transition-colors hover:border-brand"
      >
        <div className="relative">
          {hero ? (
            <Image
              src={hero.path}
              alt={hero.alt}
              width={640}
              height={480}
              className="aspect-[4/3] w-full object-cover"
              sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 380px"
            />
          ) : (
            <PhotoPlaceholder reference={listing.reference} />
          )}

          {score !== null && !sold && (
            <span
              className="data absolute left-3 top-3 inline-flex items-baseline gap-1 bg-brand px-2 py-1 text-[11px] leading-none text-white"
              style={{ borderRadius: "var(--radius)" }}
            >
              <span className="opacity-75">CONDITION</span>
              <span className="font-semibold">{score.toFixed(1)}</span>
            </span>
          )}

          {sold && (
            <span
              className="data absolute left-3 top-3 bg-sold px-2 py-1 text-[11px] uppercase leading-none tracking-[0.08em] text-white"
              style={{ borderRadius: "var(--radius)" }}
            >
              Sold
            </span>
          )}
        </div>

        <div className="flex flex-1 flex-col p-5">
          <div className="flex flex-wrap items-center gap-2">
            {listing.inspection && !sold && <span className="badge badge-verified">Inspected</span>}
            {listing.hasAuctionSheet && !sold && <span className="badge badge-verified">Auction sheet</span>}
            {/* Neutral, not amber. Amber now means money on this site, and a badge borrowing it
                would read as a price. */}
            {listing.sellerIsDealer && (
              <span className="badge border border-border text-sold">Dealer</span>
            )}
          </div>

          <h3 className="mt-3 text-lg leading-snug text-heading group-hover:text-brand">
            {listing.modelYear} {listing.makeName} {listing.modelName}
          </h3>
          <p className="mt-1 text-sm text-sold">{listing.variantName}</p>

          <p className="price mt-4 text-2xl leading-none">
            {pkr(listing.pricePkr, listing.priceOnCall)}
          </p>
          <p className="data mt-1 text-xs text-sold">
            {pkrShort(listing.pricePkr, listing.priceOnCall)}
          </p>

          <dl className="mt-4 grid grid-cols-3 gap-x-3 gap-y-1 border-t border-border pt-4 text-xs">
            <div>
              <dt className="text-sold">Mileage</dt>
              <dd className="data m-0 text-heading">{km(listing.mileageKm)}</dd>
            </div>
            <div>
              <dt className="text-sold">Engine</dt>
              <dd className="data m-0 text-heading">
                {listing.engineCc ? `${listing.engineCc} cc` : "Not stated"}
              </dd>
            </div>
            <div>
              <dt className="text-sold">Gearbox</dt>
              <dd className="m-0 capitalize text-heading">{listing.transmission ?? "Not stated"}</dd>
            </div>
          </dl>

          <p className="mt-auto pt-4 text-xs text-sold">
            {listing.areaName ? `${listing.areaName}, ` : ""}
            {listing.cityName}
            <span className="mx-2">/</span>
            {when(listing.publishedAt)}
          </p>
        </div>
      </Link>
    </article>
  );
}
