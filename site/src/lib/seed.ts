import type { Article, ForumCategory, ForumThread, Listing, PublicProfile } from "./types";

/**
 * SAMPLE CONTENT. Not real listings, and not a scraped copy of anybody else's listings.
 *
 * Every car below is invented, in the shape of the Lahore market rather than copied from it. The
 * three photographs in the repository are real car photographs owned by this business, but nobody
 * has confirmed which car each one shows, so none of them is attached to anything. Every listing
 * and every article falls back to a labelled placeholder panel.
 *
 * That is deliberate, and it replaces behaviour that was wrong. The first version of this file
 * cycled the three photographs across the listings, which is how a Honda Civic came to be
 * illustrated with a Mercedes. A photograph on a listing is not decoration: it is evidence about
 * the particular car being sold, so a picture of a different car is a false claim rather than a
 * placeholder. See PHOTOS below for how a photograph is brought into service.
 *
 * The site renders a "Sample content" banner for as long as it is running on this file. See
 * src/components/sample-notice.tsx. Real stock arrives through tools/import-dealer-stock.mjs or
 * through /sell, and only after the dealer has authorised it in writing. See
 * docs/dealer-onboarding.md.
 *
 * Counts on the browse pages are derived from this file rather than written by hand, so nothing on
 * the site claims a number the data does not support.
 */

/**
 * What each photograph shows, and therefore which listing may use it.
 *
 * A listing may only carry a photograph of the car it is selling, so a photograph is named by its
 * subject before it can be used. `subject` is the make and model exactly as they appear in ROWS
 * below, joined by a single space, for example `"Suzuki Alto"`.
 *
 * `null` means nobody has confirmed what the picture shows. It is then shown nowhere: not on a
 * listing, not as an article cover. All three are null at the moment, which is why the site is
 * currently illustrated entirely by placeholder panels.
 *
 * To bring one into service, look at the file and fill in its subject. The listings whose make and
 * model match will pick it up on the next build, in this order, capped at how many photographs that
 * listing declares. If no listing matches, it stays unused, which is the correct outcome: a
 * photograph of a car nobody is selling is still not evidence about any car that is.
 */
const PHOTOS: { path: string; subject: string | null }[] = [
  { path: "/cars/13-1.jpg", subject: null },
  { path: "/cars/10-3.jpg", subject: null },
  { path: "/cars/11-2.jpg", subject: null },
];

function photosFor(make: string, model: string, supplied: number) {
  if (supplied <= 0) return [];
  return PHOTOS.filter((p) => p.subject === `${make} ${model}`)
    .slice(0, supplied)
    .map((p, i) => ({ path: p.path, alt: `${make} ${model}, photograph ${i + 1}` }));
}

/**
 * The same three photographs, used as illustration rather than as evidence.
 *
 * The distinction is the whole point, and it is why these can be used while PHOTOS above cannot. A
 * photograph attached to a listing is a claim about that car, so it has to depict it. An article
 * cover is decoration: nobody reads it as a picture of the car the article is about, the way they
 * read a listing thumbnail as a picture of the car being sold.
 *
 * Both blog pages render these with an empty alt, and that is the mechanism rather than laziness.
 * An empty alt marks the image decorative, so a screen reader passes over it instead of announcing
 * a car the article is not about. Give one of these a real caption and it starts making a claim,
 * which is the thing it cannot support.
 */
const ILLUSTRATION_PHOTOS = ["/cars/13-1.jpg", "/cars/10-3.jpg", "/cars/11-2.jpg"];

interface Row {
  ref: string;
  make: string;
  model: string;
  variant: string;
  year: number;
  /** null means price on call */
  price: number | null;
  mileage: number | null;
  cc: number | null;
  trans: "manual" | "automatic" | null;
  fuel: "petrol" | "diesel" | "hybrid" | "electric" | null;
  body: string;
  city: string;
  area: string | null;
  owners: number | null;
  accidental: boolean;
  /** imported cars carry an auction sheet */
  sheet: boolean;
  status: "live" | "sold";
  /** how many real photographs to attach. 0 renders the placeholder panel. */
  photos: number;
  /** inspection overall score out of ten, or null if not inspected */
  score: number | null;
  features: string[];
  seller: string;
  daysAgo: number;
  soldPrice?: number;
}

