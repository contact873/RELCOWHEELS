import Link from "next/link";

export const metadata = {
  title: "Write for RELCO Wheels",
  description:
    "If you know something about buying, selling, inspecting or importing cars that a first time buyer does not, we will publish it under your name.",
  alternates: { canonical: "/write" },
};

export default function Write() {
  return (
    <div className="wrap-x py-10">
      <nav aria-label="Breadcrumb" className="text-sm text-sold">
        <Link href="/" className="hover:text-brand">Home</Link>
        <span className="mx-2">/</span>
        <Link href="/blog" className="hover:text-brand">Guides</Link>
        <span className="mx-2">/</span>
        <span className="text-heading">Write for us</span>
      </nav>

      <div className="mt-5 grid gap-12 lg:grid-cols-[1.1fr_0.9fr]">
        <div>
          <h1 className="text-3xl md:text-4xl">Write for us</h1>
          <p className="mt-3 max-w-[60ch] text-body">
            We publish articles by people who have actually bought, sold, inspected or imported cars.
            If you have done the thing, we want it written down. You keep the credit.
          </p>

          <form className="mt-8 grid gap-4">
            <div className="grid gap-1.5">
              <label htmlFor="w-name" className="text-xs uppercase tracking-[0.08em] text-sold">Your name</label>
              <input id="w-name" name="name" className="w-full border border-border bg-bg-alt px-3 py-2.5 text-sm text-heading focus:border-brand focus:outline-none" />
            </div>

            <div className="grid gap-1.5">
              <label htmlFor="w-contact" className="text-xs uppercase tracking-[0.08em] text-sold">Email or phone</label>
              <input id="w-contact" name="contact" className="w-full border border-border bg-bg-alt px-3 py-2.5 text-sm text-heading focus:border-brand focus:outline-none" />
            </div>

            <div className="grid gap-1.5">
              <label htmlFor="w-title" className="text-xs uppercase tracking-[0.08em] text-sold">Title</label>
              <input id="w-title" name="title" placeholder="What to check on a used Alto" className="w-full border border-border bg-bg-alt px-3 py-2.5 text-sm text-heading placeholder:text-sold focus:border-brand focus:outline-none" />
            </div>

            <div className="grid gap-1.5">
              <label htmlFor="w-summary" className="text-xs uppercase tracking-[0.08em] text-sold">One line summary</label>
              <input id="w-summary" name="summary" placeholder="Five things decide whether you have a good one." className="w-full border border-border bg-bg-alt px-3 py-2.5 text-sm text-heading placeholder:text-sold focus:border-brand focus:outline-none" />
            </div>

            <div className="grid gap-1.5">
              <label htmlFor="w-body" className="text-xs uppercase tracking-[0.08em] text-sold">The article</label>
              <textarea id="w-body" name="body" rows={12} placeholder="Markdown or plain text. Write it the way you would say it." className="w-full border border-border bg-bg-alt px-3 py-2.5 text-sm text-heading placeholder:text-sold focus:border-brand focus:outline-none" />
            </div>

            <div>
              <label className="flex items-start gap-2.5 text-sm text-body">
                <input type="checkbox" className="mt-1" />
                <span>
                  This is my own work, I have not copied it from anywhere, and RELCO Wheels may publish
                  it with my name on it and edit it for length and clarity.
                </span>
              </label>
            </div>

            <div>
              <button type="submit" className="btn btn-primary" disabled>
                Submit for review
              </button>
              <p className="mt-3 text-xs text-sold">
                Submission is disabled while the site runs on sample content. Articles are read before
                publication, so nothing appears publicly without a person having read it.
              </p>
            </div>
          </form>
        </div>

        <aside className="space-y-5">
          <div className="border border-border bg-bg-alt p-6">
            <h2 className="text-base">What we publish</h2>
            <ul className="mt-2 space-y-2 text-sm text-body">
              <li>Something you learned by doing it, with the numbers.</li>
              <li>A specific car, a specific fault, a specific cost.</li>
              <li>Import experience: grades, landed cost, clearing.</li>
              <li>Paperwork and transfer, where people actually get stuck.</li>
            </ul>
          </div>

          <div className="border border-border bg-bg-alt p-6">
            <h2 className="text-base">What we do not publish</h2>
            <ul className="mt-2 space-y-2 text-sm text-body">
              <li>An advertisement for your own stock, written as advice.</li>
              <li>Content copied from another site.</li>
              <li>Lists written to fill a page.</li>
              <li>Anything we cannot stand behind if it is quoted back at us.</li>
            </ul>
          </div>

          <div className="border border-border bg-bg-subtle p-6">
            <h2 className="text-base">Why the review</h2>
            <p className="mt-2 text-sm text-body">
              A published article sits under our name as well as yours, and a bad one is a lasting
              liability in a way a forum post is not. That is the whole reason articles are read first
              and forum posts are not.
            </p>
          </div>
        </aside>
      </div>
    </div>
  );
}
