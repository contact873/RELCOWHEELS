import Link from "next/link";
import { BODY_BLURBS } from "@/lib/queries";

/**
 * The first browse step: what kind of car.
 *
 * Taken from the reference site's "select car types", which is the right instinct, because it is
 * how a buyer who does not know a model name thinks about the market. Their version lists Luxury
 * twice and invents categories; this one lists what the stock actually holds.
 *
 * The count is listings, never catalogue size, so the number on the tile is the number of cars you
 * get when you click. Hairline gaps rather than padded cards, to stay in this identity.
 */
export function BodyTypeTiles({
  tiles,
}: {
  tiles: { name: string; slug: string; count: number }[];
}) {
  if (tiles.length === 0) return null;

  return (
    <ul className="grid gap-px border border-border bg-border sm:grid-cols-2 lg:grid-cols-5">
      {tiles.map((tile) => (
        <li key={tile.slug} className="bg-bg-alt">
          <Link
            href={`/cars?body=${tile.slug}`}
            className="flex h-full flex-col gap-2 p-5 transition-colors hover:bg-bg-subtle"
          >
            <span className="text-base text-heading" data-display>
              {tile.name}
            </span>
            <span className="text-sm text-sold">{BODY_BLURBS[tile.name] ?? ""}</span>
            <span className="data mt-auto pt-3 text-xs text-brand">{tile.count} listed</span>
          </Link>
        </li>
      ))}
    </ul>
  );
}
