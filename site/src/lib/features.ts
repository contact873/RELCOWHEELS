/**
 * Feature labels and grouping.
 *
 * Keys match the `features` table in supabase/migrations/0001_init.sql, so a listing imported from
 * a dealer CSV or read from the database carries the same identifiers the seed data does. The
 * grouping is what stops a listing from rendering as one undifferentiated wall of chips.
 */

export type FeatureCategory = "exterior" | "interior" | "safety" | "comfort";

export const FEATURES: Record<string, { label: string; category: FeatureCategory }> = {
  alloy_wheels: { label: "Alloy wheels", category: "exterior" },
  fog_lights: { label: "Front fog lights", category: "exterior" },
  sun_roof: { label: "Sun roof", category: "exterior" },
  led_headlights: { label: "LED headlights", category: "exterior" },

  infotainment: { label: "Infotainment screen", category: "interior" },
  rear_camera: { label: "Reversing camera", category: "interior" },

  cruise_control: { label: "Cruise control", category: "comfort" },
  climate_control: { label: "Climate control", category: "comfort" },
  power_windows: { label: "Power windows", category: "comfort" },

  airbags: { label: "Air bags", category: "safety" },
  abs: { label: "ABS", category: "safety" },
  immobilizer: { label: "Immobiliser", category: "safety" },
  traction_control: { label: "Traction control", category: "safety" },
  lane_assist: { label: "Lane assist", category: "safety" },
};

export const CATEGORY_ORDER: { key: FeatureCategory; label: string }[] = [
  { key: "safety", label: "Safety" },
  { key: "comfort", label: "Comfort and convenience" },
  { key: "interior", label: "Interior" },
  { key: "exterior", label: "Exterior" },
];

export function groupFeatures(keys: string[]) {
  return CATEGORY_ORDER.map(({ key, label }) => ({
    label,
    items: keys
      .filter((k) => FEATURES[k]?.category === key)
      .map((k) => FEATURES[k].label),
  })).filter((group) => group.items.length > 0);
}
