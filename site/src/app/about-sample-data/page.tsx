import Link from "next/link";

export const metadata = {
  title: "What the sample content on this site means",
  description:
    "Every car, article and forum post on this build is placeholder data for development. No seller has listed anything and no dealer has approved anything.",
  alternates: { canonical: "/about-sample-data" },
  robots: { index: false, follow: true },
};

export default function AboutSampleData() {
  return (
    <div className="wrap-x py-10">
      <nav aria-label="Breadcrumb" className="text-sm text-sold">
        <Link href="/" className="hover:text-brand">Home</Link>
        <span className="mx-2">/</span>
        <span className="text-heading">About the sample content</span>
      </nav>

      <div className="mt-5 max-w-[70ch]">
        <h1 className="text-3xl md:text-4xl">This site is showing sample content</h1>

        <p className="mt-4 text-body">
          You are looking at a development build. Everything on it is placeholder data. That is
          deliberate, and it is worth being precise about what it does and does not mean.
        </p>

        <h2 className="mt-8 text-xl">What the sample content is</h2>
        <ul className="mt-3 space-y-2 text-body">
          <li>The 26 cars are invented, shaped to look like the real Lahore market.</li>
          <li>The articles and forum threads are written examples, not real people talking.</li>
          <li>The three photographs are real car photographs owned by this business, reused across a few listings.</li>
          <li>Every other listing carries a labelled placeholder instead of a photograph.</li>
          <li>Prices, mileages and condition scores are plausible, not measured.</li>
        </ul>

        <h2 className="mt-8 text-xl">What it is not</h2>
        <ul className="mt-3 space-y-2 text-body">
          <li>It is not stock copied from another car site. Nothing here was scraped.</li>
          <li>It is not a real listing from any dealer, including the dealers named in our notes.</li>
          <li>It is not an offer, an invitation to treat, or a statement that any car exists.</li>
        </ul>

        <h2 className="mt-8 text-xl">Why the banner is there</h2>
        <p className="mt-3 text-body">
          A marketplace that shows sample cars without saying so is one step away from being
          misleading, and the people most likely to be misled are the dealers we want to work with.
          The banner removes the ambiguity. It disappears on its own once the site is connected to a
          real database, so there is no switch to remember.
        </p>

        <h2 className="mt-8 text-xl">How real listings will arrive</h2>
        <p className="mt-3 text-body">
          A dealer either posts through the site themselves or hands us a stock file they have filled
          in and stand behind. Both routes are authorised, in writing, by the person who owns the
          cars. We do not import stock from another marketplace, and we do not read a dealer&rsquo;s
          Facebook page to lift their inventory.{" "}
          <Link href="/safety" className="underline">
            More on how listings are checked
          </Link>
          .
        </p>

        <p className="mt-8 text-sm text-sold">
          Questions about this build go to the person who showed it to you. Nothing on this site
          should be relied on as a statement about any real vehicle.
        </p>
      </div>
    </div>
  );
}
