#!/usr/bin/env node
/**
 * The site gate. Run before every push.
 *
 *   cd ~/Documents/apps/RELCOWHEELS/site
 *   npm run check:site
 *
 * Each check below exists because it corresponds to a way this site could ship something broken,
 * unsafe or embarrassing. They are cheap to run and they are the reason a mistake gets caught here
 * rather than by a visitor.
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const SITE = path.resolve(HERE, "../site");
const SRC = path.join(SITE, "src");
const BUILD = path.join(SITE, ".next/server/app");
const PROJECT = path.resolve(HERE, "..");

const failures = [];
const warnings = [];
const notes = [];

function fail(check, detail) {
  failures.push({ check, detail });
}
function warn(check, detail) {
  warnings.push({ check, detail });
}

// ---------------------------------------------------------------------------
function walk(dir, exts, out = []) {
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return out;
  }
  for (const entry of entries) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (["node_modules", ".next", ".git"].includes(entry.name)) continue;
      walk(full, exts, out);
    } else if (exts.some((e) => entry.name.endsWith(e))) {
      out.push(full);
    }
  }
  return out;
}

const sourceFiles = walk(SRC, [".ts", ".tsx", ".css", ".md"]);

// ---------------------------------------------------------------------------
// 1. Em dashes and en dashes
//
// A standing house rule across every property, and the design skill treats it as a hard fail too.
// ---------------------------------------------------------------------------

const dashes = [];
for (const file of sourceFiles) {
  const text = fs.readFileSync(file, "utf8");
  const lines = text.split("\n");
  lines.forEach((line, i) => {
    if (line.includes("\u2014") || line.includes("\u2013")) {
      dashes.push(`${path.relative(SITE, file)}:${i + 1}`);
    }
  });
}
if (dashes.length) fail("em dash", `${dashes.length} found: ${dashes.slice(0, 5).join(", ")}`);
else notes.push("no em dashes or en dashes");

// ---------------------------------------------------------------------------
// 2. Unsanitised HTML injection
//
// dangerouslySetInnerHTML on user content is the most direct route to stealing a session. Every
// occurrence must pass through renderBody or plainText, except JSON-LD, which is JSON.stringify of
// an object this code built.
// ---------------------------------------------------------------------------

const injections = [];
for (const file of sourceFiles.filter((f) => f.endsWith(".tsx"))) {
  const text = fs.readFileSync(file, "utf8");
  const pattern = /dangerouslySetInnerHTML=\{\{\s*__html:\s*([\s\S]*?)\}\}/g;
  let m;
  while ((m = pattern.exec(text))) {
    const expr = m[1].trim();
    const safe =
      expr.startsWith("renderBody(") ||
      expr.startsWith("plainText(") ||
      expr.startsWith("JSON.stringify(") ||
      expr.startsWith("resolveBody(");
    if (!safe) {
      const line = text.slice(0, m.index).split("\n").length;
      injections.push(`${path.relative(SITE, file)}:${line} -> ${expr.slice(0, 60)}`);
    }
  }
}
if (injections.length) {
  fail("unsanitised HTML", `${injections.length} raw injection(s): ${injections.join(" | ")}`);
} else {
  notes.push("every HTML injection goes through the sanitiser");
}

// ---------------------------------------------------------------------------
// 3. Secrets in the bundle
//
// The service role key bypasses every row level security policy. A NEXT_PUBLIC_ prefix inlines a
// value into JavaScript delivered to the browser, so the two must never meet.
// ---------------------------------------------------------------------------

const secretPatterns = [
  { name: "JWT", re: /\beyJ[A-Za-z0-9_-]{12,}/ },
  { name: "service role literal", re: /service_role_key\s*[:=]\s*['"][^'"]{8,}['"]/i },
  { name: "public-prefixed secret", re: /NEXT_PUBLIC_[A-Z0-9_]*(SERVICE|SECRET|PRIVATE)[A-Z0-9_]*/i },
];

const secretHits = [];
for (const file of sourceFiles) {
  const text = fs.readFileSync(file, "utf8");
  for (const { name, re } of secretPatterns) {
    if (re.test(text)) secretHits.push(`${path.relative(SITE, file)} (${name})`);
  }
}
if (secretHits.length) fail("secret exposure", secretHits.join(", "));
else notes.push("no secret patterns and no public-prefixed secrets");

// ---------------------------------------------------------------------------
// 4. The build exists, every page has exactly one h1, and no heading level is skipped
//
// The h1 rule was already here. The heading order rule is new, and it earned its place the
// painful way: the footer's column headings were h3, so any page whose content had no h2 went
// h1 straight to h3, which a screen reader announces as a broken outline. It was found by driving
// the live site in a headless browser and reading the accessibility tree, which is not something a
// build can do. But the check itself needs no browser, because the served HTML lists the headings
// in document order, so it belongs here where it runs on every build from now on.
// ---------------------------------------------------------------------------

