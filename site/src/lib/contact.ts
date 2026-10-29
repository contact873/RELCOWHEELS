/**
 * How a buyer reaches a person.
 *
 * Every value here is empty on purpose, and the reason is that none of it can be invented. A phone
 * number in the header that nobody answers is worse than no phone number, and a number published
 * here goes on the live site immediately.
 *
 * So the contact bar, the WhatsApp button and the footer contact column all render nothing while
 * this object is unset. Fill it in and they appear. Nothing else on the site depends on it.
 *
 * `phone` and `whatsapp` are stored as digits with the country code and no punctuation, because
 * that is the form `tel:` and `wa.me` both want. The readable version is derived, so there is only
 * ever one place to correct.
 */

export const CONTACT: {
  /** Shown in the contact bar, so a buyer knows whether the stock is near them. */
  city: string;
  phone: string;
  whatsapp: string;
  email: string;
  /** One line per row, in the order they should be read. Empty hides the address block. */
  addressLines: string[];
} = {
  city: "",
  phone: "",
  whatsapp: "",
  email: "",
  addressLines: [],
};

const digitsOf = (value: string) => value.replace(/\D/g, "");

/** 923004006000 becomes "+92 300 400 6000". */
export function displayPhone(value: string): string {
  const d = digitsOf(value);
  if (d.startsWith("92") && d.length === 12) {
    const rest = d.slice(2);
    return `+92 ${rest.slice(0, 3)} ${rest.slice(3, 6)} ${rest.slice(6)}`;
  }
  if (d.startsWith("0") && d.length === 11) {
    return `${d.slice(0, 4)} ${d.slice(4, 7)} ${d.slice(7)}`;
  }
  return value;
}

export function telHref(value: string): string {
  return `tel:+${digitsOf(value)}`;
}

/** wa.me takes the number with no punctuation and no leading plus. */
export function whatsappHref(value: string, message?: string): string {
  const base = `https://wa.me/${digitsOf(value)}`;
  return message ? `${base}?text=${encodeURIComponent(message)}` : base;
}

export const hasPhone = () => digitsOf(CONTACT.phone).length >= 10;
export const hasWhatsapp = () => digitsOf(CONTACT.whatsapp).length >= 10;
export const hasEmail = () => CONTACT.email.includes("@");
export const hasAddress = () => CONTACT.addressLines.length > 0;

/** True when there is at least one way to reach a person, which is when the bars are worth showing. */
export const hasContact = () => hasPhone() || hasWhatsapp() || hasEmail() || hasAddress();
