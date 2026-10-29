/**
 * Size of the vehicle catalogue.
 *
 * GENERATED FILE. Written by tools/seed-catalogue.mjs from data/catalogue.json, and overwritten
 * whole every time it runs, so edits here are lost. Regenerate with:
 *
 *   node tools/seed-catalogue.mjs --out data/catalogue.sql
 *
 * These are catalogue facts, not listing counts. The catalogue holds 22 makes whether or not
 * anybody is selling one today, and a page showing these numbers has to say which they are.
 * Listing counts are always derived from listings, never from here.
 *
 * Source: 22 makes, 71 models, 117 variants.
 */

export const CATALOGUE_FACTS = {
  makes: 22,
  models: 71,
  variants: 117,
} as const;
