/**
 * Formatting. Prices are the most-read numbers on the site, so they get exact treatment.
 *
 * Pakistani buyers read prices in lakh and crore, not in full digits, and a marketplace that
 * shows only "2,350,000" makes everybody do arithmetic. Both forms are shown: the shorthand for
 * scanning, the full figure where it matters.
 */

export function pkr(amount: number | null, onCall = false): string {
  if (onCall || amount === null) return "Call for price";
  return `PKR ${amount.toLocaleString("en-PK")}`;
}

/** 2350000 becomes "23.5 lakh". Above one crore it switches, which is where the idiom switches. */
export function pkrShort(amount: number | null, onCall = false): string {
  if (onCall || amount === null) return "Call";
  if (amount >= 10_000_000) return `PKR ${(amount / 10_000_000).toFixed(2).replace(/\.00$/, "")} crore`;
  if (amount >= 100_000) return `PKR ${(amount / 100_000).toFixed(2).replace(/\.00$/, "")} lakh`;
  return `PKR ${amount.toLocaleString("en-PK")}`;
}

export function km(value: number | null): string {
  if (value === null) return "Not stated";
  return `${value.toLocaleString("en-PK")} km`;
}

export function cc(value: number | null): string {
  if (value === null) return "Not stated";
  return `${value.toLocaleString("en-PK")} cc`;
}

export function titleCase(value: string | null): string {
  if (!value) return "";
  return value.replace(/(^|\s)\S/g, (c) => c.toUpperCase());
}

/** "3 hours ago", "12 Aug 2026". Relative under a fortnight, absolute after that. */
export function when(iso: string): string {
  const then = new Date(iso).getTime();
  const mins = Math.round((Date.now() - then) / 60_000);

  if (mins < 1) return "just now";
  if (mins < 60) return `${mins} ${mins === 1 ? "minute" : "minutes"} ago`;

  const hours = Math.round(mins / 60);
  if (hours < 24) return `${hours} ${hours === 1 ? "hour" : "hours"} ago`;

  const days = Math.round(hours / 24);
  if (days < 14) return `${days} ${days === 1 ? "day" : "days"} ago`;

  return new Date(iso).toLocaleDateString("en-GB", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

/** The listing URL. Mirrors PakWheels' readable slug plus an id, which survives a title edit. */
export function listingSlug(l: {
  modelYear: number;
  makeSlug: string;
  modelSlug: string;
  citySlug: string;
  id: number;
}): string {
  return `${l.modelYear}-${l.makeSlug}-${l.modelSlug}-${l.citySlug}-${l.id}`;
}

export function maskPhone(phone: string | null): string {
  if (!phone) return "Not provided";
  // 0321 1234567 becomes 0321 XXXXXXX. The last seven digits are the part that identifies.
  const digits = phone.replace(/\D/g, "");
  return `${digits.slice(0, 4)} XXXXXXX`;
}

export function readingMinutes(html: string): number {
  const words = html.replace(/<[^>]+>/g, " ").split(/\s+/).filter(Boolean).length;
  return Math.max(1, Math.round(words / 220));
}
