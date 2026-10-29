import { CONTACT, hasWhatsapp, whatsappHref } from "@/lib/contact";

/**
 * The floating contact button.
 *
 * The reference site uses the usual round green button. This one is squared, because this identity
 * is crisp 2px everywhere and a circle is the one shape it never uses. It carries the word rather
 * than only a glyph, so it cannot be mistaken for a chat widget that is not there.
 *
 * z-30 sits below the cookie banner's z-40 deliberately: while the consent dialog is open it covers
 * this button, rather than the two of them stacking into a corner of overlapping boxes. Like the
 * contact bar, it renders nothing while no WhatsApp number is set.
 */
export function WhatsappFloat() {
  if (!hasWhatsapp()) return null;

  return (
    <a
      href={whatsappHref(CONTACT.whatsapp, "Hello, I have a question about a car on RELCO Wheels")}
      target="_blank"
      rel="noopener noreferrer"
      className="fixed bottom-4 right-4 z-30 inline-flex items-center gap-2 border border-border bg-bg-alt px-3 py-2 text-xs font-semibold uppercase tracking-[0.08em] text-heading transition-colors hover:border-brand hover:text-brand"
      style={{ borderRadius: "var(--radius)" }}
    >
      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" aria-hidden="true">
        <path d="M21 11.5a8.4 8.4 0 0 1-12.2 7.4L3.5 20.5l1.6-5.1A8.4 8.4 0 1 1 21 11.5z" />
      </svg>
      WhatsApp
    </a>
  );
}
