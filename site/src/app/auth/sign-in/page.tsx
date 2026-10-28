import Link from "next/link";

export const metadata = {
  title: "Sign in",
  description: "Sign in to RELCO Wheels to post a car, save a search or reply on the forum.",
  alternates: { canonical: "/auth/sign-in" },
  // Auth pages should never be indexed. Same rule PakWheels applies to its own login page.
  robots: { index: false, follow: false },
};

const PROVIDERS = [
  { id: "google", label: "Continue with Google", note: "Fastest, and works with any Gmail address." },
  { id: "facebook", label: "Continue with Facebook", note: "Use this if Facebook is how you already sign in to things." },
];

export default function SignIn() {
  return (
    <div className="wrap-x py-16">
      <div className="mx-auto max-w-[440px]">
        <h1 className="text-3xl">Sign in</h1>
        <p className="mt-3 text-body">
          You need an account to post a car, save a search or reply on the forum. Browsing is free and
          needs nothing.
        </p>

        <div className="mt-8 space-y-3">
          {PROVIDERS.map((p) => (
            <div key={p.id}>
              <button type="button" className="btn btn-ghost w-full justify-start" disabled>
                {p.label}
              </button>
              <p className="mt-1.5 text-xs text-sold">{p.note}</p>
            </div>
          ))}
        </div>

        <div className="mt-8 border-t border-border pt-6">
          <h2 className="text-base">Sign in with a phone number</h2>
          <p className="mt-2 text-sm text-body">
            A large share of buyers here have no email address, so a phone number will be a first class
            way in, not an afterthought. It is being built second because every code we send costs
            money, and there is no revenue yet to pay for it.
          </p>
        </div>

        <p className="mt-8 text-xs text-sold">
          Sign-in is disabled while the site runs on sample content. Google and Facebook are
          configuration rather than code, so they come online as soon as the database is connected.
        </p>

        <div className="mt-8 border border-border bg-bg-subtle p-5">
          <h2 className="text-base">Why an account at all</h2>
          <p className="mt-2 text-sm text-body">
            An account is what makes a listing accountable. It is also what stops the site filling up
            with automated posts, which is the first thing that happens to an open classifieds board.
          </p>
          <p className="mt-3 text-sm text-body">
            Read the{" "}
            <Link href="/privacy" className="underline">privacy note</Link>{" "}
            before you do. It is short and it is specific about what happens to your phone number when
            you reveal a seller&rsquo;s.
          </p>
        </div>
      </div>
    </div>
  );
}
