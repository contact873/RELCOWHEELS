import type { Metadata } from "next";
import { Archivo, Public_Sans, IBM_Plex_Mono } from "next/font/google";
import "./globals.css";
import { SiteHeader } from "@/components/site-header";
import { SiteFooter } from "@/components/site-footer";
import { CookieConsent } from "@/components/cookie-consent";
import { SampleNotice } from "@/components/sample-notice";

/*
  Three faces, all self-hosted by next/font at build time, and none of them shared with any other
  RELCO property. See ~/Documents/apps/DESIGN-IDENTITY.md.

    Archivo       display, with the width axis opened to 118 for an expanded, mechanical heading
    Public Sans   body
    IBM Plex Mono data: prices, mileage, engine capacity, reference numbers
*/
const display = Archivo({
  subsets: ["latin"],
  variable: "--font-display",
  axes: ["wdth"],
  display: "swap",
});

const body = Public_Sans({
  subsets: ["latin"],
  variable: "--font-body",
  display: "swap",
});

const mono = IBM_Plex_Mono({
  subsets: ["latin"],
  weight: ["400", "500", "600"],
  variable: "--font-mono",
  display: "swap",
});

const SITE_URL = process.env.NEXT_PUBLIC_SITE_URL ?? "https://wheels.relcoai.com";

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: "RELCO Wheels: cars for sale in Pakistan, with the price and the condition shown",
    template: "%s | RELCO Wheels",
  },
  description:
    "Buy and sell used cars in Pakistan. Every listing carries its real asking price, mileage, engine capacity and inspection result, so you know what you are buying before you call.",
  applicationName: "RELCO Wheels",
  robots: { index: true, follow: true, "max-image-preview": "large", "max-snippet": -1 },
  openGraph: {
    type: "website",
    siteName: "RELCO Wheels",
    locale: "en_PK",
    url: SITE_URL,
  },
  twitter: { card: "summary_large_image" },
  alternates: {
    canonical: SITE_URL,
    languages: { en: SITE_URL, "x-default": SITE_URL },
  },
  icons: { icon: "/icon.svg" },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${display.variable} ${body.variable} ${mono.variable}`}>
      <body className="min-h-screen bg-bg text-body">
        <a
          href="#main"
          className="sr-only focus:not-sr-only focus:absolute focus:left-3 focus:top-3 focus:z-50 focus:bg-brand focus:px-3 focus:py-2 focus:text-white"
        >
          Skip to content
        </a>
        <SiteHeader />
        {/* Disappears on its own the moment a database is configured. */}
        <SampleNotice />
        <main id="main">{children}</main>
        <SiteFooter />
        {/* Renders a banner only. No analytics script exists in this HTML until a choice is stored. */}
        <CookieConsent />
      </body>
    </html>
  );
}
