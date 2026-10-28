import Link from "next/link";

export const metadata = {
  title: "Buying and selling safely",
  description:
    "How to avoid the advance payment scam, what to check before money changes hands, and what RELCO Wheels does and does not do about fraud.",
  alternates: { canonical: "/safety" },
};

const BUYING = [
  ["See the car before you pay anything", "Not a photograph, not a video call. The car, in daylight, in a public place."],
  ["Check the engine and chassis numbers", "Match the numbers stamped on the car against the registration book. It takes four minutes and it catches the problem you cannot fix later."],
  ["Take somebody with you", "Two people notice twice as much, and a seller behaves differently when you are not alone."],
  ["Never send a deposit to hold a car you have not seen", "This is the single most common way people lose money on a used car, in every country."],
  ["Be suspicious of a price that is too low", "A car priced well under the market is usually hiding something, or does not exist."],
  ["Do the transfer properly", "A car is not yours until the registration is transferred. A signed piece of paper is not ownership."],
];

const SELLING = [
  ["Meet at a bank or a public place", "Not at your home, and not at night."],
  ["Take the money before the keys", "Bank transfer confirmed in your own account, or cash counted at a bank counter."],
  ["Never release the car on a cheque", "Cheques bounce, and by then the car is gone."],
  ["Keep a copy of everything", "The transfer form, the buyer's identity document, and the receipt."],
  ["Report the sale", "If somebody is still using your registration after you have sold, the problem lands on you."],
];

export default function Safety() {
  return (
    <div className="wrap-x py-10">
      <nav aria-label="Breadcrumb" className="text-sm text-sold">
        <Link href="/" className="hover:text-brand">Home</Link>
        <span className="mx-2">/</span>
        <span className="text-heading">Safety</span>
      </nav>

      <div className="mt-5 max-w-[72ch]">
        <h1 className="text-3xl md:text-4xl">Buying and selling safely</h1>

        <div className="mt-6 border-l-2 border-brand pl-5">
          <p className="text-body">
            RELCO Wheels is a venue. We do not own the cars, we do not hold any payment, and we are not
            a party to any sale. That means the responsibility for a safe transaction is yours, and
            this page exists to make it easy to get right.
          </p>
        </div>

        <h2 className="mt-10 text-xl">If you are buying</h2>
        <ol className="mt-4 space-y-5">
          {BUYING.map(([title, body], i) => (
            <li key={title}>
              <p className="data text-sm text-brand">{String(i + 1).padStart(2, "0")}</p>
              <h3 className="mt-1 text-base">{title}</h3>
              <p className="mt-1 text-body">{body}</p>
            </li>
          ))}
        </ol>

        <h2 className="mt-10 text-xl">If you are selling</h2>
        <ol className="mt-4 space-y-5">
          {SELLING.map(([title, body], i) => (
            <li key={title}>
              <p className="data text-sm text-brand">{String(i + 1).padStart(2, "0")}</p>
              <h3 className="mt-1 text-base">{title}</h3>
              <p className="mt-1 text-body">{body}</p>
            </li>
          ))}
        </ol>

        <h2 className="mt-10 text-xl">What we do about bad listings</h2>
        <ul className="mt-3 space-y-2 text-body">
          <li>You have to be signed in to post, which removes most automated spam before it starts.</li>
          <li>A member&rsquo;s first post is held for review. Everything after that publishes immediately.</li>
          <li>Every listing and every post can be reported, and reports go into one queue.</li>
          <li>We can hide a listing, suspend an account, or ban it outright.</li>
          <li>We check new dealer accounts in person before their stock goes up.</li>
        </ul>

        <h2 className="mt-10 text-xl">What we cannot do</h2>
        <p className="mt-3 text-body">
          We cannot verify that every car exists, that every seller owns what they are advertising, or
          that a meeting will be safe. An inspection is a description of a car on one afternoon, not a
          guarantee. If somebody on this site asks you for money before you have seen a car, that is a
          report we want, whatever else happens.
        </p>

        <div className="mt-8 border border-border bg-bg-alt p-5">
          <h2 className="text-base">Something looks wrong</h2>
          <p className="mt-2 text-sm text-body">
            Use the report link on the listing or the post. If it is urgent, contact us directly using
            the details on the site.
          </p>
          <Link href="/cars" className="btn btn-ghost mt-4">
            Back to the cars
          </Link>
        </div>
      </div>
    </div>
  );
}
