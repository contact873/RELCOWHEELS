/**
 * Manufacturer specification sheets, by model.
 *
 * Everything here is a FACT about a product, recorded with its source and the date it was read,
 * because a price or a specification without a date is a claim with no shelf life. Facts are not
 * protected expression, so they may be recorded; the manufacturer's photographs, brochure and
 * descriptive wording are not, and none of them appear here.
 *
 * One deliberate gap. The compression ratio on the published sheet extracts as a garbled fraction
 * (0.417 instead of a ratio like 9.5:1), so it is omitted rather than printed wrong. A number that
 * looks authoritative and is wrong is worse than an absent one.
 */

export interface SpecRow {
  label: string;
  value: string;
}

export interface SpecGroup {
  group: string;
  rows: SpecRow[];
}

export interface ComparisonRow {
  group: string;
  feature: string;
  /** One entry per column, in the same order as `columns`. A boolean renders as a tick. */
  values: (boolean | string)[];
}

export interface ModelSheet {
  make: string;
  model: string;
  makeSlug: string;
  modelSlug: string;
  /** The date the manufacturer's published figures were read. */
  asOf: string;
  source: string;
  columns: string[];
  newPricesPkr: Record<string, number>;
  specs: SpecGroup[];
  comparison: ComparisonRow[];
  notes: string[];
}

const ALTO: ModelSheet = {
  make: "Suzuki",
  model: "Alto",
  makeSlug: "suzuki",
  modelSlug: "alto",
  asOf: "2026-10-31",
  source: "suzukipakistan.com product page and the published Alto specification sheet",
  columns: ["Alto VXR", "Alto VXR-AGS", "Alto VXL-AGS"],
  newPricesPkr: {
    "Alto VXR": 2_994_861,
    "Alto VXR-AGS": 3_166_480,
    "Alto VXL-AGS": 3_326_446,
  },
  specs: [
    {
      group: "Dimensions",
      rows: [
        { label: "Overall length", value: "3,395 mm" },
        { label: "Overall width", value: "1,475 mm" },
        { label: "Overall height", value: "1,490 mm" },
        { label: "Wheelbase", value: "2,460 mm" },
        { label: "Track, front and rear", value: "1,305 mm / 1,310 mm" },
        { label: "Minimum ground clearance", value: "170 mm" },
        { label: "Minimum turning radius", value: "4.2 m" },
        { label: "Gross vehicle weight", value: "1,050 kg" },
      ],
    },
    {
      group: "Engine",
      rows: [
        { label: "Engine code", value: "R06A" },
        { label: "Displacement", value: "658 cc" },
        { label: "Valves", value: "12" },
        { label: "Bore and stroke", value: "64.0 x 68.2 mm" },
        { label: "Maximum output", value: "29 kW at 6,500 rpm" },
        { label: "Maximum torque", value: "56 Nm at 4,000 rpm" },
      ],
    },
    {
      group: "Capacity and transmission",
      rows: [
        { label: "Fuel tank", value: "27 litres" },
        { label: "Seating", value: "4" },
        { label: "Drive", value: "Front wheel drive" },
        { label: "Gearbox", value: "5 speed manual, or AGS on the automatic" },
      ],
    },
    {
      group: "Suspension, brakes and tyres",
      rows: [
        { label: "Front suspension", value: "MacPherson strut with coil spring" },
        { label: "Rear suspension", value: "Torsion beam with coil spring" },
        { label: "Front brakes", value: "Solid disc" },
        { label: "Rear brakes", value: "Drum, leading and trailing" },
        { label: "Tyres", value: "145/80 R13" },
      ],
    },
  ],
  comparison: [
    { group: "Safety", feature: "Dual airbags", values: [true, true, true] },
    { group: "Safety", feature: "ABS", values: [true, true, true] },
    { group: "Safety", feature: "Front seat belt force limiters", values: [true, true, true] },
    { group: "Safety", feature: "Front disc brakes", values: [true, true, true] },
    { group: "Safety", feature: "Immobiliser", values: [true, true, true] },
    { group: "Safety", feature: "Childproof rear door locks", values: [true, true, true] },
    { group: "Safety", feature: "Hill hold control", values: [true, true, true] },
    { group: "Safety", feature: "Seat belt reminder, lamp and buzzer", values: [true, true, true] },
    { group: "Safety", feature: "Pinch guard, driver window", values: [true, true, true] },
    { group: "Safety", feature: "Seat belt pretensioners, both front", values: [true, true, true] },
    { group: "Safety", feature: "ISOFIX lower anchors", values: [true, true, true] },
    { group: "Safety", feature: "High mounted stop lamp", values: [true, true, true] },
    { group: "Comfort", feature: "Air conditioning", values: [true, true, true] },
    { group: "Comfort", feature: "Heater", values: [true, true, true] },
    { group: "Comfort", feature: "Front defroster and side demister", values: [true, true, true] },
    { group: "Comfort", feature: "Audio", values: ["2 Din", "2 Din", "Touch screen"] },
    { group: "Comfort", feature: "Speakers", values: ["Front 2", "Front 2", "Front 2"] },
    { group: "Comfort", feature: "Keyless entry", values: [true, true, true] },
    { group: "Comfort", feature: "Security system", values: [true, true, true] },
    { group: "Comfort", feature: "Central locking", values: [true, true, true] },
    { group: "Comfort", feature: "Power windows, front and rear", values: ["Both", "Both", "Both"] },
    { group: "Comfort", feature: "Power steering", values: [true, true, true] },
    { group: "Instrument panel", feature: "Low fuel warning lamp", values: [true, true, true] },
    { group: "Instrument panel", feature: "Accessory socket", values: [true, true, true] },
    { group: "Instrument panel", feature: "Door ajar warning light", values: [true, true, true] },
    { group: "Instrument panel", feature: "Side louvre accent", values: [true, true, true] },
    { group: "Instrument panel", feature: "Glove box lid", values: [true, true, true] },
    { group: "Instrument panel", feature: "Dial type climate control", values: [true, true, true] },
  ],
  notes: [
    "Compression ratio is omitted. The published sheet extracts as 0.417 rather than a ratio, and a wrong number with a citation is worse than a gap.",
    "The published comparison shows one row differing across the three variants, which is the audio unit. Everything else is identical across the range.",
  ],
};

const SHEETS: ModelSheet[] = [ALTO];

export function getModelSheet(makeSlug: string, modelSlug: string): ModelSheet | null {
  return SHEETS.find((s) => s.makeSlug === makeSlug && s.modelSlug === modelSlug) ?? null;
}

/** Only rows where the published values are not all identical. Used to lead with the difference. */
export function differingRows(sheet: ModelSheet): ComparisonRow[] {
  return sheet.comparison.filter((row) => {
    const seen = new Set(row.values.map((v) => String(v)));
    return seen.size > 1;
  });
}

export const MODELS_WITH_SHEETS = SHEETS.map((s) => ({
  makeSlug: s.makeSlug,
  modelSlug: s.modelSlug,
}));
