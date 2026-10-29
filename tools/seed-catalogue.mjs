#!/usr/bin/env node
/**
 * Turn data/catalogue.json into SQL that fills makes, models and variants.
 *
 *   node tools/seed-catalogue.mjs --dry-run
 *   node tools/seed-catalogue.mjs --out data/catalogue.sql
 *
 * Why SQL rather than writing to the database directly: it needs no keys on this machine, it works
 * before the project exists, and every change can be read before it is applied. The dealer importer
 * works the same way for the same reasons.
 *
 * Why the catalogue is not in a migration: it changes. A new model launches and the file grows, and a
 * migration that has to be edited every time is a migration nobody trusts. The migration creates the
 * tables; this fills them.
 *
 * The generated SQL is idempotent. Running it twice updates names and engine sizes rather than
 * creating a second Suzuki.
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const CATALOGUE = path.join(ROOT, "data/catalogue.json");

const TRANSMISSIONS = new Set(["manual", "automatic"]);
const FUELS = new Set(["petrol", "diesel", "hybrid", "electric", "cng", "lpg"]);

const args = process.argv.slice(2);
const dryRun = args.includes("--dry-run");
const outIndex = args.indexOf("--out");
const outPath = outIndex >= 0 ? path.resolve(args[outIndex + 1] ?? "") : path.join(ROOT, "data/catalogue.sql");

if (outIndex >= 0 && !args[outIndex + 1]) {
  console.error("\n  --out needs a file path.\n");
  process.exit(2);
}

function fail(message) {
  console.error(`\n  ${message}\n`);
  process.exit(1);
}

function slugify(v) {
  return String(v).toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "");
}

if (!fs.existsSync(CATALOGUE)) fail(`No catalogue at ${CATALOGUE}`);

let doc;
try {
  doc = JSON.parse(fs.readFileSync(CATALOGUE, "utf8"));
} catch (error) {
  fail(`data/catalogue.json does not parse: ${error.message}`);
}

// ---------------------------------------------------------------------------
// Validate before generating anything. A bad slug becomes a broken URL, so it is worth failing here
// rather than discovering it as a 404 three weeks later.
// ---------------------------------------------------------------------------

const errors = [];
const makeSlugs = new Set();
let modelCount = 0;
let variantCount = 0;

for (const make of doc.makes ?? []) {
  if (!make.name || !make.slug) errors.push(`A make is missing a name or slug: ${JSON.stringify(make.name)}`);
  if (make.slug !== slugify(make.name)) errors.push(`Make "${make.name}" has slug "${make.slug}", expected "${slugify(make.name)}"`);
  if (makeSlugs.has(make.slug)) errors.push(`Duplicate make slug: ${make.slug}`);
  makeSlugs.add(make.slug);

  const modelSlugs = new Set();
  for (const model of make.models ?? []) {
    modelCount += 1;
    if (model.slug !== slugify(model.name)) {
      errors.push(`${make.name} / "${model.name}" has slug "${model.slug}", expected "${slugify(model.name)}"`);
    }
    if (modelSlugs.has(model.slug)) errors.push(`Duplicate model slug in ${make.name}: ${model.slug}`);
    modelSlugs.add(model.slug);

    if (!Array.isArray(model.variants) || model.variants.length === 0) {
      errors.push(`${make.name} / ${model.name} has no variants, so it can never appear in a listing`);
      continue;
    }

    const variantSlugs = new Set();
    for (const v of model.variants) {
      variantCount += 1;
      const where = `${make.name} / ${model.name} / ${v.name}`;

      if (!v.name || !v.slug) { errors.push(`${where}: missing name or slug`); continue; }
      if (v.slug !== slugify(v.name)) errors.push(`${where}: slug "${v.slug}" should be "${slugify(v.name)}"`);
      if (variantSlugs.has(v.slug)) errors.push(`${where}: duplicate variant slug`);
      variantSlugs.add(v.slug);

      if (v.engine_cc !== null && v.engine_cc !== undefined) {
        if (!Number.isInteger(v.engine_cc) || v.engine_cc < 50 || v.engine_cc > 10000) {
          errors.push(`${where}: engine_cc ${v.engine_cc} is not plausible`);
        }
      }
      if (v.transmission && !TRANSMISSIONS.has(v.transmission)) errors.push(`${where}: bad transmission "${v.transmission}"`);
      if (v.fuel && !FUELS.has(v.fuel)) errors.push(`${where}: bad fuel "${v.fuel}"`);
      if (!v.body_type) errors.push(`${where}: no body_type, so it cannot be faceted by body`);
      if (v.seats !== undefined && (!Number.isInteger(v.seats) || v.seats < 1 || v.seats > 20)) {
        errors.push(`${where}: seats ${v.seats} is not plausible`);
      }
    }
  }
}

if (errors.length) {
  console.log(`\n  ${errors.length} problem${errors.length === 1 ? "" : "s"} in data/catalogue.json:\n`);
  for (const e of errors.slice(0, 30)) console.log(`    ${e}`);
  if (errors.length > 30) console.log(`    and ${errors.length - 30} more`);
  console.log("");
  process.exit(1);
}

// ---------------------------------------------------------------------------
// Generate. One statement per model, walking make then model then variant, so a re-run updates
// rather than duplicates.
// ---------------------------------------------------------------------------

const q = (v) => (v === null || v === undefined ? "null" : `'${String(v).replace(/'/g, "''")}'`);

function modelSql(make, model) {
  const variantRows = model.variants
    .map((v) => `    (${q(v.name)}, ${q(v.slug)}, ${v.engine_cc ?? "null"}, ${q(v.transmission)}, ${q(v.fuel)}, ${q(v.body_type)}, ${v.seats ?? "null"})`)
    .join(",\n");

  return `-- ${make.name} / ${model.name}, ${model.variants.length} variant${model.variants.length === 1 ? "" : "s"}
with mk as (
  insert into makes (name, slug, vertical)
  values (${q(make.name)}, ${q(make.slug)}, 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), ${q(model.name)}, ${q(model.slug)})
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
${variantRows}
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;`;
}

const statements = [];
for (const make of doc.makes) {
  for (const model of make.models) statements.push(modelSql(make, model));
}

// ---------------------------------------------------------------------------
// Report
// ---------------------------------------------------------------------------

const bodies = new Set();
for (const make of doc.makes) for (const model of make.models) for (const v of model.variants) bodies.add(v.body_type);

console.log("");
console.log("  RELCO Wheels, vehicle catalogue");
console.log("");
console.log(`  makes      ${doc.makes.length}`);
console.log(`  models     ${modelCount}`);
console.log(`  variants   ${variantCount}`);
console.log(`  bodies     ${[...bodies].sort().join(", ")}`);
console.log(`  statements ${statements.length}, one per model`);

if (dryRun) {
  console.log("\n  Dry run. Nothing written. Drop --dry-run and add --out <file.sql> to emit SQL.\n");
  process.exit(0);
}

const sql = [
  "-- RELCO Wheels, vehicle catalogue",
  `-- Source: data/catalogue.json`,
  `-- Generated: ${new Date().toISOString()}`,
  "--",
  "-- Idempotent: re-running updates names and engine sizes rather than duplicating a make.",
  "-- Run this after the three migrations, in the Supabase SQL editor, or with psql.",
  "",
  "begin;",
  "",
  ...statements,
  "",
  "commit;",
  "",
].join("\n");

fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(outPath, sql);

console.log(`\n  Wrote ${path.relative(ROOT, outPath)}, ${(sql.length / 1024).toFixed(1)} KB`);

// The site's numbers band reads its counts from a generated module rather than having them typed
// into a page. A count written into markup drifts from the catalogue the first time the catalogue
// changes, and a number on screen that the catalogue does not support is exactly what this project
// exists to avoid. Written whole, so the file cannot accumulate edits that disagree with the data.
const FACTS_PATH = path.resolve(ROOT, "site/src/lib/catalogue-facts.ts");
const facts = `/**
 * Size of the vehicle catalogue.
 *
 * GENERATED FILE. Written by tools/seed-catalogue.mjs from data/catalogue.json, and overwritten
 * whole every time it runs, so edits here are lost. Regenerate with:
 *
 *   node tools/seed-catalogue.mjs --out data/catalogue.sql
 *
 * These are catalogue facts, not listing counts. The catalogue holds ${doc.makes.length} makes whether or not
 * anybody is selling one today, and a page showing these numbers has to say which they are.
 * Listing counts are always derived from listings, never from here.
 *
 * Source: ${doc.makes.length} makes, ${modelCount} models, ${variantCount} variants.
 */

export const CATALOGUE_FACTS = {
  makes: ${doc.makes.length},
  models: ${modelCount},
  variants: ${variantCount},
} as const;
`;

fs.writeFileSync(FACTS_PATH, facts);
console.log(`  Also wrote ${path.relative(ROOT, FACTS_PATH)}, which the site reads for its counts.`);

console.log("\n  Next: paste it into the Supabase SQL editor, or run:");
console.log(`    psql "$DATABASE_URL" -f ${path.relative(ROOT, outPath)}\n`);
