import Link from "next/link";
import { CookieSettingsButton } from "@/components/cookie-settings-button";

export const metadata = {
  title: "Cookies",
  description:
    "The two cookies RELCO Wheels sets, what each one does, and how to change your choice. Analytics is off unless you turn it on.",
  alternates: { canonical: "/cookies" },
};

export default function Cookies() {
  return (
    <div className="wrap-x py-10">
      <nav aria-label="Breadcrumb" className="text-sm text-sold">
        <Link href="/" className="hover:text-brand">Home</Link>
        <span className="mx-2">/</span>
        <span className="text-heading">Cookies</span>
      </nav>

      <div className="mt-5 max-w-[70ch]">
        <h1 className="text-3xl md:text-4xl">Cookies</h1>

        <p className="mt-4 text-body">
          Two cookies are needed for the site to work. A third is optional, and it stays off until you
          say otherwise. This page is short because there is not much to say, which is the point.
        </p>

        <h2 className="mt-8 text-xl">Necessary</h2>
        <table className="mt-3 w-full text-sm">
          <thead>
            <tr className="border-b border-border text-left">
              <th className="py-2 pr-4 font-semibold text-heading">Name</th>
              <th className="py-2 pr-4 font-semibold text-heading">What it does</th>
              <th className="py-2 font-semibold text-heading">Lasts</th>
            </tr>
          </thead>
          <tbody>
            <tr className="border-b border-border align-top">
              <td className="py-3 pr-4"><span className="data">relwheels.consent.v1</span></td>
              <td className="py-3 pr-4 text-body">Remembers the choice you made on the cookie banner, so you are not asked on every page.</td>
              <td className="py-3 text-body">Until you clear it</td>
            </tr>
            <tr className="border-b border-border align-top">
              <td className="py-3 pr-4"><span className="data">session</span></td>
              <td className="py-3 pr-4 text-body">Keeps you signed in. Without it you would have to sign in on every page.</td>
              <td className="py-3 text-body">Until you sign out</td>
            </tr>
          </tbody>
        </table>

        <h2 className="mt-8 text-xl">Optional</h2>
        <table className="mt-3 w-full text-sm">
          <thead>
            <tr className="border-b border-border text-left">
              <th className="py-2 pr-4 font-semibold text-heading">Name</th>
              <th className="py-2 pr-4 font-semibold text-heading">What it does</th>
              <th className="py-2 font-semibold text-heading">Lasts</th>
            </tr>
          </thead>
          <tbody>
            <tr className="align-top">
              <td className="py-3 pr-4"><span className="data">_ga</span></td>
              <td className="py-3 pr-4 text-body">
                Google Analytics. Tells us which pages get used and which do not. It is not loaded at
                all unless you accept, and the site works completely without it.
              </td>
              <td className="py-3 text-body">13 months</td>
            </tr>
          </tbody>
        </table>

        <h2 className="mt-8 text-xl">Changing your mind</h2>
        <p className="mt-3 text-body">
          Use the button below, or the Cookie settings link in the footer at any time.
        </p>
        <div className="mt-4">
          <CookieSettingsButton />
        </div>

        <h2 className="mt-8 text-xl">A note on how this is built</h2>
        <p className="mt-3 text-body">
          No analytics script is present in the page source before you accept. It is added afterwards,
          by the browser, only if a recorded choice says so. That is a stronger position than the usual
          banner over trackers that have already loaded, and it is what makes &ldquo;essential
          only&rdquo; a real option rather than a label.
        </p>
      </div>
    </div>
  );
}
