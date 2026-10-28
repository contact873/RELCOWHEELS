import Link from "next/link";
import { isSampleData } from "@/lib/data-source";

/**
 * Shown while the site is reading from seed data rather than a database.
 *
 * This exists so that placeholder content can never be mistaken for real stock, by a dealer viewing
 * the site, by a buyer who stumbles onto a preview deployment, or by us six months from now.
 *
 * Note the gate: it is NEXT_PUBLIC_DATA_SOURCE, not "is a Supabase URL set". Gating on the URL
 * looked right and was wrong: it hid the banner the moment a project existed, while the data layer
 * was still serving invented cars. See src/lib/data-source.ts.
 */
export function SampleNotice() {
  if (!isSampleData()) return null;

  return (
    <div className="border-b border-border bg-bg-subtle">
      <div className="wrap-x flex flex-wrap items-baseline gap-x-3 gap-y-1 py-2.5 text-sm">
        <span className="badge badge-held">Sample content</span>
        <p className="text-body">
          Every listing, article and forum post here is placeholder data for development. No car on
          this site has been listed by a real seller, and no dealer has approved any of it.{" "}
          <Link href="/about-sample-data" className="underline">
            What that means
          </Link>
        </p>
      </div>
    </div>
  );
}
