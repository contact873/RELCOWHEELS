#!/usr/bin/env node
// Writes brand/preview.html with the logo files inlined.
//
//   node brand/tools/build-preview.mjs
//
// Inlined rather than referenced with <img>, because the wordmark is set in Archivo at a width of
// 118% and in Public Sans. An externally referenced SVG cannot see the host page's webfonts, so a
// referenced preview would silently fall back to Arial and show something that is not the logo.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const LOGO = path.join(ROOT, "logo");

function inline(name, { width = null, height = null } = {}) {
  const svg = fs
    .readFileSync(path.join(LOGO, name), "utf8")
    .replace(/<\?xml[\s\S]*?\?>/g, "")
    .replace(/<!doctype[^>]*>/i, "")
    .replace(/<!--[\s\S]*?-->/g, "")
    .trim();

  if (!width) return svg;
  const heightAttr = height ? ` height="${height}"` : "";
  return svg.replace(/<svg\b/, `<svg width="${width}"${heightAttr}`);
}

const MARKS = [["16", 16], ["24", 24], ["32", 32], ["48", 48], ["64", 64], ["128", 128]];

const SWATCHES = [
  ["Verified green", "#0E5C4A", "brand. Verification is the product"],
  ["Action blue", "#1D4ED8", "links and actions only"],
  ["Heading", "#0F1B26", "cool graphite navy"],
  ["Body", "#33414E", ""],
  ["Ground", "#F4F6F8", "cool grey white. Warm cream dulls silver cars"],
  ["Border", "#D3DBE2", ""],
  ["Sold", "#64748B", "desaturated, not red"],
  ["The node", "#C9541F", "the one colour that never changes"],
];