const ROWS: Row[] = [
  { ref: "RW-1042", make: "Suzuki", model: "Alto", variant: "VXL AGS", year: 2019, price: 2345000, mileage: 55400, cc: 660, trans: "automatic", fuel: "petrol", body: "Hatchback", city: "lahore", area: "Johar Town", owners: 2, accidental: false, sheet: false, status: "live", photos: 2, score: 8.4, features: ["alloy_wheels", "power_windows", "airbags", "immobilizer", "climate_control"], seller: "bilal_cheema", daysAgo: 2 },
  { ref: "RW-1043", make: "Honda", model: "Civic", variant: "Oriel 1.8 i-VTEC CVT", year: 2016, price: 5590000, mileage: 68000, cc: 1800, trans: "automatic", fuel: "petrol", body: "Sedan", city: "lahore", area: "DHA Phase 5", owners: 1, accidental: false, sheet: false, status: "live", photos: 3, score: 7.9, features: ["sun_roof", "alloy_wheels", "cruise_control", "climate_control", "airbags", "abs", "rear_camera", "infotainment"], seller: "ayesha_t", daysAgo: 1 },
  { ref: "RW-1044", make: "KIA", model: "Sportage", variant: "AWD", year: 2021, price: 10750000, mileage: 43900, cc: 2000, trans: "automatic", fuel: "petrol", body: "SUV", city: "lahore", area: "DHA Phase 8", owners: 1, accidental: false, sheet: false, status: "live", photos: 2, score: 9.1, features: ["led_headlights", "alloy_wheels", "rear_camera", "cruise_control", "climate_control", "airbags", "abs", "traction_control", "lane_assist"], seller: "zahid_autos", daysAgo: 4 },
  { ref: "RW-1045", make: "Toyota", model: "Corolla", variant: "GLi 1.3 VVTi", year: 2008, price: 1975000, mileage: 214000, cc: 1300, trans: "manual", fuel: "petrol", body: "Sedan", city: "lahore", area: "Township", owners: 3, accidental: true, sheet: false, status: "live", photos: 2, score: 5.2, features: ["power_windows", "immobilizer"], seller: "naveed_anwar", daysAgo: 5 },
  { ref: "RW-1046", make: "Toyota", model: "Land Cruiser", variant: "V8 ZX", year: 2013, price: null, mileage: 96000, cc: 4600, trans: "automatic", fuel: "petrol", body: "SUV", city: "lahore", area: "Gulberg III", owners: 2, accidental: false, sheet: true, status: "live", photos: 2, score: 8.8, features: ["sun_roof", "led_headlights", "infotainment", "rear_camera", "cruise_control", "climate_control", "airbags", "abs", "traction_control"], seller: "ibrar_h", daysAgo: 7 },
  { ref: "RW-1047", make: "Suzuki", model: "Mehran", variant: "VXR Euro II", year: 2012, price: 1320000, mileage: 148000, cc: 800, trans: "manual", fuel: "petrol", body: "Hatchback", city: "lahore", area: "Ichhra", owners: 2, accidental: false, sheet: false, status: "sold", photos: 1, score: 6.1, features: ["immobilizer"], seller: "bilal_cheema", daysAgo: 45, soldPrice: 1320000 },
  { ref: "RW-1048", make: "Toyota", model: "Corolla", variant: "Altis 1.6 Automatic", year: 2018, price: 4850000, mileage: 194000, cc: 1600, trans: "automatic", fuel: "petrol", body: "Sedan", city: "lahore", area: "Johar Town", owners: 2, accidental: false, sheet: false, status: "live", photos: 3, score: 7.1, features: ["alloy_wheels", "climate_control", "airbags", "abs", "power_windows"], seller: "zahid_autos", daysAgo: 3 },
  { ref: "RW-1049", make: "Honda", model: "City", variant: "1.3 i-VTEC Prosmatec", year: 2019, price: 3990000, mileage: 79000, cc: 1300, trans: "automatic", fuel: "petrol", body: "Sedan", city: "lahore", area: "Gulberg II", owners: 1, accidental: false, sheet: false, status: "live", photos: 2, score: 8.2, features: ["alloy_wheels", "power_windows", "airbags", "abs", "immobilizer"], seller: "zahid_autos", daysAgo: 6 },
  { ref: "RW-1050", make: "Suzuki", model: "Cultus", variant: "VXL", year: 2019, price: 3150000, mileage: 58000, cc: 1000, trans: "manual", fuel: "petrol", body: "Hatchback", city: "lahore", area: "Gulberg III", owners: 1, accidental: false, sheet: false, status: "live", photos: 0, score: 8.6, features: ["power_windows", "airbags", "immobilizer", "climate_control"], seller: "zahid_autos", daysAgo: 8 },
  { ref: "RW-1051", make: "Toyota", model: "Prius", variant: "S Touring Selection", year: 2017, price: 6750000, mileage: 71000, cc: 1800, trans: "automatic", fuel: "hybrid", body: "Hatchback", city: "lahore", area: "DHA Phase 6", owners: 1, accidental: false, sheet: true, status: "live", photos: 0, score: 8.9, features: ["led_headlights", "rear_camera", "cruise_control", "climate_control", "airbags", "abs", "infotainment"], seller: "ibrar_h", daysAgo: 9 },
  { ref: "RW-1052", make: "Honda", model: "Vezel", variant: "X Honda Sensing", year: 2019, price: 6900000, mileage: 52000, cc: 1500, trans: "automatic", fuel: "hybrid", body: "Crossover", city: "lahore", area: "Bahria Town", owners: 1, accidental: false, sheet: true, status: "live", photos: 0, score: 9.0, features: ["led_headlights", "rear_camera", "lane_assist", "cruise_control", "climate_control", "airbags", "abs"], seller: "ibrar_h", daysAgo: 11 },
  { ref: "RW-1053", make: "Daihatsu", model: "Mira", variant: "L SA III", year: 2020, price: 4250000, mileage: 39000, cc: 660, trans: "automatic", fuel: "petrol", body: "Hatchback", city: "lahore", area: "Johar Town", owners: 1, accidental: false, sheet: true, status: "live", photos: 0, score: 9.2, features: ["led_headlights", "rear_camera", "airbags", "abs", "immobilizer"], seller: "ibrar_h", daysAgo: 12 },
  { ref: "RW-1054", make: "Toyota", model: "Yaris", variant: "ATIV X CVT 1.5", year: 2021, price: 4590000, mileage: 34000, cc: 1500, trans: "automatic", fuel: "petrol", body: "Sedan", city: "lahore", area: "Faisal Town", owners: 1, accidental: false, sheet: false, status: "live", photos: 0, score: 9.3, features: ["alloy_wheels", "rear_camera", "cruise_control", "climate_control", "airbags", "abs", "power_windows"], seller: "ayesha_t", daysAgo: 13 },
  { ref: "RW-1055", make: "Hyundai", model: "Tucson", variant: "FWD GLS Sport", year: 2021, price: 9850000, mileage: 48000, cc: 2000, trans: "automatic", fuel: "petrol", body: "SUV", city: "lahore", area: "Askari X", owners: 1, accidental: false, sheet: false, status: "live", photos: 0, score: 8.7, features: ["led_headlights", "alloy_wheels", "rear_camera", "cruise_control", "climate_control", "airbags", "abs", "traction_control"], seller: "zahid_autos", daysAgo: 14 },
  { ref: "RW-1056", make: "Suzuki", model: "Every", variant: "Join", year: 2018, price: 3450000, mileage: 88000, cc: 660, trans: "automatic", fuel: "petrol", body: "Van", city: "lahore", area: "Township", owners: 1, accidental: false, sheet: true, status: "live", photos: 0, score: 7.8, features: ["power_windows", "airbags", "immobilizer"], seller: "naveed_anwar", daysAgo: 16 },
  { ref: "RW-1057", make: "Suzuki", model: "Wagon R", variant: "VXL", year: 2022, price: 2980000, mileage: 27000, cc: 1000, trans: "manual", fuel: "petrol", body: "Hatchback", city: "lahore", area: "Wapda Town", owners: 1, accidental: false, sheet: false, status: "live", photos: 0, score: 9.4, features: ["airbags", "abs", "immobilizer", "power_windows", "climate_control"], seller: "zahid_autos", daysAgo: 18 },
  { ref: "RW-1058", make: "Changan", model: "Oshan X7", variant: "Comfort", year: 2024, price: 7850000, mileage: 18000, cc: 1500, trans: "automatic", fuel: "petrol", body: "SUV", city: "lahore", area: "DHA Phase 5", owners: 1, accidental: false, sheet: false, status: "live", photos: 0, score: 9.5, features: ["led_headlights", "rear_camera", "cruise_control", "climate_control", "airbags", "abs", "traction_control", "lane_assist", "infotainment"], seller: "ayesha_t", daysAgo: 19 },
  { ref: "RW-1059", make: "MG", model: "HS", variant: "1.5 Turbo", year: 2021, price: 5850000, mileage: 61000, cc: 1500, trans: "automatic", fuel: "petrol", body: "SUV", city: "lahore", area: "Johar Town", owners: 1, accidental: false, sheet: false, status: "live", photos: 0, score: 8.5, features: ["led_headlights", "alloy_wheels", "rear_camera", "climate_control", "airbags", "abs"], seller: "zahid_autos", daysAgo: 21 },
  { ref: "RW-1060", make: "Nissan", model: "Dayz", variant: "Highway Star", year: 2019, price: 3850000, mileage: 44000, cc: 660, trans: "automatic", fuel: "petrol", body: "Hatchback", city: "lahore", area: "Gulberg III", owners: 1, accidental: false, sheet: true, status: "live", photos: 0, score: 9.0, features: ["led_headlights", "rear_camera", "lane_assist", "airbags", "abs", "immobilizer"], seller: "ibrar_h", daysAgo: 23 },
  { ref: "RW-1061", make: "Toyota", model: "Fortuner", variant: "2.8 Sigma 4", year: 2018, price: 10950000, mileage: 112000, cc: 2800, trans: "automatic", fuel: "diesel", body: "SUV", city: "lahore", area: "DHA Phase 8", owners: 2, accidental: false, sheet: false, status: "live", photos: 0, score: 7.6, features: ["alloy_wheels", "rear_camera", "cruise_control", "climate_control", "airbags", "abs", "traction_control"], seller: "ibrar_h", daysAgo: 25 },
  { ref: "RW-1062", make: "KIA", model: "Picanto", variant: "1.0 Automatic", year: 2020, price: 3650000, mileage: 42000, cc: 1000, trans: "automatic", fuel: "petrol", body: "Hatchback", city: "lahore", area: "Model Town", owners: 1, accidental: false, sheet: false, status: "live", photos: 0, score: 8.8, features: ["rear_camera", "climate_control", "airbags", "abs", "power_windows"], seller: "zahid_autos", daysAgo: 27 },
  { ref: "RW-1063", make: "Honda", model: "BR-V", variant: "i-VTEC S", year: 2019, price: 5450000, mileage: 74000, cc: 1500, trans: "manual", fuel: "petrol", body: "SUV", city: "lahore", area: "Green Town", owners: 2, accidental: false, sheet: false, status: "live", photos: 0, score: 7.4, features: ["rear_camera", "climate_control", "airbags", "abs", "power_windows", "immobilizer"], seller: "naveed_anwar", daysAgo: 29 },
  { ref: "RW-1064", make: "Mercedes Benz", model: "E Class", variant: "E200", year: 2014, price: 9150000, mileage: 98000, cc: 2000, trans: "automatic", fuel: "petrol", body: "Sedan", city: "islamabad", area: "F-7", owners: 2, accidental: false, sheet: true, status: "live", photos: 0, score: 7.9, features: ["led_headlights", "alloy_wheels", "infotainment", "rear_camera", "cruise_control", "climate_control", "airbags", "abs", "traction_control"], seller: "ibrar_h", daysAgo: 31 },
  { ref: "RW-1065", make: "Toyota", model: "Prado", variant: "TX L Package 2.7", year: 2019, price: 23900000, mileage: 75000, cc: 2700, trans: "automatic", fuel: "petrol", body: "SUV", city: "islamabad", area: "E-11", owners: 1, accidental: false, sheet: true, status: "live", photos: 0, score: 9.1, features: ["sun_roof", "led_headlights", "alloy_wheels", "rear_camera", "cruise_control", "climate_control", "airbags", "abs", "traction_control"], seller: "ibrar_h", daysAgo: 33 },
  { ref: "RW-1066", make: "Suzuki", model: "Alto", variant: "VXR", year: 2021, price: 2725000, mileage: 33000, cc: 660, trans: "manual", fuel: "petrol", body: "Hatchback", city: "karachi", area: "Clifton", owners: 1, accidental: false, sheet: false, status: "sold", photos: 0, score: 8.9, features: ["airbags", "immobilizer", "power_windows"], seller: "zahid_autos", daysAgo: 60, soldPrice: 2680000 },
  { ref: "RW-1067", make: "Toyota", model: "Hiace", variant: "Standard", year: 2016, price: 5950000, mileage: 156000, cc: 2700, trans: "manual", fuel: "diesel", body: "Van", city: "lahore", area: "Badami Bagh", owners: 2, accidental: false, sheet: true, status: "sold", photos: 0, score: 6.8, features: ["power_windows", "immobilizer"], seller: "naveed_anwar", daysAgo: 74, soldPrice: 5720000 },
];

