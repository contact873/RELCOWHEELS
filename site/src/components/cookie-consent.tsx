"use client";

import { useEffect, useState } from "react";

/**
 * Cookie consent, built properly rather than copied.
 *
 * PakWheels fires GTM, Google Analytics and Ad Manager on page load with no banner anywhere in
 * the markup. We do the opposite: no analytics script exists in the served HTML at all, and one
 * is only injected after a recorded acceptance. Essential only leaves the site fully working,
 * because sign in, search, posting and messaging never depended on analytics.
 *
 * The pattern is the one used on auctions22.com, which gates gtag behind a localStorage flag.
 */

const KEY = "relwheels.consent.v1";
const GA_ID = process.env.NEXT_PUBLIC_GA_ID ?? "";

type Choice = "all" | "essential";

function readChoice(): Choice | null {
  try {
    const raw = localStorage.getItem(KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as { choice?: Choice };
    return parsed.choice === "all" || parsed.choice === "essential" ? parsed.choice : null;
  } catch {
    return null;
  }
}

export function loadAnalytics() {
  if (!GA_ID || typeof window === "undefined") return;
  if (document.getElementById("ga-script")) return;

  const s = document.createElement("script");
  s.id = "ga-script";
  s.async = true;
  s.src = `https://www.googletagmanager.com/gtag/js?id=${GA_ID}`;
  document.head.appendChild(s);

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const w = window as any;
  w.dataLayer = w.dataLayer || [];
  w.gtag = function gtag() {
    w.dataLayer.push(arguments);
  };
  w.gtag("js", new Date());
  w.gtag("config", GA_ID, { anonymize_ip: true });
}

export function CookieConsent() {
  const [choice, setChoice] = useState<Choice | null>(null);
  const [ready, setReady] = useState(false);
  const [reopened, setReopened] = useState(false);

  useEffect(() => {
    const stored = readChoice();
    setChoice(stored);
    setReady(true);
    if (stored === "all") loadAnalytics();

    // The footer link sets this flag so a choice can be changed later.
    const onOpen = () => setReopened(true);
    window.addEventListener("relwheels:cookie-settings", onOpen);
    return () => window.removeEventListener("relwheels:cookie-settings", onOpen);
  }, []);

  function decide(next: Choice) {
    try {
      localStorage.setItem(KEY, JSON.stringify({ choice: next, at: new Date().toISOString() }));
    } catch {
      /* storage disabled: treat as undecided and show nothing further */
    }
    setChoice(next);
    setReopened(false);
    if (next === "all") loadAnalytics();
  }

  if (!ready) return null;
  if (choice !== null && !reopened) return null;

  return (
    <div
      role="dialog"
      aria-label="Cookies"
      className="fixed inset-x-0 bottom-0 z-40 border-t border-border bg-bg-alt"
    >
      <div className="wrap-x flex flex-col gap-4 py-4 md:flex-row md:items-center md:justify-between">
        <p className="max-w-prose text-sm text-body">
          We use one cookie to remember this choice, and one for staying signed in. Analytics is
          off unless you turn it on, and the site works fully without it.{" "}
          <a href="/cookies" className="underline">
            What each cookie is for
          </a>
          .
        </p>
        <div className="flex shrink-0 gap-2">
          <button type="button" className="btn btn-ghost" onClick={() => decide("essential")}>
            Essential only
          </button>
          <button type="button" className="btn btn-primary" onClick={() => decide("all")}>
            Accept all
          </button>
        </div>
      </div>
    </div>
  );
}
