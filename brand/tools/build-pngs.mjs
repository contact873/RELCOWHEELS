#!/usr/bin/env node
// Export PNGs from the RELCO Wheels SVG logo files using headless Chrome.
//
//   node brand/tools/build-pngs.mjs
//
// Why Chrome: neither rsvg nor ImageMagick is installed, and Chrome is, and it is the only one that
// renders the variable webfonts. The wordmark depends on Archivo at a width of 118% and on Public
// Sans, so each SVG has to be inlined into a page that loads them. An externally referenced SVG
// cannot reach the host page's fonts and would silently fall back to Arial, which is not the logo.
//
// Every file written here is then measured by verify-pngs.py. Geometry that quietly overflows its
// canvas looks correct in code and wrong on a wall, and these exports cannot be inspected by eye.

import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const LOGO = path.join(ROOT, "logo");
const OUT = path.join(ROOT, "png");
const TMP = path.join(ROOT, ".build");

const CHROME = [
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
  "/Applications/Chromium.app/Contents/MacOS/Chromium",
  "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge",
].find((p) => fs.existsSync(p));

if (!CHROME) {
  console.error("  No Chrome, Chromium or Edge found, so PNG export is not possible here.");
  console.error("  The SVG files are complete and can be exported from any design tool.");
  process.exit(1);
}

// The three grounds this identity actually uses.
const BACKGROUNDS = {
  light: "#F4F6F8",   // the Wheels page background
  ink: "#0F1B26",     // the Wheels heading colour, used for the footer band
  white: "#FFFFFF",
  transparent: null,
};

// name, svg file, width, height, background
//
// Heights match each file's own viewBox ratio. A mismatch is not fatal because an SVG letterboxes
// rather than distorting, but it produces an export with dead space that then has to be trimmed.
//
// The mark on ink uses the single colour file. The standard mark is drawn in #0C1014, which would
// disappear on an ink ground apart from the orange node.
const EXPORTS = [
  ["mark-1024", "relco-wheels-mark.svg", 1024, 1024, "light"],
  ["mark-512", "relco-wheels-mark.svg", 512, 512, "light"],
  ["mark-256", "relco-wheels-mark.svg", 256, 256, "light"],
  ["mark-128", "relco-wheels-mark.svg", 128, 128, "light"],
  ["mark-64", "relco-wheels-mark.svg", 64, 64, "light"],
  ["mark-48", "relco-wheels-mark.svg", 48, 48, "light"],
  ["mark-32", "relco-wheels-mark.svg", 32, 32, "light"],
  ["mark-16", "relco-wheels-mark.svg", 16, 16, "light"],
  ["mark-transparent-512", "relco-wheels-mark.svg", 512, 512, "transparent"],
  ["roundel-512", "relco-wheels-mark-roundel.svg", 512, 512, "light"],
  ["roundel-256", "relco-wheels-mark-roundel.svg", 256, 256, "light"],
  ["lockup-horizontal-1600", "relco-wheels-lockup-horizontal.svg", 1600, 667, "light"],
  ["lockup-horizontal-800", "relco-wheels-lockup-horizontal.svg", 800, 333, "light"],
  ["lockup-horizontal-tagline-1600", "relco-wheels-lockup-horizontal-tagline.svg", 1600, 703, "light"],
  ["lockup-stacked-1200", "relco-wheels-lockup-stacked.svg", 1200, 1200, "light"],
  ["lockup-horizontal-mono-light-1600", "relco-wheels-lockup-horizontal-mono-light.svg", 1600, 667, "ink"],
  ["lockup-horizontal-mono-dark-1600", "relco-wheels-lockup-horizontal-mono-dark.svg", 1600, 667, "white"],
];

fs.mkdirSync(OUT, { recursive: true });
fs.mkdirSync(TMP, { recursive: true });

function page(svg, width, height, background) {
  const body = svg.replace(/<\?xml[\s\S]*?\?>/g, "").replace(/<!doctype[^>]*>/i, "");
  const bg = background ? BACKGROUNDS[background] : "transparent";
  return `<!doctype html>
<html><head><meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Archivo:wdth,wght@62..125,100..900&family=Public+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
  html, body { margin: 0; padding: 0; background: ${bg}; }
  svg { display: block; width: ${width}px; height: ${height}px; }
</style></head>
<body>${body}</body></html>`;
}

let built = 0;
let failed = 0;

for (const [name, svgFile, width, height, background] of EXPORTS) {
  const svgPath = path.join(LOGO, svgFile);
  if (!fs.existsSync(svgPath)) {
    console.error(`  missing source: ${svgFile}`);
    failed += 1;
    continue;
  }

  const htmlPath = path.join(TMP, `${name}.html`);
  const pngPath = path.join(OUT, `${name}.png`);
  fs.writeFileSync(htmlPath, page(fs.readFileSync(svgPath, "utf8"), width, height, background));

  const result = spawnSync(
    CHROME,
    [
      "--headless=new",
      "--disable-gpu",
      "--hide-scrollbars",
      "--no-sandbox",
      "--force-device-scale-factor=1",
      "--virtual-time-budget=6000",
      `--window-size=${width},${height}`,
      `--screenshot=${pngPath}`,
      `file://${htmlPath}`,
    ],
    { encoding: "utf8", timeout: 60_000 },
  );

  if (fs.existsSync(pngPath) && fs.statSync(pngPath).size > 0) {
    built += 1;
    console.log(`  ${String(width).padStart(4)}x${String(height).padEnd(5)} ${name}.png`);
  } else {
    failed += 1;
    console.error(`  FAILED ${name}: ${(result.stderr || "").split("\n")[0]}`);
  }
}

fs.rmSync(TMP, { recursive: true, force: true });

console.log(`\n  ${built} PNG written, ${failed} failed. Now run: python3 brand/tools/verify-pngs.py\n`);
process.exit(failed ? 1 : 0);
