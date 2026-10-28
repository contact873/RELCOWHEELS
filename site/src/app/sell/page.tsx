import Link from "next/link";

export const metadata = {
  title: "Sell your car",
  description:
    "List a car on RELCO Wheels. Free, no commission, and the enquiries come straight to your phone. Four steps and about ten minutes.",
  alternates: { canonical: "/sell" },
};

const STEPS: [string, string, string][] = [
  [
    "Describe the car",
    "Make, model, variant and year, then the mileage, gearbox and engine size. Ten fields, and the site fills in what it already knows about the model.",
    "About four minutes",
  ],
  [
    "Add the photographs",
    "Up to twenty. Front three quarter, rear three quarter, both sides, the dashboard with the odometer readable, the interior, and the engine bay. Daylight, car clean.",
    "About five minutes",
  ],
  [
    "Set the price",
    "Compare against live listings for the same year and trim before you decide. You can change it later, and the listing shows how long it has been up.",
    "One number",
  ],
  [
    "Answer the enquiries",
    "They arrive on your phone. When the car sells, mark it sold and we keep the final price on the record.",
    "When they come",
  ],
];

export default function Sell() {
  return (
    <div className="wrap-x py-10">
      <nav aria-label="Breadcrumb" className="text-sm text-sold">
        <Link href="/" className="hover:text-brand">Home</Link>
        <span className="mx-2">/</span>
        <span className="text-heading">Sell</span>
      </nav>

      <div className="mt-5 max-w-[72ch]">
        <h1 className="text-3xl md:text-4xl">Sell your car</h1>
        <p className="mt-3 text-lg text-body">
          Free to list, no commission, and the enquiries come to your phone rather than sitting in a
          dashboard you have to remember to check.
        </p>

        <div className="mt-8 border border-border bg-bg-alt p-6">
          <h2 className="text-lg">Sign in first</h2>
          <p className="mt-2 text-sm text-body">
            Posting needs an account, because a listing with no accountable person behind it is the
            first thing a spammer produces. Signing in takes one tap with Google or Facebook.
          </p>
          <div className="mt-4 flex flex-wrap gap-3">
            <Link href="/auth/sign-in" className="btn btn-primary">
              Sign in to continue
            </Link>
            <Link href="/safety" className="btn btn-ghost">
              Read the safety advice
            </Link>
          </div>
          <p className="mt-4 text-xs text-sold">
            Posting is disabled while the site runs on sample content. The flow is built; it needs the
            database connected before it can save a listing.
          </p>
        </div>

        <h2 className="mt-12 text-xl">Four steps</h2>
        <ol className="mt-5 space-y-6">
          {STEPS.map(([title, body, time], i) => (
            <li key={title} className="grid gap-2 border-b border-border pb-5 sm:grid-cols-[auto_1fr_auto] sm:items-start sm:gap-6">
              <p className="data text-sm text-brand">{String(i + 1).padStart(2, "0")}</p>
              <div>
                <h3 className="text-base">{title}</h3>
                <p className="mt-1 text-body">{body}</p>
              </div>
              <p className="data shrink-0 text-xs text-sold">{time}</p>
            </li>
          ))}
        </ol>

        <h2 className="mt-12 text-xl">What it costs</h2>
        <p className="mt-3 text-body">
          Nothing. There is no listing fee, no commission on the sale, and no charge for photographs.
          The site earns from dealers who pay for the enquiries their listings produce, and from
          nothing else. That is why a private seller pays nothing.
        </p>

        <h2 className="mt-12 text-xl">What we will ask you to confirm</h2>
        <ul className="mt-3 space-y-2 text-body">
          <li>That the car is yours to sell, or that you are authorised to sell it.</li>
          <li>That the photographs are of this car, not a similar one.</li>
          <li>That the mileage you enter is what the odometer reads.</li>
          <li>That you will mark it sold when it sells.</li>
        </ul>

        <h2 className="mt-12 text-xl">If you are a dealer</h2>
        <p className="mt-3 text-body">
          Dealers get a stock page, a bulk upload, and a monthly record of how many enquiries each
          listing produced. Ask about a dealer account rather than listing car by car.
        </p>
      </div>
    </div>
  );
}
