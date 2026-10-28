import type { Config } from "tailwindcss";

/**
 * RELCO Wheels keeps its colours in CSS custom properties, in src/app/tokens.css, and points
 * Tailwind at those variables rather than at hex values. One source of truth, so the registry in
 * identity.json, the stylesheet and the Tailwind utilities can never disagree.
 */
const config: Config = {
  content: ["./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        brand: "var(--brand)",
        "brand-alt": "var(--brand-alt)",
        heading: "var(--heading)",
        body: "var(--text)",
        bg: "var(--bg)",
        "bg-alt": "var(--bg-alt)",
        border: "var(--border)",
        subtle: "var(--bg-subtle)",
        extra: "var(--extra)",
        price: "var(--price)",
        sold: "var(--sold)",
        warn: "var(--warn)",
        danger: "var(--danger)",
      },
      fontFamily: {
        display: ["var(--font-display)", "system-ui", "sans-serif"],
        sans: ["var(--font-body)", "system-ui", "sans-serif"],
        mono: ["var(--font-mono)", "ui-monospace", "monospace"],
      },
      borderRadius: {
        // crisp-2px: the marketplace reads as documentation, not as an app.
        none: "0",
        DEFAULT: "2px",
        sm: "2px",
        md: "3px",
      },
      maxWidth: {
        wrap: "1240px",
        prose: "68ch",
      },
    },
  },
  plugins: [],
};

export default config;
