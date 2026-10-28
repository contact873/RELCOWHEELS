#!/usr/bin/env node
/**
 * Import a dealer's own stock list into RELCO Wheels.
 *
 *   node tools/import-dealer-stock.mjs stock/zahid-autos.csv --dealer zahid_autos --dry-run
 *   node tools/import-dealer-stock.mjs stock/zahid-autos.csv --dealer zahid_autos --out stock/zahid.sql
 *
 * WHY THIS EXISTS RATHER THAN A SCRAPER.
 *
 * Stock enters RELCO Wheels only from the person who owns the car, or from a dealer who has
 * authorised us in writing to list their stock. PakWheels prohibits automated collection in its
 * terms and claims ownership of the listing text and photographs, so copying from there would make
 * this project liable for their legal costs. See docs/dealer-onboarding.md.
 *
 * The consequence for this script: it takes a file a dealer filled in and stands behind, writes
 * SQL, and does not touch the network at all. There is no fetch, no crawl and no import from a URL
 * anywhere in this file, and there should never be one.
 *
 * Behaviour worth knowing before you run it:
 *
 * - It refuses the WHOLE file if any row fails. A half imported stock list is worse than none,
 *   because nobody notices which cars went missing.
 * - It writes SQL rather than connecting to the database, so it works before a Supabase project
 *   exists and so every change can be read before it is applied.
 * - Photographs are referenced by path only. The files themselves are uploaded to Supabase Storage
 *   separately, under dealers/<handle>/.
 */

import fs from "node:fs";
import path from "node:path";

// ---------------------------------------------------------------------------
// Arguments
// ---------------------------------------------------------------------------

function parseArgs(argv) {
  const out = { csv: null, dealer: null, out: null, dryRun: false, dealerName: null, city: "lahore" };
  const rest = argv.slice(2);

  for (let i = 0; i < rest.length; i += 1) {
    const a = rest[i];
    if (a === "--dry-run") out.dryRun = true;
    else if (a === "--dealer") out.dealer = rest[++i];
    else if (a === "--dealer-name") out.dealerName = rest[++i];
    else if (a === "--city") out.city = rest[++i];
    else if (a === "--out") out.out = rest[++i];
    else if (!a.startsWith("--")) out.csv = a;
    else fail(`Unknown option: ${a}`, 2);
  }

  if (!out.csv) fail("No CSV given. Usage: node tools/import-dealer-stock.mjs <file.csv> --dealer <handle>", 2);
  if (!out.dealer) fail("No --dealer handle given. Every listing needs a seller.", 2);
  if (!/^[a-z0-9_]{3,30}$/.test(out.dealer)) fail(`Bad dealer handle "${out.dealer}". Lowercase letters, digits and underscores only.`, 2);

  // The dealer row is created if it does not exist, because listings need a dealer_id and the whole
  // point of migration 0004 is that a dealer record can exist before its owner has signed up.
  if (!out.dealerName) {
    out.dealerName = out.dealer
      .split("_")
      .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
      .join(" ");
  }

  return out;
}

function fail(message, code = 1) {
  console.error(`\n  ${message}\n`);
  process.exit(code);
}

// ---------------------------------------------------------------------------
// CSV parsing
//
// Hand written rather than pulled from npm, because the only thing needed is correct handling of
// quoted fields, doubled quotes and both line endings. A dependency for that would be a dependency
// to keep patched.
// ---------------------------------------------------------------------------

function parseCsv(text) {
  const rows = [];
  let row = [];
  let field = "";
  let inQuotes = false;

  const src = text.replace(/^\uFEFF/, ""); // strip a BOM, which Excel writes

  for (let i = 0; i < src.length; i += 1) {
    const c = src[i];

    if (inQuotes) {
      if (c === '"') {
        if (src[i + 1] === '"') {
          field += '"';
          i += 1;
        } else {
          inQuotes = false;
        }
      } else {
        field += c;
      }
      continue;
    }

    if (c === '"') inQuotes = true;
    else if (c === ",") {
      row.push(field);
      field = "";
    } else if (c === "\n" || c === "\r") {
      if (c === "\r" && src[i + 1] === "\n") i += 1;
      row.push(field);
      if (row.some((v) => v.trim() !== "")) rows.push(row);
      row = [];
      field = "";
    } else {
      field += c;
    }
  }

  row.push(field);
  if (row.some((v) => v.trim() !== "")) rows.push(row);

  return rows;
}

