import sanitizeHtml from "sanitize-html";

/**
 * Rendering user authored HTML.
 *
 * Whatever a member writes ends up on a public page, so it is sanitised here, on the way out, at the
 * last possible moment. Two things follow from that choice:
 *
 *   1. The allowlist is deliberately small. A forum post is paragraphs, lists, links and the
 *      occasional blockquote. It is not a place for a script tag, an iframe, an inline style or an
 *      event handler, and none of those can be expressed in the allowed set below.
 *   2. Sanitising on the way out rather than on the way in means a mistake at write time cannot
 *      become a stored attack. The database can hold anything; only this decides what renders.
 *
 * This matters more than it looks. Until the forum is live, every body on the site comes from
 * src/lib/seed.ts and is trusted. The moment a member posts, it is not, and an unsanitised
 * dangerouslySetInnerHTML is the single most direct route to stealing another member's session.
 */

const ALLOWED_TAGS = [
  "p", "br", "strong", "b", "em", "i", "u", "s",
  "ul", "ol", "li",
  "blockquote", "code", "pre",
  "h2", "h3", "h4",
  "a", "hr",
  "table", "thead", "tbody", "tr", "th", "td",
];

export function renderBody(html: string | null | undefined): string {
  if (!html) return "";

  return sanitizeHtml(html, {
    allowedTags: ALLOWED_TAGS,
    allowedAttributes: {
      a: ["href", "title"],
      th: ["scope"],
      td: ["colspan"],
    },
    // No data: or javascript: URLs. This is the attribute that would otherwise carry an XSS.
    allowedSchemes: ["http", "https", "mailto"],
    allowedSchemesAppliedToAttributes: ["href"],
    // Anything not in the allowlist is dropped, not escaped into visible noise.
    disallowedTagsMode: "discard",
    transformTags: {
      // Every outbound link opens as a separate document and cannot reach back through
      // window.opener. Both attributes are set here rather than trusted to the author.
      a: sanitizeHtml.simpleTransform("a", { rel: "nofollow noopener noreferrer" }),
    },
  });
}

/** Text only, for meta descriptions and excerpts. Never renders, so it cannot leak markup. */
export function plainText(html: string | null | undefined): string {
  if (!html) return "";
  return sanitizeHtml(html, { allowedTags: [], allowedAttributes: {} })
    .replace(/\s+/g, " ")
    .trim();
}

/**
 * A safe preview of a post body.
 *
 * The forum category listing used to do `bodyHtml.slice(0, 320)`, which cuts a string rather than a
 * document: it can stop in the middle of a tag and leave an unclosed element behind. Stripping to
 * text first and then truncating cannot do that.
 */
export function excerpt(html: string | null | undefined, max = 240): string {
  const text = plainText(html);
  if (text.length <= max) return text;
  const cut = text.slice(0, max);
  const lastSpace = cut.lastIndexOf(" ");
  return `${(lastSpace > max * 0.6 ? cut.slice(0, lastSpace) : cut).trimEnd()}...`;
}
