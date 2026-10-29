import {
  CONTACT,
  displayPhone,
  hasAddress,
  hasContact,
  hasEmail,
  hasPhone,
  hasWhatsapp,
  telHref,
  whatsappHref,
} from "@/lib/contact";

/**
 * The utility bar above the header.
 *
 * Taken from the reference dealer site, and it is the device with the clearest argument behind it:
 * in this market buyers telephone. RELCO Wheels previously published no phone number anywhere on
 * the site, which meant a buyer who was ready to talk had nowhere to go.
 *
 * It renders nothing at all while CONTACT is unset. That is the point. A phone number that nobody
 * answers is worse than no phone number, so this bar cannot appear until there is a real one behind
 * it, and it disappears again if the details are ever cleared.
 */
export function ContactBar() {
  if (!hasContact()) return null;

  const left = [CONTACT.city, hasAddress() ? CONTACT.addressLines[0] : ""].filter(Boolean);

  return (
    <div className="border-b border-border bg-bg-subtle">
      <div className="wrap-x flex flex-wrap items-center justify-between gap-x-6 gap-y-1 py-2 text-xs">
        {left.length > 0 ? (
          <p className="text-sold">
            {left.map((part, i) => (
              <span key={part}>
                {i > 0 && <span className="mx-2">/</span>}
                {part}
              </span>
            ))}
          </p>
        ) : (
          <span />
        )}

        <div className="flex flex-wrap items-center gap-x-5 gap-y-1">
          {hasPhone() && (
            <a href={telHref(CONTACT.phone)} className="data text-heading hover:text-brand">
              {displayPhone(CONTACT.phone)}
            </a>
          )}
          {hasWhatsapp() && (
            <a
              href={whatsappHref(CONTACT.whatsapp)}
              target="_blank"
              rel="noopener noreferrer"
              className="text-heading hover:text-brand"
            >
              WhatsApp
            </a>
          )}
          {hasEmail() && (
            <a href={`mailto:${CONTACT.email}`} className="text-heading hover:text-brand">
              {CONTACT.email}
            </a>
          )}
        </div>
      </div>
    </div>
  );
}