const CITY_NAMES: Record<string, string> = {
  lahore: "Lahore",
  karachi: "Karachi",
  islamabad: "Islamabad",
  rawalpindi: "Rawalpindi",
  faisalabad: "Faisalabad",
  multan: "Multan",
};

function slugify(v: string) {
  return v.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "");
}

function daysAgoIso(days: number) {
  const d = new Date();
  d.setDate(d.getDate() - days);
  d.setHours(9, 30, 0, 0);
  return d.toISOString();
}

const SELLERS: Record<string, { name: string; role: "member" | "dealer"; dealer: boolean }> = {
  bilal_cheema: { name: "Bilal Cheema", role: "member", dealer: false },
  ayesha_t: { name: "Ayesha Tariq", role: "member", dealer: false },
  naveed_anwar: { name: "Naveed Anwar", role: "member", dealer: false },
  zahid_autos: { name: "Zahid Autos", role: "dealer", dealer: true },
  ibrar_h: { name: "Ibrar Hussain", role: "dealer", dealer: true },
};

function buildListings(): Listing[] {
  return ROWS.map((r, i) => {
    const seller = SELLERS[r.seller];
    const id = 1042 + i;
    const photos = photosFor(r.make, r.model, r.photos);

    return {
      id,
      reference: r.ref,
      vertical: "car",
      slug: `${r.year}-${slugify(r.make)}-${slugify(r.model)}-${r.city}-${id}`,
      title: `${r.make} ${r.model} ${r.variant} ${r.year}`,
      description: null,
      makeName: r.make,
      makeSlug: slugify(r.make),
      modelName: r.model,
      modelSlug: slugify(r.model),
      variantName: r.variant,
      modelYear: r.year,
      pricePkr: r.soldPrice ?? r.price,
      priceOnCall: r.price === null,
      mileageKm: r.mileage,
      engineCc: r.cc,
      transmission: r.trans,
      fuel: r.fuel,
      bodyType: r.body,
      color: null,
      assembly: r.sheet ? "imported" : "local",
      seats: r.body === "SUV" || r.body === "Van" ? 7 : 5,
      cityName: CITY_NAMES[r.city] ?? r.city,
      citySlug: r.city,
      areaName: r.area,
      registeredIn: CITY_NAMES[r.city] ?? r.city,
      status: r.status,
      ownerCount: r.owners,
      isAccidental: r.accidental,
      hasAuctionSheet: r.sheet,
      photos,
      featureKeys: r.features,
      inspection:
        r.score === null
          ? null
          : {
              overallScore: r.score,
              exterior: Math.min(100, Math.round(r.score * 10 - 6)),
              engine: Math.min(100, Math.round(r.score * 10 + 4)),
              suspension: Math.min(100, Math.round(r.score * 10 - 2)),
              interior: Math.min(100, Math.round(r.score * 10 + 1)),
              ac: Math.min(100, Math.round(r.score * 10 + 6)),
              inspectedOn: daysAgoIso(r.daysAgo + 3).slice(0, 10),
            },
      sellerName: seller.name,
      sellerHandle: r.seller,
      sellerRole: seller.role,
      sellerIsDealer: seller.dealer,
      publishedAt: daysAgoIso(r.daysAgo),
      updatedAt: daysAgoIso(Math.max(0, r.daysAgo - 1)),
      // Synthetic, and deliberately not rendered anywhere. Sample content cannot know how many
      // people looked at a listing, and an engagement figure invented for a demo reads as a fact
      // about real buyers. Kept in the shape so the database can fill it in later.
      viewCount: 240 + ((i * 137) % 2900),
      phoneRevealCount: 4 + ((i * 17) % 84),
    } satisfies Listing;
  });
}

