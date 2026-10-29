/**
 * The five things a condition report scores.
 *
 * Named in one place because the hero panel and the numbers band both refer to them, and a report
 * that scores five parts on one page and four on another is a report nobody trusts. The keys match
 * the columns on `inspections` in supabase/migrations/0001_init.sql.
 */
export const CONDITION_PARTS = [
  { key: "exterior", label: "Exterior and paint" },
  { key: "engine", label: "Engine and drivetrain" },
  { key: "suspension", label: "Suspension and steering" },
  { key: "interior", label: "Interior and trim" },
  { key: "ac", label: "Air conditioning" },
] as const;