// ---------------------------------------------------------------------------
// Validation
// ---------------------------------------------------------------------------

const REQUIRED = ["make", "model", "year", "city", "description", "reference"];
const KNOWN_COLUMNS = new Set([
  "make", "model", "variant", "year", "price_pkr", "price_on_call", "mileage_km", "engine_cc",
  "transmission", "fuel", "body_type", "color", "assembly", "seats", "owners", "accidental",
  "registered_in", "city", "area", "reference", "description",
  ...Array.from({ length: 20 }, (_, i) => `photo_${i + 1}`),
]);

// Seeded in supabase/migrations/0001_init.sql. Checked here so a typo in a city becomes an error
// rather than a listing that silently belongs nowhere.
const CITY_SLUGS = new Set([
  "lahore", "karachi", "islamabad", "rawalpindi", "faisalabad", "multan", "gujranwala",
  "peshawar", "sialkot", "sargodha", "sheikhupura", "gujrat", "sahiwal", "okara",
  "rahim-yar-khan", "jhelum", "kasur", "quetta",
]);

const TRANSMISSIONS = new Set(["manual", "automatic"]);
const FUELS = new Set(["petrol", "diesel", "hybrid", "electric", "cng", "lpg"]);
const ASSEMBLY = new Set(["local", "imported"]);

const MAX_PRICE = 2_000_000_000;      // 2 billion PKR. Above this it is a typo.
const MAX_MILEAGE = 2_000_000;
const MAX_PHOTOS = 20;                // enforced again by a trigger in the database

function slugify(value) {
  return String(value)
    .toLowerCase()
    .normalize("NFKD")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 60);
}