export const seedListings: Listing[] = buildListings();

export function liveListings(): Listing[] {
  return seedListings.filter((l) => l.status === "live");
}

export function soldListings(): Listing[] {
  return seedListings.filter((l) => l.status === "sold");
}

/**
 * Derived from the data, never hand written. A browse page that claims 214 Suzukis when the seed
 * holds five is exactly the kind of invented precision that makes a site untrustworthy.
 */
export function countByMake(): { name: string; slug: string; count: number }[] {
  const map = new Map<string, { name: string; slug: string; count: number }>();
  for (const l of liveListings()) {
    const cur = map.get(l.makeSlug) ?? { name: l.makeName, slug: l.makeSlug, count: 0 };
    cur.count += 1;
    map.set(l.makeSlug, cur);
  }
  return [...map.values()].sort((a, b) => b.count - a.count || a.name.localeCompare(b.name));
}

export function countByCity(): { name: string; slug: string; count: number }[] {
  const map = new Map<string, { name: string; slug: string; count: number }>();
  for (const l of liveListings()) {
    const cur = map.get(l.citySlug) ?? { name: l.cityName, slug: l.citySlug, count: 0 };
    cur.count += 1;
    map.set(l.citySlug, cur);
  }
  return [...map.values()].sort((a, b) => b.count - a.count || a.name.localeCompare(b.name));
}

/**
 * Body type, counted from live listings rather than from the catalogue.
 *
 * Deliberate, and it matters. The catalogue holds eight body types; only five have cars listed
 * against them. A tile reading "SUV 40" because the catalogue knows forty SUV variants, sitting on
 * a page where clicking it returns four cars, is the same class of lie as a photograph of the wrong
 * car. A tile says how many are listed, so it counts listings.
 *
 * Ordered by BODY_TYPES rather than by count, so the tiles hold their position on every build and
 * a returning buyer's muscle memory keeps working.
 */
