import Link from "next/link";

export const metadata = {
  title: "Terms of use",
  description: "The terms on which RELCO Wheels is offered. Plain language, and the parts that matter are short.",
  alternates: { canonical: "/terms" },
};

export default function Terms() {
  return (
    <div className="wrap-x py-10">
      <nav aria-label="Breadcrumb" className="text-sm text-sold">
        <Link href="/" className="hover:text-brand">Home</Link>
        <span className="mx-2">/</span>
        <span className="text-heading">Terms</span>
      </nav>

      <div className="mt-5 max-w-[70ch]">
        <h1 className="text-3xl md:text-4xl">Terms of use</h1>

        <p className="mt-4 text-sm text-sold">
          Plain language version, written to match what the software actually does. It has not been
          reviewed by a lawyer and must be before this site is published.
        </p>

        <h2 className="mt-8 text-xl">Who we are, and what this is</h2>
        <p className="mt-3 text-body">
          RELCO Wheels is a classified advertising venue. We let a seller publish a car and we let a
          buyer find it and contact them. We are not a dealer, we are not an agent for either side, and
          we are not a party to any sale.
        </p>

        <h2 className="mt-8 text-xl">What we do not promise</h2>
        <ul className="mt-3 space-y-2 text-body">
          <li>We do not promise a car exists, is owned by the person advertising it, or is as described.</li>
          <li>We do not promise an inspection is complete. It is one inspector&rsquo;s opinion on one day.</li>
          <li>We do not hold money and we do not mediate a dispute.</li>
          <li>We do not guarantee that a listing produces enquiries, or that an enquiry is answered.</li>
        </ul>

        <h2 className="mt-8 text-xl">If you post a listing</h2>
        <ul className="mt-3 space-y-2 text-body">
          <li>You must own the car, or be authorised to sell it.</li>
          <li>The photographs and description must be yours, and must describe the actual car.</li>
          <li>You must update or remove the listing when the car sells.</li>
          <li>You must not post the same car repeatedly to stay at the top.</li>
          <li>You give us permission to display that content on this site until the listing is removed.</li>
        </ul>

        <h2 className="mt-8 text-xl">If you post an article or a forum post</h2>
        <ul className="mt-3 space-y-2 text-body">
          <li>It must be your own work. Quoting somebody with attribution is fine.</li>
          <li>No advertising disguised as advice, and no dealer using the forum to promote their own stock.</li>
          <li>Articles are read before publication. Forum posts publish immediately, except a first post.</li>
          <li>You keep the credit for what you write. We may edit for length, clarity and accuracy.</li>
        </ul>

        <h2 className="mt-8 text-xl">What gets you removed</h2>
        <p className="mt-3 text-body">
          Advertising a car you do not have. Asking for money before a buyer has seen the car.
          Harassment. Impersonating another person or another business. Automated posting. Attempting to
          collect other members&rsquo; contact details in bulk.
        </p>

        <h2 className="mt-8 text-xl">Two things about our name</h2>
        <p className="mt-3 text-body">
          Display names cannot contain our name or the words reserved for staff, so nobody can pose as
          us. And a listing showing an inspection result means what it says on the listing: it does not
          mean we are vouching for the seller.
        </p>

        <h2 className="mt-8 text-xl">Liability</h2>
        <p className="mt-3 text-body">
          To the extent the law allows, we are not liable for a loss arising from a transaction between
          two members. Nothing here excludes liability that cannot lawfully be excluded.
        </p>

        <h2 className="mt-8 text-xl">Which law applies</h2>
        <p className="mt-3 text-body">
          The laws of Pakistan, and the courts at Lahore, because that is where this business is.
        </p>

        <h2 className="mt-8 text-xl">Changes</h2>
        <p className="mt-3 text-body">
          If these terms change materially we will say so on the site. The date below is the version
          you agreed to when you signed up.
        </p>

        <p className="data mt-8 text-xs text-sold">Version 1, draft. Not yet in force.</p>
      </div>
    </div>
  );
}