if (!fs.existsSync(BUILD)) {
  warn("build output", "no .next/server/app, run npm run build first");
} else {
  const pages = walk(BUILD, [".html"]);
  const badH1 = [];
  const badOrder = [];

  for (const page of pages) {
    const html = fs.readFileSync(page, "utf8");
    const where = path.relative(BUILD, page);

    const count = (html.match(/<h1/g) ?? []).length;
    if (count !== 1) badH1.push(`${where} (${count})`);

    // Document order, which is the order a screen reader reads them in.
    const levels = [...html.matchAll(/<h([1-6])/g)].map((m) => Number(m[1]));
    for (let i = 1; i < levels.length; i += 1) {
      if (levels[i] - levels[i - 1] > 1) {
        badOrder.push(`${where} (h${levels[i - 1]} then h${levels[i]})`);
        break;
      }
    }
  }

  if (badH1.length) fail("h1 count", badH1.slice(0, 6).join(", "));
  else notes.push(`${pages.length} pages, one h1 each`);

  if (badOrder.length) fail("heading order", badOrder.slice(0, 6).join(", "));
  else notes.push(`${pages.length} pages, no heading level skipped`);
}

// ---------------------------------------------------------------------------
// 5. The registry matches the stylesheet
// ---------------------------------------------------------------------------

try {
  const identity = JSON.parse(fs.readFileSync(path.join(PROJECT, "identity.json"), "utf8"));
  const tokenFile = path.join(PROJECT, identity.tokenFile);
  const text = fs.readFileSync(tokenFile, "utf8").toLowerCase();
  if (!text.includes(String(identity.tokens.brand).toLowerCase())) {
    fail("stale identity", `${identity.tokens.brand} is declared but absent from ${identity.tokenFile}`);
  } else {
    notes.push(`identity.json matches ${identity.tokenFile}`);
  }
} catch (error) {
  fail("identity", String(error.message));
}

// ---------------------------------------------------------------------------
// 6. Environment files are not going to be committed
// ---------------------------------------------------------------------------

const gitignore = path.join(PROJECT, ".gitignore");
if (fs.existsSync(gitignore)) {
  const text = fs.readFileSync(gitignore, "utf8");
  for (const pattern of [".env", ".env*.local"]) {
    if (!text.includes(pattern)) warn("gitignore", `${pattern} is not ignored`);
  }
  notes.push(".env files are ignored");
}
if (fs.existsSync(path.join(SITE, ".env.local"))) {
  notes.push(".env.local present, gitignored, never commit it");
}

// ---------------------------------------------------------------------------
// 7. Local development is not pointed at the production database
//
// There are two Supabase projects now, they look identical from the outside, and pointing the site
// at the wrong one is easy to do and hard to notice. supabase/projects.json says which is which.
//
// This is a warning rather than a failure for one reason, and it is temporary: the split is half
// done. Production is live, staging has no migrations in it yet, so .env.local legitimately still
// points at production. Once staging is migrated and .env.local points at it, change this warn() to
// fail(), because from that moment pointing local development at production is a mistake rather
// than a necessity.
// ---------------------------------------------------------------------------

const projectsFile = path.join(PROJECT, "supabase/projects.json");
const envLocal = path.join(SITE, ".env.local");

if (fs.existsSync(projectsFile) && fs.existsSync(envLocal)) {
  try {
    const registry = JSON.parse(fs.readFileSync(projectsFile, "utf8"));
    const production = (registry.projects ?? []).find((p) => p.role === "production");
    const staging = (registry.projects ?? []).find((p) => p.role === "staging");
    const env = fs.readFileSync(envLocal, "utf8");

    if (!production?.ref) {
      warn("environments", "supabase/projects.json names no production project");
    } else if (env.includes(production.ref)) {
      warn(
        "environments",
        `.env.local points at the production project (${production.ref}). Repoint it at staging once staging has its migrations: see docs/environments.md`,
      );
    } else {
      notes.push(
        `local development is not pointed at production${staging?.ref ? ` (staging ${staging.ref})` : ""}`,
      );
    }
  } catch (error) {
    warn("environments", `could not read supabase/projects.json: ${String(error.message)}`);
  }
}

// ---------------------------------------------------------------------------
// Report
// ---------------------------------------------------------------------------

console.log("");
for (const n of notes) console.log(`  ok    ${n}`);
for (const w of warnings) console.log(`  warn  ${w.check}: ${w.detail}`);

if (failures.length) {
  console.log("");
  for (const f of failures) console.log(`  FAIL  ${f.check}: ${f.detail}`);
  console.log(`\n  ${failures.length} problem${failures.length === 1 ? "" : "s"}. Do not push.\n`);
  process.exit(1);
}

console.log(`\n  ${notes.length} checks passed${warnings.length ? `, ${warnings.length} warning${warnings.length === 1 ? "" : "s"}` : ""}.\n`);