const html = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>RELCO Wheels, logo preview</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Archivo:wdth,wght@62..125,100..900&family=Public+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
  :root {
    --brand:#0E5C4A; --extra:#1D4ED8; --heading:#0F1B26; --text:#33414E;
    --bg:#F4F6F8; --bg-alt:#FCFDFE; --border:#D3DBE2; --subtle:#E8EDF1;
    --sold:#64748B; --node:#C9541F; --radius:2px;
  }
  * { box-sizing: border-box; }
  body { margin:0; background:var(--bg); color:var(--text); line-height:1.6;
         font-family:'Public Sans', system-ui, sans-serif; }
  .wrap { max-width:1040px; margin:0 auto; padding:48px 24px 96px; }
  h1, h2, h3 { font-family:Archivo, system-ui, sans-serif; color:var(--heading);
               font-variation-settings:"wdth" 118; letter-spacing:-0.015em; margin:0; }
  h1 { font-size:clamp(1.9rem,4vw,2.8rem); font-weight:700; }
  h2 { font-size:1.35rem; font-weight:700; margin:56px 0 16px; padding-top:24px;
       border-top:1px solid var(--border); }
  h3 { font-size:0.8rem; font-weight:600; letter-spacing:0.12em; text-transform:uppercase;
       color:var(--sold); margin:32px 0 12px; font-variation-settings:normal; }
  p { max-width:66ch; }
  .panel { background:var(--bg-alt); border:1px solid var(--border); border-radius:var(--radius); padding:32px; }
  .panel.ink { background:var(--heading); border-color:#243546; color:#B3C1CD; }
  .row { display:flex; align-items:flex-end; gap:28px; flex-wrap:wrap; }
  .size { text-align:center; margin:0; }
  .size figcaption { font-size:0.7rem; color:var(--sold); margin-top:10px;
                     font-family:ui-monospace, Menlo, monospace; }
  .lockup { max-width:460px; }
  .lockup svg { width:100%; height:auto; }
  .tab { display:inline-flex; align-items:center; gap:8px; background:var(--bg-alt);
         border:1px solid var(--border); border-radius:var(--radius) var(--radius) 0 0;
         padding:8px 14px; font-size:0.85rem; }
  .appicon { width:96px; height:96px; border-radius:22px; background:var(--heading);
             display:grid; place-items:center; }
  .appicon svg { width:60px; height:60px; }
  .roundel { width:132px; height:132px; border-radius:50%; background:var(--bg-alt);
             border:1px solid var(--border); display:grid; place-items:center; }
  .note { font-size:0.85rem; color:var(--sold); }
  code { font-family:ui-monospace, Menlo, monospace; font-size:0.85em; background:var(--subtle);
         padding:2px 5px; border-radius:2px; }
  .swatches { display:grid; grid-template-columns:repeat(auto-fill,minmax(150px,1fr)); gap:14px; }
  .chip { height:58px; border:1px solid var(--border); border-radius:var(--radius); margin-bottom:6px; }
  .swatch strong { display:block; font-size:0.85rem; color:var(--heading); }
  .swatch .hex { font-family:ui-monospace, Menlo, monospace; font-size:0.75rem; color:var(--sold); }
  table { border-collapse:collapse; width:100%; font-size:0.9rem; }
  td { padding:8px 12px 8px 0; border-bottom:1px solid var(--border); vertical-align:top; }
  footer { margin-top:64px; font-size:0.85rem; color:var(--sold); }
</style>
</head>
<body>
<div class="wrap">
  <h1>RELCO Wheels, logo preview</h1>
  <p>This page inlines the SVG files, so what you see is exactly what the exports contain. Look at the small sizes first: if the mark reads at 16 pixels in a browser tab, it will read anywhere.</p>

  <h2>The mark</h2>
  <div class="panel">
    <div class="row">
      ${MARKS.map(([label, size]) => `<figure class="size">${inline("relco-wheels-mark.svg", { width: size })}<figcaption>${label}px</figcaption></figure>`).join("\n      ")}
    </div>
  </div>
  <p class="note">Carried over from the parent brand kit unchanged. The R and its orange node are the only things every RELCO property shares, which is why the node is allowed to be the one fixed colour across the portfolio.</p>

  <h2>The primary lockup</h2>
  <div class="panel">
    <div class="lockup">${inline("relco-wheels-lockup-horizontal.svg")}</div>
  </div>
  <p class="note">RELCO in Archivo at 118% width, WHEELS in Public Sans letterspaced. The hairline rule and EST. 2026 are what make it read as established rather than as a startup.</p>

  <h2>With the tagline</h2>
  <div class="panel">
    <div class="lockup" style="max-width:540px">${inline("relco-wheels-lockup-horizontal-tagline.svg")}</div>
  </div>
  <p class="note">Know what you&rsquo;re buying. It describes the buyer&rsquo;s position rather than promising our perfection, so one bad listing cannot make it false.</p>

  <h2>Stacked, for square spaces</h2>
  <div class="panel" style="max-width:300px">
    ${inline("relco-wheels-lockup-stacked.svg", { width: 240 })}
  </div>

  <h2>The roundel, for icons</h2>
  <div class="row">
    <div class="roundel">${inline("relco-wheels-mark-roundel.svg", { width: 96 })}</div>
    <div class="appicon">${inline("relco-wheels-mark.svg", { width: 60 })}</div>
  </div>
  <p class="note">Left: the hairline ring, for app icons and social avatars. Right: the plain mark on ink. The ring is not the primary mark, because a ring around a letter reads as a badge rather than a signature.</p>

  <h2>On ink</h2>
  <div class="panel ink">
    <div class="lockup">${inline("relco-wheels-lockup-horizontal-mono-light.svg")}</div>
  </div>
  <p class="note">Single colour. The two colour mark is drawn in ink, so on an ink ground only the orange node would survive. That is what the mono file is for.</p>

  <h2>In context</h2>
  <div class="row">
    <div class="tab">${inline("relco-wheels-mark.svg", { width: 16 })} RELCO Wheels</div>
  </div>

  <h2>Colour</h2>
  <div class="swatches">
    ${SWATCHES.map(([name, hex, why]) => `<div class="swatch"><div class="chip" style="background:${hex}"></div><strong>${name}</strong><div class="hex">${hex}</div>${why ? `<div class="note">${why}</div>` : ""}</div>`).join("\n    ")}
  </div>

  <h2>Minimum sizes and clear space</h2>
  <table>
    <tr><td>Mark</td><td>16px. It is drawn to hold at that size.</td></tr>
    <tr><td>Horizontal lockup</td><td>140px wide. Below that, use the mark alone.</td></tr>
    <tr><td>Stacked lockup</td><td>110px wide.</td></tr>
    <tr><td>Clear space</td><td>Half the mark&rsquo;s height on all four sides. Nothing enters that band, including page edges.</td></tr>
    <tr><td>Alignment</td><td>The lockup aligns on the cap height of RELCO, not on its bounding box. Against a rule or a heading, line up the R&rsquo;s top.</td></tr>
  </table>

  <footer>
    <p>Generated by <code>node brand/tools/build-preview.mjs</code>. Do not edit preview.html by hand: it is overwritten each time.</p>
  </footer>
</div>
</body>
</html>
`;

fs.writeFileSync(path.join(ROOT, "preview.html"), html);
console.log(`  preview.html written, ${(html.length / 1024).toFixed(0)} KB`);