export function countByBody(): { name: string; slug: string; count: number }[] {
  const map = new Map<string, { name: string; slug: string; count: number }>();
  for (const l of liveListings()) {
    if (!l.bodyType) continue;
    const slug = slugify(l.bodyType);
    const cur = map.get(slug) ?? { name: l.bodyType, slug, count: 0 };
    cur.count += 1;
    map.set(slug, cur);
  }
  const rank = (name: string) => {
    const i = BODY_TYPES.findIndex((x: string) => x.toLowerCase() === name.toLowerCase());
    return i === -1 ? BODY_TYPES.length : i;
  };
  return [...map.values()].sort((a, b) => rank(a.name) - rank(b.name) || a.name.localeCompare(b.name));
}

export const BUDGET_BANDS: { label: string; slug: string; under: number }[] = [
  { label: "Under 20 lakh", slug: "under-20-lakh", under: 2_000_000 },
  { label: "Under 30 lakh", slug: "under-30-lakh", under: 3_000_000 },
  { label: "Under 50 lakh", slug: "under-50-lakh", under: 5_000_000 },
  { label: "Under 80 lakh", slug: "under-80-lakh", under: 8_000_000 },
  { label: "Under 1 crore", slug: "under-1-crore", under: 10_000_000 },
];

export const BODY_TYPES = ["Sedan", "Hatchback", "SUV", "Crossover", "Van"] as const;

/**
 * One line per body type for the tiles. Plain language on purpose: this is the first browse step
 * for somebody who does not know what a crossover is, and "a car platform with a taller body" is
 * not an answer.
 */
export const BODY_BLURBS: Record<string, string> = {
  Sedan: "Four doors and a boot. The family default.",
  Hatchback: "Short, easy to park, the cheapest to run.",
  SUV: "Higher seating, four wheel drive on most.",
  Crossover: "The SUV shape on a car platform.",
  Van: "Sliding doors and room for seven.",
};

export const seedProfiles: PublicProfile[] = [
  {
    handle: "bilal_cheema",
    displayName: "Bilal Cheema",
    role: "member",
    bio: "Two cars bought and sold here. I photograph the faults before I list anything, which is why the negotiating at the end is short.",
    cityName: "Lahore",
    avatarPath: null,
    joinedAt: "2026-03-11T10:00:00+05:00",
    listingCount: 2,
    threadCount: 14,
    postCount: 96,
    acceptedAnswers: 11,
  },
  {
    handle: "zahid_autos",
    displayName: "Zahid Autos",
    role: "dealer",
    bio: "Filters and parts on Main Boulevard since 2004. We also handle a small number of clean trade-ins.",
    cityName: "Lahore",
    avatarPath: null,
    joinedAt: "2026-04-02T09:00:00+05:00",
    listingCount: 9,
    threadCount: 3,
    postCount: 22,
    acceptedAnswers: 2,
  },
  {
    handle: "ibrar_h",
    displayName: "Ibrar Hussain",
    role: "dealer",
    bio: "Japanese imports, mostly grade 4 and above, with the original auction sheet kept with the car.",
    cityName: "Lahore",
    avatarPath: null,
    joinedAt: "2026-02-19T11:00:00+05:00",
    listingCount: 8,
    threadCount: 6,
    postCount: 41,
    acceptedAnswers: 5,
  },
];

// ---------------------------------------------------------------------------
// Forum
// ---------------------------------------------------------------------------

export const seedCategories: ForumCategory[] = [
  { id: 1, name: "Buying advice", slug: "buying-advice", description: "Deciding between two cars, what to look at first, and whether a price is fair.", threadCount: 46, position: 1 },
  { id: 2, name: "Inspection and condition", slug: "inspection", description: "Reading a sheet, understanding a grade, and what a score means for what you will pay.", threadCount: 31, position: 2 },
  { id: 3, name: "Selling advice", slug: "selling-advice", description: "Photography, pricing, and how long a car should take to move in this market.", threadCount: 24, position: 3 },
  { id: 4, name: "Ownership and running costs", slug: "ownership", description: "Fuel, parts, workshops, and what the third year of ownership actually costs.", threadCount: 58, position: 4 },
  { id: 5, name: "Japanese imports", slug: "japanese-imports", description: "Auction grades, shaken, landed cost, and what to check before the container is opened.", threadCount: 37, position: 5 },
  { id: 6, name: "Paperwork and transfer", slug: "paperwork", description: "Registration, transfer, token tax, and what to verify before money changes hands.", threadCount: 27, position: 6 },
];

