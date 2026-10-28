import Link from "next/link";

/**
 * Shown whenever the application is running on seed data rather than a database.
 *
 * This exists so that placeholder content can never be mistaken for real stock, by a dealer
 * viewing the site, by a buyer who stumbles onto a preview deployment, or by us six months from
 * now. It disappears on its own the moment NEXT_PUBLIC_SUPABASE_URL is set, so there is no switch
 * to remember to turn off.
 */
export function SampleNotice() {
  if (process.env.NEXT_PUBLIC_SUPABASE_URL) return null;

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
