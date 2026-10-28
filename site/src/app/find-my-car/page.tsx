import Link from "next/link";

export const metadata = {
  title: "Find my car",
  description:
    "Tell us the car you want and we will watch the Lahore market for it. Make, model, year, mileage, budget and how far you will travel.",
  alternates: { canonical: "/find-my-car" },
};

const FIELDS: { name: string; label: string; type?: string; placeholder?: string; half?: boolean }[] = [
  { name: "make", label: "Make", placeholder: "Suzuki", half: true },
  { name: "model", label: "Model", placeholder: "Alto", half: true },
  { name: "year_from", label: "Year from", placeholder: "2018", half: true },
  { name: "year_to", label: "Year to", placeholder: "2022", half: true },
  { name: "budget_max", label: "Budget, up to", placeholder: "2,800,000", half: true },
  { name: "mileage_max", label: "Mileage, up to", placeholder: "80,000", half: true },
  { name: "city", label: "Where you will buy", placeholder: "Lahore", half: true },
  { name: "name", label: "Your name", half: true },
  { name: "phone", label: "Your phone", placeholder: "03XX XXXXXXX", type: "tel", half: true },
];

export default function FindMyCar() {
  return (
    <div className="wrap-x py-10">
      <nav aria-label="Breadcrumb" className="text-sm text-sold">
        <Link href="/" className="hover:text-brand">Home</Link>
        <span className="mx-2">/</span>
        <span className="text-heading">Find my car</span>
      </nav>

      <div className="mt-5 grid gap-12 lg:grid-cols-[1.1fr_0.9fr]">
        <div>
          <h1 className="text-3xl md:text-4xl">Tell us what you want</h1>
          <p className="mt-3 max-w-[58ch] text-body">
            Not every car reaches the site before it sells. Tell us what you are looking for and we
            will watch the Lahore market for it, including the cars dealers have not listed yet.
          </p>

          <form className="mt-8 grid gap-4 sm:grid-cols-2">
            {FIELDS.map((f) => (
              <div key={f.name} className={f.half ? "grid gap-1.5" : "grid gap-1.5 sm:col-span-2"}>
                <label htmlFor={f.name} className="text-xs uppercase tracking-[0.08em] text-sold">
                  {f.label}
                </label>
                <input
                  id={f.name}
                  name={f.name}
                  type={f.type ?? "text"}
                  placeholder={f.placeholder}
                  className="w-full border border-border bg-bg-alt px-3 py-2.5 text-sm text-heading placeholder:text-sold focus:border-brand focus:outline-none"
                />
              </div>
            ))}

            <div className="grid gap-1.5 sm:col-span-2">
              <label htmlFor="notes" className="text-xs uppercase tracking-[0.08em] text-sold">
                Anything else
              </label>
              <textarea
                id="notes"
                name="notes"
                rows={4}
                placeholder="Automatic only, no accident history, must have the service record"
                className="w-full border border-border bg-bg-alt px-3 py-2.5 text-sm text-heading placeholder:text-sold focus:border-brand focus:outline-none"
              />
            </div>

            <div className="sm:col-span-2">
              <label className="flex items-start gap-2.5 text-sm text-body">
                <input type="checkbox" className="mt-1" />
                <span>
                  I am happy for RELCO Wheels to contact me about cars that match this. My number is not
                  passed to any dealer without me asking.
                </span>
              </label>
            </div>

            <div className="sm:col-span-2">
              <button type="submit" className="btn btn-primary" disabled>
                Send it
              </button>
              <p className="mt-3 text-xs text-sold">
                Submission is disabled while the site runs on sample content. Once the database is
                connected this saves the request and notifies the desk.
              </p>
            </div>
          </form>
        </div>

        <aside className="lg:sticky lg:top-20 lg:self-start">
          <div className="border border-border bg-bg-alt p-6">
            <h2 className="text-base">How this differs from a saved search</h2>
            <p className="mt-2 text-sm text-body">
              A saved search alerts you when something matching appears on the site. This reaches
              further: it covers cars a dealer has in stock but has not photographed yet, and cars
              coming out of a trade-in.
            </p>
          </div>

          <div className="mt-5 border border-border bg-bg-alt p-6">
            <h2 className="text-base">What we will not do</h2>
            <ul className="mt-2 space-y-2 text-sm text-body">
              <li>We will not send your number to every dealer who might have something.</li>
              <li>We will not charge you for this.</li>
              <li>We will not promise we will find it. Some cars are simply not in the market this month.</li>
            </ul>
          </div>

          <div className="mt-5 border border-border bg-bg-subtle p-6">
            <h2 className="text-base">In a hurry?</h2>
            <p className="mt-2 text-sm text-body">
              Browse what is listed today instead. Everything on the site shows its price, mileage and
              condition result.
            </p>
            <Link href="/cars" className="btn btn-ghost mt-4 w-full">
              Browse the cars
            </Link>
          </div>
        </aside>
      </div>
    </div>
  );
}