export const seedThreads: ForumThread[] = [
  {
    id: 501,
    slug: "alto-2019-at-23-45-lakh-is-that-fair",
    title: "Alto VXL 2019 at 23.45 lakh, is that fair for Johar Town?",
    kind: "question",
    categorySlug: "buying-advice",
    categoryName: "Buying advice",
    bodyHtml:
      "<p>Looking at the VXL AGS listed here with 55,000 km on it. The owner is asking 23.45 lakh and will not move. Two owners, the last one since 2022, with a service record from the authorised workshop.</p><p>Comparable examples I am seeing run 22.8 to 24.1, so it sits in the middle. Anything specific I should check on a 2019 Alto before agreeing?</p>",
    authorHandle: "naveed_anwar",
    authorName: "Naveed Anwar",
    authorRole: "member",
    listingRef: "RW-1042",
    listingSlug: "2019-suzuki-alto-lahore-1042",
    listingTitle: "Suzuki Alto VXL AGS 2019",
    replyCount: 3,
    viewCount: 412,
    isPinned: false,
    isLocked: false,
    createdAt: daysAgoIso(2),
    lastReplyAt: daysAgoIso(0),
    posts: [
      {
        id: 9001, threadId: 501, parentPostId: null,
        bodyHtml:
          "<p>23.45 is fair if the AGS has never been apart. Ask for the transmission service invoice, not the engine one. If they cannot show it, budget about 90,000 for a rebuild somewhere in the next 20,000 km and price accordingly.</p><p>The other thing on these is the air conditioning compressor at around 60,000. The inspection sheet here scores it 96, so that one has been looked after.</p>",
        authorHandle: "bilal_cheema", authorName: "Bilal Cheema", authorRole: "member", authorPostCount: 96,
        isAcceptedAnswer: true, status: "visible", editedAt: null, editCount: 0, createdAt: daysAgoIso(2),
      },
      {
        id: 9002, threadId: 501, parentPostId: 9001,
        bodyHtml: "<p>The invoice is in the photographs, second one in the set. AGS fluid changed at 51,000. So I should be fine then.</p>",
        authorHandle: "naveed_anwar", authorName: "Naveed Anwar", authorRole: "member", authorPostCount: 14,
        isAcceptedAnswer: false, status: "visible", editedAt: daysAgoIso(1), editCount: 1, createdAt: daysAgoIso(1),
      },
      {
        id: 9003, threadId: 501, parentPostId: null,
        bodyHtml:
          "<p>One more thing. Get the underside looked at near the rear arches. Anything off the coast picks up surface rust there, and Johar Town has had a wet couple of months.</p>",
        authorHandle: "zahid_autos", authorName: "Zahid Autos", authorRole: "dealer", authorPostCount: 22,
        isAcceptedAnswer: false, status: "visible", editedAt: null, editCount: 0, createdAt: daysAgoIso(0),
      },
    ],
  },
  {
    id: 502,
    slug: "what-a-grade-4-5-actually-gets-you",
    title: "What a grade 4.5 auction sheet actually gets you",
    kind: "discussion",
    categorySlug: "japanese-imports",
    categoryName: "Japanese imports",
    bodyHtml:
      "<p>I have bought three imports on 4.5 sheets and the grade on its own tells you less than people think. What matters more is the interior and exterior letter scores underneath it, and whether the sheet maps any panel repairs.</p><p>Posting this because a 4.5 with a C interior is a different car from a 4.5 with an A, and the price difference is real.</p>",
    authorHandle: "ibrar_h", authorName: "Ibrar Hussain", authorRole: "dealer",
    listingRef: "RW-1052", listingSlug: "2019-honda-vezel-lahore-1052", listingTitle: "Honda Vezel X Honda Sensing 2019",
    replyCount: 2, viewCount: 1187, isPinned: true, isLocked: false,
    createdAt: daysAgoIso(11), lastReplyAt: daysAgoIso(1),
    posts: [
      {
        id: 9010, threadId: 502, parentPostId: null,
        bodyHtml: "<p>Agreed, and I would add the shaken date to that. A current shaken on an older car tells you more about how it was kept than the grade does.</p>",
        authorHandle: "bilal_cheema", authorName: "Bilal Cheema", authorRole: "member", authorPostCount: 96,
        isAcceptedAnswer: true, status: "visible", editedAt: null, editCount: 0, createdAt: daysAgoIso(10),
      },
      {
        id: 9011, threadId: 502, parentPostId: null,
        bodyHtml:
          "<p>Worth saying that an R or RA sheet is not automatically a walk away. It tells you there was damage and that it was repaired, and if the sheet names the panels you can see exactly what moved. That is more than any local classifieds will ever tell you.</p>",
        authorHandle: "ayesha_t", authorName: "Ayesha Tariq", authorRole: "member", authorPostCount: 8,
        isAcceptedAnswer: false, status: "visible", editedAt: null, editCount: 0, createdAt: daysAgoIso(1),
      },
    ],
  },
  {
    id: 503,
    slug: "working-out-the-real-landed-cost-of-a-vezel",
    title: "Working out the real landed cost of an imported Vezel",
    kind: "discussion",
    categorySlug: "japanese-imports",
    categoryName: "Japanese imports",
    bodyHtml:
      "<p>People quote the auction price and stop there. The number that matters is the one after freight, duty, clearing and the trip to Lahore. Posting my working so others can check it against theirs.</p>",
    authorHandle: "ibrar_h", authorName: "Ibrar Hussain", authorRole: "dealer",
    listingRef: null, listingSlug: null, listingTitle: null,
    replyCount: 1, viewCount: 884, isPinned: false, isLocked: false,
    createdAt: daysAgoIso(6), lastReplyAt: daysAgoIso(4),
    posts: [
      {
        id: 9020, threadId: 503, parentPostId: null,
        bodyHtml: "<p>This is the part nobody puts in an ad, and it is why two cars of the same grade sell 300,000 apart in the same showroom.</p>",
        authorHandle: "naveed_anwar", authorName: "Naveed Anwar", authorRole: "member", authorPostCount: 14,
        isAcceptedAnswer: false, status: "visible", editedAt: null, editCount: 0, createdAt: daysAgoIso(4),
      },
    ],
  },
  {
    id: 504,
    slug: "how-many-photographs-before-an-ad-works",
    title: "How many photographs before an ad actually works?",
    kind: "question",
    categorySlug: "selling-advice",
    categoryName: "Selling advice",
    bodyHtml:
      "<p>I listed with three pictures and got two calls in a week. Same car, twelve pictures, eight calls. That seems too big a jump to be about the car.</p>",
    authorHandle: "ayesha_t", authorName: "Ayesha Tariq", authorRole: "member",
    listingRef: null, listingSlug: null, listingTitle: null,
    replyCount: 2, viewCount: 655, isPinned: false, isLocked: false,
    createdAt: daysAgoIso(5), lastReplyAt: daysAgoIso(3),
    posts: [
      {
        id: 9030, threadId: 504, parentPostId: null,
        bodyHtml: "<p>It is not about the car. Buyers use the photographs to decide whether the seller is hiding something. Ten ordinary honest pictures beat two flattering ones, because ten says you have nothing to hide.</p>",
        authorHandle: "bilal_cheema", authorName: "Bilal Cheema", authorRole: "member", authorPostCount: 96,
        isAcceptedAnswer: true, status: "visible", editedAt: null, editCount: 0, createdAt: daysAgoIso(4),
      },
      {
        id: 9031, threadId: 504, parentPostId: null,
        bodyHtml: "<p>Shoot in daylight with the car clean, and include the interior and the engine bay. Nobody skips a car because the engine bay looked honest, but plenty walk away from a listing that does not show one.</p>",
        authorHandle: "zahid_autos", authorName: "Zahid Autos", authorRole: "dealer", authorPostCount: 22,
        isAcceptedAnswer: false, status: "visible", editedAt: null, editCount: 0, createdAt: daysAgoIso(3),
      },
    ],
  },
  {
    id: 505,
    slug: "transfer-papers-in-punjab-what-to-check",
    title: "Transfer papers in Punjab, what to check before you pay",
    kind: "discussion",
    categorySlug: "paperwork",
    categoryName: "Paperwork and transfer",
    bodyHtml:
      "<p>Form F, the defaced book, the biometric at the excise office, and the difference between the seller being registered and the seller being the owner. Writing down the order I check these in, because getting it wrong costs a month.</p>",
    authorHandle: "naveed_anwar", authorName: "Naveed Anwar", authorRole: "member",
    listingRef: null, listingSlug: null, listingTitle: null,
    replyCount: 1, viewCount: 1420, isPinned: false, isLocked: false,
    createdAt: daysAgoIso(9), lastReplyAt: daysAgoIso(7),
    posts: [
      {
        id: 9040, threadId: 505, parentPostId: null,
        bodyHtml: "<p>Add this: match the engine and chassis numbers on the book against the ones stamped on the car, in daylight, before any money moves. It takes four minutes and it catches the one problem you cannot fix later.</p>",
        authorHandle: "ibrar_h", authorName: "Ibrar Hussain", authorRole: "dealer", authorPostCount: 41,
        isAcceptedAnswer: true, status: "visible", editedAt: null, editCount: 0, createdAt: daysAgoIso(7),
      },
    ],
  },
  {
    id: 506,
    slug: "what-a-660cc-car-costs-in-its-third-year",
    title: "What a 660cc car actually costs in its third year",
    kind: "discussion",
    categorySlug: "ownership",
    categoryName: "Ownership and running costs",
    bodyHtml:
      "<p>Bought a Mira new to me in 2023. Posting the real numbers for fuel, servicing, the two parts that failed and insurance, because the asking price tells you nothing about the third year.</p>",
    authorHandle: "bilal_cheema", authorName: "Bilal Cheema", authorRole: "member",
    listingRef: null, listingSlug: null, listingTitle: null,
    replyCount: 1, viewCount: 967, isPinned: false, isLocked: false,
    createdAt: daysAgoIso(14), lastReplyAt: daysAgoIso(12),
    posts: [
      {
        id: 9050, threadId: 506, parentPostId: null,
        bodyHtml: "<p>Useful. The 660cc cars surprise people on the parts side: cheap to run in fuel, not always cheap to repair, because the parts come through fewer hands.</p>",
        authorHandle: "zahid_autos", authorName: "Zahid Autos", authorRole: "dealer", authorPostCount: 22,
        isAcceptedAnswer: false, status: "visible", editedAt: null, editCount: 0, createdAt: daysAgoIso(12),
      },
    ],
  },
];

