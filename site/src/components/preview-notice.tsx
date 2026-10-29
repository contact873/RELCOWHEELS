import type { Prospect } from "@/lib/prospects";

/**
 * The banner that stops a preview being mistaken for a live page.
 *
 * It is deliberately loud and deliberately at the top. A dealer page carrying a real company's name
 * is a sales document, and the failure mode is somebody finding it in Google, or a dealer seeing it
 * before we have spoken to them, and concluding we have put them on our site without asking. That
 * is a worse outcome than any amount of ugliness here.
 *
 * It renders nothing for a dealership that has authorised us, because at that point it is a real
 * page and the banner would be a lie in the other direction.
 */
export function PreviewNotice({ prospect }: { prospect: Prospect }) {
  if (prospect.status === "live") return null;

  const sample = prospect.status === "sample";

  return (
    <div className="border-b border-border bg-bg-subtle">
      <div className="wrap-x py-3">
        <p className="text-sm text-heading">
          <span className="data mr-2 text-[11px] uppercase tracking-[0.08em] text-brand">
            {sample ? "Sample" : "Preview"}
          </span>
          {sample ? (
            <>
              This dealership is invented. It exists so the shape of a populated dealer page can be
              seen, and none of the cars below are real.
            </>
          ) : (
            <>
              A preview built for <strong>{prospect.name}</strong>, who have not seen it and have not
              authorised it. No car on this page is theirs, and nothing here should be read as a
              partnership. It is not in search results and it is not linked from anywhere on the
              site.
            </>
          )}
        </p>
      </div>
    </div>
  );
}
