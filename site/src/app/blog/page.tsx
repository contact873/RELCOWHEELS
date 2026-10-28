import Image from "next/image";
import Link from "next/link";
import { PhotoPlaceholder } from "@/components/photo-placeholder";
import { publishedArticles } from "@/lib/queries";
import { when } from "@/lib/format";

export const metadata = {
  title: "Guides to buying and selling cars in Pakistan",
  description:
    "What to check before you buy, how to read an auction sheet, how to photograph a car so it sells, and what the third year of ownership really costs.",
  alternates: { canonical: "/blog" },
};

export default function BlogIndex() {
  const articles = publishedArticles();
  const [lead, ...rest] = articles;

  return (
    <div className="wrap-x py-10">
      <nav aria-label="Breadcrumb" className="text-sm text-sold">
        <Link href="/" className="hover:text-brand">Home</Link>
        <span className="mx-2">/</span>
        <span className="text-heading">Guides</span>
      </nav>

      <h1 className="mt-4 text-3xl md:text-4xl">Guides and articles</h1>
      <p className="mt-3 max-w-[64ch] text-body">
        Written by people who inspect, buy and sell these cars. No listicles, and nothing that we
        would not act on ourselves.
      </p>

      {lead && (
        <article className="mt-10 grid gap-8 border-b border-border pb-10 lg:grid-cols-2">
          <Link href={`/blog/${lead.slug}`} className="block border border-border bg-bg-alt">
            {lead.coverPath ? (
              <Image
                src={lead.coverPath}
                alt=""
                width={900}
                height={675}
                className="h-auto w-full"
                sizes="(max-width: 1024px) 100vw, 560px"
                priority
              />
            ) : (
              <PhotoPlaceholder reference={lead.tags[0] ?? "editorial"} label="Illustration pending" />
            )}
          </Link>
          <div className="flex flex-col justify-center">
            <p className="data text-xs uppercase tracking-[0.1em] text-brand">{lead.tags[0]}</p>
            <h2 className="mt-2 text-2xl md:text-3xl">
              <Link href={`/blog/${lead.slug}`} className="text-heading hover:text-brand">
                {lead.title}
              </Link>
            </h2>
            <p className="mt-3 max-w-[56ch] text-body">{lead.dek}</p>
            <p className="data mt-4 text-xs text-sold">
              {lead.authorName}
              <span className="mx-2">/</span>
              {lead.readingMinutes} min read
              <span className="mx-2">/</span>
              {lead.publishedAt ? when(lead.publishedAt) : ""}
            </p>
            <Link
              href={`/blog/${lead.slug}`}
              className="btn btn-ghost mt-6 self-start"
            >
              Read it
            </Link>
          </div>
        </article>
      )}

      <ul className="mt-10 grid gap-x-10 gap-y-8 md:grid-cols-2">
        {rest.map((a) => (
          <li key={a.id} className="border-b border-border pb-6">
            <p className="data text-xs uppercase tracking-[0.1em] text-brand">{a.tags[0]}</p>
            <h2 className="mt-2 text-xl leading-snug">
              <Link href={`/blog/${a.slug}`} className="text-heading hover:text-brand">
                {a.title}
              </Link>
            </h2>
            <p className="mt-2 text-sm text-body">{a.dek}</p>
            <p className="data mt-3 text-xs text-sold">
              {a.authorName}
              <span className="mx-2">/</span>
              {a.readingMinutes} min read
            </p>
          </li>
        ))}
      </ul>

      <section className="mt-14 border border-border bg-bg-alt p-6">
        <h2 className="text-lg">Write for us</h2>
        <p className="mt-2 max-w-[62ch] text-sm text-body">
          If you have bought, sold, inspected or imported enough cars to know something a first time
          buyer does not, we will publish it under your name. Every submission is read before it goes
          up, and you keep the credit.
        </p>
        <Link href="/write" className="btn btn-primary mt-4">
          Submit an article
        </Link>
      </section>
    </div>
  );
}