// ---------------------------------------------------------------------------
// Blog
// ---------------------------------------------------------------------------

export const seedArticles: Article[] = [
  {
    id: 1,
    slug: "what-to-check-on-a-used-alto-before-you-buy",
    title: "What to check on a used Alto before you buy",
    dek: "The 660cc Alto is the most common car on the market and the one most often bought badly. Five things decide whether you have a good one.",
    bodyHtml:
      "<p>The Alto is the easiest car in Pakistan to buy and the easiest to buy badly. It is cheap enough that people skip the checks they would run on a Corolla, and the costs they inherit are identical.</p><h2>Ask for the transmission invoice, not the engine one</h2><p>On the automatic, the gearbox is fine when it has been serviced and expensive when it has not, and the entire difference is a single piece of paper.</p><h2>Test the air conditioning from cold</h2><p>They commonly fail at around 60,000 km. Switch it on the moment you arrive, not after a ten minute drive when the cabin has already cooled and the fault is invisible.</p><h2>Look at the rear arches with a torch</h2><p>Surface rust starts there on anything that spent time near the coast. Look up under the arch lip rather than at the paint.</p><h2>Prefer the service record to the mileage</h2><p>A 70,000 km car with a full authorised workshop history is a better buy than a 45,000 km car with none.</p><h2>Compare against live listings, not against a dealer's opinion of the market</h2><p>Same year, same trim, this month, in your city. That is the only comparison that means anything.</p>",
    status: "published",
    coverPath: ILLUSTRATION_PHOTOS[0],
    tags: ["buying", "suzuki", "inspection"],
    authorHandle: "bilal_cheema", authorName: "Bilal Cheema", isGuest: false,
    publishedAt: daysAgoIso(6), updatedAt: daysAgoIso(4), viewCount: 3412, readingMinutes: 4,
  },
  {
    id: 2,
    slug: "why-asking-prices-in-pakistan-are-not-sale-prices",
    title: "Why asking prices in Pakistan are not sale prices",
    dek: "A listed price is an opening position. Here is what the gap actually looks like, and how to use it when you negotiate.",
    bodyHtml:
      "<p>Every listing on every Pakistani car site shows an asking price, and almost none shows what the car sold for. That single omission is why buyers negotiate blind and sellers wait months.</p><p>Treat the asking price as evidence of the seller's expectation, not of the car's value. What a car actually changes hands for depends on the year, the trim, the condition result and how long the seller has been waiting, and the only comparison that means anything is against several live examples of the same car in the same month.</p><p>The habit that helps most: before you name a number, find three cars of the same year and trim listed in your city, and work from those rather than from the asking price in front of you.</p>",
    status: "published",
    coverPath: ILLUSTRATION_PHOTOS[1],
    tags: ["prices", "buying"],
    authorHandle: "relco_editors", authorName: "RELCO Wheels", isGuest: false,
    publishedAt: daysAgoIso(10), updatedAt: daysAgoIso(10), viewCount: 5921, readingMinutes: 3,
  },
  {
    id: 3,
    slug: "reading-a-japanese-auction-sheet",
    title: "Reading a Japanese auction sheet without being a dealer",
    dek: "The overall grade is the headline. The interior and exterior letters underneath it are where the money is.",
    bodyHtml:
      "<p>A grade 4.5 tells you the inspector thought the car was good. It does not tell you whether the interior is an A or a C, and those two cars are not worth the same money.</p><h2>The letter scores</h2><p>Interior and exterior are graded separately from A down to D. A car with a clean body and a tired cabin is priced like the cabin, not like the body.</p><h2>Panel markings</h2><p>The diagram records where the inspector found repairs. Two marked panels is not a disaster. Seven is a story, and the seller should be able to tell it.</p><h2>R and RA</h2><p>These mean the car had damage and it was repaired. They are disclosed, which is more than most local classifieds manage. Read which panels moved, and price accordingly.</p><h2>Shaken</h2><p>A current shaken on an older import tells you how the car has been kept, which is often more useful than the grade itself.</p>",
    status: "published",
    coverPath: ILLUSTRATION_PHOTOS[2],
    tags: ["imports", "inspection"],
    authorHandle: "ibrar_h", authorName: "Ibrar Hussain", isGuest: false,
    publishedAt: daysAgoIso(13), updatedAt: daysAgoIso(13), viewCount: 4188, readingMinutes: 5,
  },
  {
    id: 4,
    slug: "photographing-a-car-so-that-it-sells",
    title: "Photographing a car so that it sells",
    dek: "Twelve ordinary honest pictures beat three flattering ones. Here is the sequence that works, shot on a phone.",
    bodyHtml:
      "<p>Buyers read photographs as evidence about the seller, not only about the car. A short set looks like something is being hidden, even when nothing is.</p><h2>The twelve</h2><p>Front three quarter, rear three quarter, both sides square, front, rear, dashboard with the odometer readable, both front seats, the rear bench, the boot floor, the engine bay.</p><h2>Daylight, car clean, phone held level</h2><p>Overcast light is better than direct sun. Wash the car first: it is the cheapest improvement available and almost nobody does it.</p><h2>Do not crop to a fixed shape</h2><p>Leave the photographs at their own proportions. Cropping a car to a square hides the part somebody wants to see.</p><h2>Photograph the faults</h2><p>A photographed scratch costs you a small negotiation. An undiscovered scratch costs you the sale, the travel and the trust.</p>",
    status: "published",
    coverPath: ILLUSTRATION_PHOTOS[0],
    tags: ["selling"],
    authorHandle: "relco_editors", authorName: "RELCO Wheels", isGuest: false,
    publishedAt: daysAgoIso(17), updatedAt: daysAgoIso(17), viewCount: 2760, readingMinutes: 4,
  },
  {
    id: 5,
    slug: "what-the-third-year-of-ownership-costs",
    title: "What the third year of ownership actually costs",
    dek: "The asking price tells you nothing about the year the warranty stops mattering. Here is the shape of it.",
    bodyHtml:
      "<p>Almost every buyer works out the purchase price and stops. The third year is where the surprises sit, and they are predictable.</p><h2>Tyres and battery arrive together</h2><p>Carefully, around the third or fourth year, both. Budget for them rather than discovering them.</p><h2>Small imports cost more to repair than to run</h2><p>Fuel is cheap on a 660cc car. The parts come through fewer hands, so a single failure can cost more than a year of fuel.</p><h2>Suspension on Lahore roads</h2><p>Bushes and mounts are a running cost here, not a defect. A car with a fresh suspension refresh is worth paying a little more for.</p><h2>Keep the service record after the warranty ends</h2><p>It is what makes the car sellable in year five, and it costs nothing to keep.</p>",
    status: "published",
    coverPath: ILLUSTRATION_PHOTOS[1],
    tags: ["ownership"],
    authorHandle: "bilal_cheema", authorName: "Bilal Cheema", isGuest: false,
    publishedAt: daysAgoIso(21), updatedAt: daysAgoIso(21), viewCount: 3310, readingMinutes: 4,
  },
  {
    id: 6,
    slug: "what-we-do-not-claim",
    title: "What we do not claim",
    dek: "An inspection is a description of a car on one afternoon. It is not a warranty, and it is worth being blunt about the difference.",
    bodyHtml:
      "<p>An inspection records what a car was like on the day it was looked at. It is not a guarantee, and any site that implies otherwise is doing you no favours.</p><h2>What a condition score is</h2><p>An inspector's opinion, recorded on a date, across five areas. It is comparable between cars. It is not a prediction about yours.</p><h2>What it is not</h2><p>A warranty. A guarantee against anything failing next month. A substitute for looking at the car yourself, with your own eyes, before you pay.</p><h2>What we will not do</h2><p>We will not tell you a car is clean because a seller told us so. Where a car has not been inspected, the listing says so rather than showing an empty score that reads like a good one.</p>",
    status: "published",
    coverPath: ILLUSTRATION_PHOTOS[2],
    tags: ["inspection", "trust"],
    authorHandle: "relco_editors", authorName: "RELCO Wheels", isGuest: false,
    publishedAt: daysAgoIso(24), updatedAt: daysAgoIso(24), viewCount: 1877, readingMinutes: 3,
  },
];