function toInt(value) {
  const n = Number(String(value ?? "").replace(/[,\s]/g, ""));
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

function validateRow(raw, lineNo, seenReferences, currentYear) {
  const errors = [];
  const r = {};
  for (const [k, v] of Object.entries(raw)) r[k] = typeof v === "string" ? v.trim() : v;

  for (const col of REQUIRED) {
    if (!r[col]) errors.push(`${col} is required`);
  }
  if (errors.length) return { errors };

  // reference, unique within the file and shaped so it stays readable in a URL and in print
  if (!/^[A-Za-z0-9-]{3,24}$/.test(r.reference)) {
    errors.push("reference must be 3 to 24 characters, letters, digits and hyphens only");
  } else if (seenReferences.has(r.reference.toUpperCase())) {
    errors.push(`reference "${r.reference}" appears more than once in this file`);
  }

  const year = toInt(r.year);
  if (year === null || year < 1900 || year > currentYear + 1) {
    errors.push(`year "${r.year}" is not a plausible model year`);
  }

  // Price: either a figure, or explicitly on call. Never both, never neither.
  const onCall = /^(on_call|on call|call|yes)$/i.test(r.price_on_call ?? "");
  const price = toInt(r.price_pkr);
  if (!onCall) {
    if (price === null || price <= 0) errors.push("price_pkr is required unless price_on_call is set");
    else if (price > MAX_PRICE) errors.push(`price_pkr ${price} looks like a typo`);
  }

  const mileage = r.mileage_km ? toInt(r.mileage_km) : null;
  if (r.mileage_km && (mileage === null || mileage < 0 || mileage > MAX_MILEAGE)) {
    errors.push(`mileage_km "${r.mileage_km}" is not plausible`);
  }

  const engineCc = r.engine_cc ? toInt(r.engine_cc) : null;
  if (r.engine_cc && (engineCc === null || engineCc < 50 || engineCc > 10000)) {
    errors.push(`engine_cc "${r.engine_cc}" is not plausible`);
  }

  if (r.transmission && !TRANSMISSIONS.has(r.transmission.toLowerCase())) {
    errors.push(`transmission must be manual or automatic, got "${r.transmission}"`);
  }
  if (r.fuel && !FUELS.has(r.fuel.toLowerCase())) {
    errors.push(`fuel must be one of ${[...FUELS].join(", ")}, got "${r.fuel}"`);
  }
  if (r.assembly && !ASSEMBLY.has(r.assembly.toLowerCase())) {
    errors.push(`assembly must be local or imported, got "${r.assembly}"`);
  }

  const seats = r.seats ? toInt(r.seats) : null;
  if (r.seats && (seats === null || seats < 1 || seats > 20)) errors.push(`seats "${r.seats}" is not plausible`);

  const owners = r.owners ? toInt(r.owners) : null;
  if (r.owners && (owners === null || owners < 1 || owners > 20)) errors.push(`owners "${r.owners}" is not plausible`);

  const citySlug = slugify(r.city);
  if (!CITY_SLUGS.has(citySlug)) {
    errors.push(`city "${r.city}" is not in the seeded list. Add the city in a migration first.`);
  }

  const regSlug = r.registered_in ? slugify(r.registered_in) : null;
  if (regSlug && !CITY_SLUGS.has(regSlug)) errors.push(`registered_in "${r.registered_in}" is not a known city`);

  if (r.description.length < 30) {
    errors.push("description is under 30 characters. A listing without a real description reads as a fake one.");
  }
  if (r.description.length > 5000) {
    errors.push("description is over 5000 characters");
  }

  const photos = [];
  for (let i = 1; i <= MAX_PHOTOS; i += 1) {
    const p = r[`photo_${i}`];
    if (p) photos.push({ position: i - 1, file: p });
  }
  if (photos.length === 0) errors.push("at least one photo is required");

  if (errors.length) return { errors };

  return {
    row: {
      reference: r.reference.toUpperCase(),
      make: r.make,
      makeSlug: slugify(r.make),
      model: r.model,
      modelSlug: slugify(r.model),
      variant: r.variant || null,
      variantSlug: r.variant ? slugify(r.variant) : "standard",
      year,
      price: onCall ? null : price,
      onCall,
      mileage,
      engineCc,
      transmission: r.transmission ? r.transmission.toLowerCase() : null,
      fuel: r.fuel ? r.fuel.toLowerCase() : null,
      bodyType: r.body_type || null,
      color: r.color || null,
      assembly: r.assembly ? r.assembly.toLowerCase() : null,
      seats,
      owners,
      accidental: /^(yes|true|1|y)$/i.test(r.accidental ?? ""),
      registeredIn: regSlug,
      city: citySlug,
      area: r.area || null,
      description: r.description,
      photos,
      title: `${year} ${r.make} ${r.model}${r.variant ? ` ${r.variant}` : ""}`,
    },
    lineNo,
  };
}

// ---------------------------------------------------------------------------
// SQL emission
// ---------------------------------------------------------------------------

const q = (v) => (v === null || v === undefined ? "null" : `'${String(v).replace(/'/g, "''")}'`);

/**
 * One statement per listing, wrapped in a CTE that walks the catalogue chain: make, then model,
 * then variant. All three use ON CONFLICT DO UPDATE so importing the same dealer twice does not
 * create duplicate makes, and so a later import can correct an engine size or a body type.
 */
function listingSql(row, dealerHandle) {
  const variantName = row.variant ?? "Standard";
  const bodyType = row.bodyType ? q(row.bodyType) : "null";
  const seats = row.seats === null ? "null" : row.seats;

  return `-- ${row.reference} ${row.title}
with mk as (
  insert into makes (name, slug, vertical)
  values (${q(row.make)}, ${q(row.makeSlug)}, 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), ${q(row.model)}, ${q(row.modelSlug)})
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
), vr as (
  insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
  values ((select id from md), ${q(variantName)}, ${q(row.variantSlug)},
          ${row.engineCc ?? "null"}, ${q(row.transmission)}, ${q(row.fuel)}, ${bodyType}, ${seats})
  on conflict (model_id, slug) do update
    set engine_cc = coalesce(excluded.engine_cc, variants.engine_cc),
        transmission = coalesce(excluded.transmission, variants.transmission),
        fuel = coalesce(excluded.fuel, variants.fuel)
  returning id
), ins as (
  insert into listings (
    reference, seller_id, dealer_id, vertical, variant_id, make_id, model_id, model_year,
    title, description, price_pkr, price_on_call, mileage_km, color, assembly,
    registered_in_city_id, city_id, owner_count, is_accidental
  )
  values (
    ${q(row.reference)},
    (select p.id from profiles p where p.handle = ${q(dealerHandle)}),
    (select d.id from dealers d where d.slug = ${q(dealerHandle)}),
    'car',
    (select id from vr),
    (select id from mk),
    (select id from md),
    ${row.year},
    ${q(row.title)},
    ${q(row.description)},
    ${row.price ?? "null"},
    ${row.onCall},
    ${row.mileage ?? "null"},
    ${q(row.color)},
    ${q(row.assembly)},
    ${row.registeredIn ? `(select id from cities where slug = ${q(row.registeredIn)})` : "null"},
    (select id from cities where slug = ${q(row.city)}),
    ${row.owners ?? "null"},
    ${row.accidental}
  )
  on conflict (reference) do update set
    title = excluded.title,
    description = excluded.description,
    price_pkr = excluded.price_pkr,
    price_on_call = excluded.price_on_call,
    mileage_km = excluded.mileage_km,
    color = excluded.color,
    updated_at = now()
  returning id
)
insert into listing_photos (listing_id, storage_path, position)
select ins.id, ${q(`/dealers/${dealerHandle}/`)} || v.file, v.position
from ins, (values ${row.photos.map((p) => `(${p.position}, ${q(p.file)})`).join(", ")}) as v(position, file)
on conflict (listing_id, position) do nothing;`;
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

const args = parseArgs(process.argv);
const csvPath = path.resolve(args.csv);

// The template's cars are invented, so a file generated from it gets a banner saying so. The risk is
// specific and easy to hit: the generated SQL looks exactly like a real import, and pasting it into
// the live database would put six fictional cars on a fictional dealer's page.
const isTemplate = /template/i.test(path.basename(csvPath));

if (!fs.existsSync(csvPath)) fail(`No such file: ${csvPath}`, 2);

const rows = parseCsv(fs.readFileSync(csvPath, "utf8"));
if (rows.length < 2) fail("The file has a header and no data rows.", 2);

const header = rows[0].map((h) => h.trim().toLowerCase());
const unknown = header.filter((h) => h && !KNOWN_COLUMNS.has(h));
if (unknown.length) {
  fail(
    `Unrecognised columns: ${unknown.join(", ")}\n` +
      `  Start from templates/dealer-stock-template.csv so the headers match.`,
    2,
  );
}
for (const col of REQUIRED) {
  if (!header.includes(col)) fail(`The file is missing the required column "${col}".`, 2);
}

const currentYear = new Date().getFullYear();
const seenReferences = new Set();
const accepted = [];
const rejected = [];

rows.slice(1).forEach((cells, i) => {
  const raw = {};
  header.forEach((h, c) => {
    if (h) raw[h] = cells[c] ?? "";
  });

  const result = validateRow(raw, i + 2, seenReferences, currentYear);
  if (result.errors) {
    rejected.push({ lineNo: i + 2, reference: raw.reference || "(no reference)", errors: result.errors });
  } else {
    seenReferences.add(result.row.reference);
    accepted.push(result.row);
  }
});

// ---------------------------------------------------------------------------
// Report
// ---------------------------------------------------------------------------

console.log(`\n  RELCO Wheels, dealer stock import`);
console.log(`  ${path.basename(csvPath)} for dealer "${args.dealer}"`);
console.log(`  ${rows.length - 1} data rows read\n`);

if (rejected.length) {
  console.log(`  REFUSED. ${rejected.length} of ${rows.length - 1} rows have problems:\n`);
  for (const r of rejected) {
    console.log(`  line ${r.lineNo}, ${r.reference}`);
    for (const e of r.errors) console.log(`      ${e}`);
  }
  console.log(
    `\n  Nothing was written. Fix the file and run it again.\n` +
      `  The whole file is refused rather than the bad rows skipped, because a partly imported\n` +
      `  stock list is worse than none: nobody notices the cars that went missing.\n`,
  );
  process.exit(1);
}

const withPrice = accepted.filter((r) => !r.onCall);
const prices = withPrice.map((r) => r.price).sort((a, b) => a - b);
const median = prices.length ? prices[Math.floor(prices.length / 2)] : null;

console.log(`  All ${accepted.length} rows are valid.\n`);
console.log(`  ${accepted.length} listings, ${accepted.reduce((n, r) => n + r.photos.length, 0)} photographs`);
console.log(`  ${withPrice.length} priced, ${accepted.length - withPrice.length} price on call`);
if (median !== null) console.log(`  Median price: PKR ${median.toLocaleString("en-PK")}`);
console.log(
  `  Makes: ${[...new Set(accepted.map((r) => r.make))].join(", ")}`,
);
console.log(
  `  Years: ${Math.min(...accepted.map((r) => r.year))} to ${Math.max(...accepted.map((r) => r.year))}`,
);

const missingPhotos = accepted.filter((r) => r.photos.length < 4);
if (missingPhotos.length) {
  console.log(`\n  ${missingPhotos.length} listing(s) carry fewer than four photographs.`);
  console.log(`  Update the seller: buyers skip ads with one or two pictures.`);
}

if (args.dryRun) {
  console.log(`\n  Dry run. Nothing written. Drop --dry-run and add --out <file.sql> to emit SQL.\n`);
  process.exit(0);
}

const dealerUpsert = `-- The dealer record, created if it does not exist.
--
-- owner_id stays null: this is a business record created by us, on the dealer's written authority, and
-- it gets claimed later when the owner signs up and we set owner_id. Migration 0004 made that legal.
insert into public.dealers (name, slug, city_id)
values (
  ${q(args.dealerName)},
  ${q(args.dealer)},
  (select id from public.cities where slug = ${q(args.city)})
)
on conflict (slug) do nothing;`;

const sql = [
  `-- RELCO Wheels, dealer stock import`,
  `-- Source: ${path.basename(csvPath)}`,
  `-- Dealer: ${args.dealer} (${args.dealerName})`,
  `-- Generated: ${new Date().toISOString()}`,
  ...(isTemplate
    ? [
        `--`,
        `-- ==========================================================================`,
        `--   THE TEMPLATE CSV, REHEARSED. EVERY CAR IN THIS FILE IS INVENTED, AND`,
        `--   SO IS THE DEALER. RUN IT NOWHERE BUT THE TEST HARNESS.`,
        `--`,
        `--   This banner appears because the input was dealer-stock-template.csv.`,
        `--   A real dealer's file does not produce it.`,
        `-- ==========================================================================`,
      ]
    : []),
  `--`,
  `-- Before running this, confirm that ${args.dealer} has authorised us in writing to publish this`,
  `-- stock, and that they own the photographs. See docs/dealer-onboarding.md.`,
  `--`,
  `-- Photographs are assumed to be uploaded already, to dealers/${args.dealer}/ in Supabase Storage.`,
  ``,
  `begin;`,
  ``,
  dealerUpsert,
  ``,
  ...accepted.map((r) => listingSql(r, args.dealer)),
  ``,
  `commit;`,
  ``,
].join("\n");

const outPath = path.resolve(args.out ?? `stock/${args.dealer}-import.sql`);
fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(outPath, sql);

console.log(`\n  Wrote ${outPath}`);
console.log(`  ${(sql.length / 1024).toFixed(1)} KB, ${accepted.length} statements inside one transaction.`);
console.log(`\n  Next:`);
console.log(`    1. Upload the photographs to Supabase Storage under dealers/${args.dealer}/`);
console.log(`    2. Run the file in the Supabase SQL editor`);
console.log(`    3. Check that every listing appears at /cars\n`);
