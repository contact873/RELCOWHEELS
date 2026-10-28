import Link from "next/link";

export const metadata = {
  title: "Privacy",
  description:
    "What RELCO Wheels collects, why, where it is stored, and how to have it deleted. Written in plain language.",
  alternates: { canonical: "/privacy" },
};

export default function Privacy() {
  return (
    <div className="wrap-x py-10">
      <nav aria-label="Breadcrumb" className="text-sm text-sold">
        <Link href="/" className="hover:text-brand">Home</Link>
        <span className="mx-2">/</span>
        <span className="text-heading">Privacy</span>
      </nav>

      <div className="mt-5 max-w-[70ch]">
        <h1 className="text-3xl md:text-4xl">Privacy</h1>

        <p className="mt-4 text-sm text-sold">
          Plain language version, written to match what the software actually does. It has not been
          reviewed by a lawyer and must be before this site is published.
        </p>

        <h2 className="mt-8 text-xl">What we collect</h2>
        <dl className="mt-3 space-y-4 text-body">
          <div>
            <dt className="font-semibold text-heading">When you create an account</dt>
            <dd className="mt-1">
              Your name, email address, and a phone number if you give us one. If you sign in with
              Google or Facebook, we receive your name and email from them. We never receive your
              password for those services.
            </dd>
          </div>
          <div>
            <dt className="font-semibold text-heading">When you list a car</dt>
            <dd className="mt-1">
              The car details you enter, the photographs you upload, and the city and area you choose.
              Your phone number is stored but never displayed in full: it is masked on the listing and
              only released to a buyer who deliberately reveals it.
            </dd>
          </div>
          <div>
            <dt className="font-semibold text-heading">When you reveal a seller&rsquo;s number or send a message</dt>
            <dd className="mt-1">
              We record the enquiry: which car, when, your name and phone number, and the message.
              This is the record that shows the seller what the listing produced. Your number is
              passed to that seller so they can call you back. That is the purpose, and it is why the
              button says so before you press it.
            </dd>
          </div>
          <div>
            <dt className="font-semibold text-heading">When you use the site</dt>
            <dd className="mt-1">
              Sign-in times, roughly which pages were viewed, and standard technical information a
              server records. Analytics is off unless you accept it in the cookie banner.
            </dd>
          </div>
        </dl>

        <h2 className="mt-8 text-xl">What we do not do</h2>
        <ul className="mt-3 space-y-2 text-body">
          <li>We do not sell your data to anyone.</li>
          <li>We do not share your email address with other members. It is not readable outside your own account.</li>
          <li>We do not show your phone number publicly. Buyers reveal it, or they do not contact you.</li>
          <li>We do not load advertising or analytics trackers before you choose.</li>
          <li>We do not take payments, so we hold no card details at all.</li>
        </ul>

        <h2 className="mt-8 text-xl">Who can see what</h2>
        <p className="mt-3 text-body">
          Listings are public. Forum posts and articles are public. Your email address is visible only
          to you and to site administrators. Enquiries are visible only to the seller they were sent
          to, to you, and to administrators. These are enforced by the database itself, not only by
          the pages, which means a mistake in the code cannot expose them.
        </p>

        <h2 className="mt-8 text-xl">How long we keep it</h2>
        <p className="mt-3 text-body">
          Listings and enquiries are kept while the listing exists and afterwards as part of the
          price record, because what cars actually sold for is the most useful thing on the site.
          Enquiry records are kept for accounting, because they are how we demonstrate to a dealer
          what their listing produced. Account details are deleted when you ask us to delete the
          account.
        </p>

        <h2 className="mt-8 text-xl">Getting your data out, or deleted</h2>
        <p className="mt-3 text-body">
          Write to us and ask. We will confirm what we hold and delete it, except where we are
          required to keep a record for tax or a legal dispute. You do not have to give a reason.
        </p>

        <h2 className="mt-8 text-xl">Security</h2>
        <p className="mt-3 text-body">
          Access is controlled per row in the database, traffic is encrypted, and administrative access
          is limited. No system is perfect, and anybody who claims otherwise about their own should be
          treated with suspicion.
        </p>

        <h2 className="mt-8 text-xl">Contact</h2>
        <p className="mt-3 text-body">
          Use the contact details on the site, or reply to any message we have sent you.
        </p>
      </div>
    </div>
  );
}
