// Execute the RELCO Wheels migrations against an embedded Postgres, to prove they parse and run.
//
//   node check.mjs
//
// pglite is a WebAssembly build of Postgres 16 running in Node, so the SQL is genuinely executed
// rather than pattern matched. Four things have to be adapted, because pglite is not Supabase:
//
//   1. The `auth` schema does not exist. A stub is created, with an `auth.users` table and an
//      `auth.uid()` function, so the foreign keys and the policies resolve.
//   2. The roles `anon`, `authenticated` and `service_role` do not exist. Stubs are created so the
//      grants and revokes resolve.
//   3. `citext` and `pg_trgm` are not available. `citext` becomes `text`, and the trigram indexes are
//      dropped. This loses case-insensitive uniqueness and the trigram indexes, and it means a pass
//      here does NOT prove those two features work. It does prove the rest parses and executes,
//      including every trigger and policy, which is where the real risk sits.
//   4. `gen_random_uuid()` is core in Postgres 13 and later, so no extension is needed.
//
// Any statement that fails is reported with its line number and the statement itself.

import fs from "node:fs";
import path from "node:path";
import { PGlite } from "@electric-sql/pglite";
import { fileURLToPath } from "node:url";

const MIGRATIONS = [
  path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../../supabase/migrations/0001_init.sql"),
  path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../../supabase/migrations/0002_blog_forum.sql"),
  path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../../supabase/migrations/0003_harden.sql"),
];

/**
 * Split SQL into statements. A naive split on ";" breaks inside function bodies, which is most of
 * this schema, so this tracks single quotes, dollar quoting and both comment styles.
 */
function splitStatements(sql) {
  const out = [];
  let current = "";
  let i = 0;
  let dollarTag = null;

  while (i < sql.length) {
    const two = sql.slice(i, i + 2);

    if (dollarTag) {
      if (sql.startsWith(dollarTag, i)) {
        current += dollarTag;
        i += dollarTag.length;
        dollarTag = null;
        continue;
      }
      current += sql[i];
      i += 1;
      continue;
    }

    if (two === "--") {
      const nl = sql.indexOf("\n", i);
      const end = nl === -1 ? sql.length : nl;
      current += sql.slice(i, end);
      i = end;
      continue;
    }

    if (two === "/*") {
      const close = sql.indexOf("*/", i + 2);
      const end = close === -1 ? sql.length : close + 2;
      current += sql.slice(i, end);
      i = end;
      continue;
    }

    const ch = sql[i];

    if (ch === "'") {
      current += ch;
      i += 1;
      while (i < sql.length) {
        if (sql[i] === "'" && sql[i + 1] === "'") {
          current += "''";
          i += 2;
          continue;
        }
        current += sql[i];
        if (sql[i] === "'") {
          i += 1;
          break;
        }
        i += 1;
      }
      continue;
    }

    if (ch === "$") {
      const m = /^\$[A-Za-z_]*\$/.exec(sql.slice(i));
      if (m) {
        dollarTag = m[0];
        current += dollarTag;
        i += dollarTag.length;
        continue;
      }
    }

    if (ch === ";") {
      if (current.trim()) out.push(current.trim());
      current = "";
      i += 1;
      continue;
    }

    current += ch;
    i += 1;
  }

  if (current.trim()) out.push(current.trim());
  return out;
}

function adapt(sql) {
  return sql
    .replace(/create extension if not exists "?(citext|pg_trgm|pgcrypto)"?;/gi, "")
    .replace(/\bcitext\b/gi, "text")
    // The trigram indexes cannot be built without pg_trgm. Matched leniently because the real files
    // align the index names with extra spaces.
    .replace(/create index[\s\S]{0,140}?gin_trgm_ops[^;]*;/gi, "");
}

const STUB = `
create schema if not exists auth;
create table if not exists auth.users (id uuid primary key);
create or replace function auth.uid() returns uuid language sql stable as $$ select null::uuid $$;
do $$ begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then create role anon nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then create role authenticated nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then create role service_role nologin; end if;
end $$;
`;

const db = new PGlite();

for (const stmt of splitStatements(STUB)) {
  await db.exec(stmt);
}

let total = 0;
let failed = 0;
const failures = [];

for (const file of MIGRATIONS) {
  const raw = fs.readFileSync(file, "utf8");
  const statements = splitStatements(adapt(raw));
  const name = path.basename(file);
  let ok = 0;

  for (const stmt of statements) {
    total += 1;
    const line = raw.slice(0, Math.max(0, raw.indexOf(stmt.slice(0, 60)))).split("\n").length;

    try {
      await db.exec(stmt);
      ok += 1;
    } catch (error) {
      failed += 1;
      failures.push({
        file: name,
        line,
        message: String(error.message ?? error).split("\n")[0],
        snippet: stmt.split("\n").slice(0, 3).join(" / ").slice(0, 150),
      });
    }
  }

  console.log(`  ${name}: ${ok} of ${statements.length} statements executed`);
}

// Count what should now exist. This is the part that catches a migration which ran but did nothing.
const counts = await db.query(`
  select
    (select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relkind = 'r')::int as public_tables,
    (select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'private' and c.relkind = 'r')::int as private_tables,
    (select count(*) from pg_proc where pronamespace in ('public'::regnamespace, 'private'::regnamespace))::int as functions,
    (select count(*) from pg_trigger where not tgisinternal)::int as triggers,
    (select count(*) from pg_policies where schemaname in ('public', 'private'))::int as policies,
    (select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname in ('public', 'private') and c.relkind = 'r' and c.relrowsecurity)::int as tables_with_rls,
    (select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname in ('public', 'private') and c.relkind = 'r')::int as tables_total
`);

const row = counts.rows[0];
console.log("");
console.log(`  tables              ${row.public_tables} exposed, ${row.private_tables} private`);
console.log(`  functions           ${row.functions}`);
console.log(`  triggers            ${row.triggers}`);
console.log(`  row level policies  ${row.policies}`);
console.log(`  tables with RLS on  ${row.tables_with_rls} of ${row.tables_total}`);

// Every table, in either schema, must have RLS. This is the check that matters most: one table left
// unprotected exposes everything behind it.
const unprotected = await db.query(`
  select n.nspname, c.relname as table_name
  from pg_class c join pg_namespace n on n.oid = c.relnamespace
  where n.nspname in ('public', 'private') and c.relkind = 'r' and not c.relrowsecurity
  order by n.nspname, c.relname
`);
if (unprotected.rows.length) {
  console.log(
    `\n  RLS DISABLED ON: ${unprotected.rows.map((r) => `${r.nspname}.${r.table_name}`).join(", ")}`,
  );
}

// ---------------------------------------------------------------------------
// Behaviour tests
//
// Executing the statements proves they parse. These prove the triggers and guards actually do what
// they claim, which is the part that cannot be checked by reading the file. pglite runs as the
// table owner, so row level security is bypassed here; these test the triggers, not the policies.
// ---------------------------------------------------------------------------

let passed = 0;
let failedTests = 0;

async function test(label, fn) {
  try {
    await fn();
    passed += 1;
    console.log(`  PASS  ${label}`);
  } catch (error) {
    failedTests += 1;
    console.log(`  FAIL  ${label}`);
    console.log(`        ${String(error.message).split("\n")[0]}`);
  }
}

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

async function expectError(sql, params, fragment) {
  try {
    await db.query(sql, params);
  } catch (error) {
    const message = String(error.message);
    if (fragment && !message.toLowerCase().includes(fragment.toLowerCase())) {
      throw new Error(`raised the wrong error: ${message.split("\n")[0]}`);
    }
    return;
  }
  throw new Error("expected an error and none was raised");
}

const ALICE = "00000000-0000-0000-0000-000000000001";
const ADMIN = "00000000-0000-0000-0000-000000000002";

console.log("");
console.log("  Behaviour");

await db.query(`insert into auth.users (id) values ($1), ($2)`, [ALICE, ADMIN]);
await db.query(
  `insert into profiles (id, display_name, handle, terms_version) values
     ($1, 'Alice Member', 'alice_member', '1'),
     ($2, 'Site Owner', 'site_owner', '1')`,
  [ALICE, ADMIN],
);
await db.query(`update profiles set role = 'admin' where id = $1`, [ADMIN]);

// The display name constraint blocks the platform's own name, so nobody can pose as us. This was
// discovered the honest way: an earlier version of this file used "Site Admin" as test data and the
// insert was rejected, which is the constraint doing its job.
await test("a display name cannot impersonate the platform", async () => {
  await db.query(`insert into auth.users (id) values ('00000000-0000-0000-0000-000000000003')`);
  await expectError(
    `insert into profiles (id, display_name, handle, terms_version)
     values ('00000000-0000-0000-0000-000000000003', 'RELCO Support', 'relco_support', '1')`,
    [],
    "profiles_display_name_check",
  );
});

const cat = await db.query(`select id from forum_categories where slug = 'buying-advice'`);
const CATEGORY = cat.rows[0].id;

await test("a member's first thread is held, not published", async () => {
  const r = await db.query(
    `insert into threads (category_id, author_id, title, slug, body_md)
     values ($1, $2, 'Is 23.45 lakh fair for a 2019 Alto', 'first-thread', 'Asking before I agree.')
     returning id, status`,
    [CATEGORY, ALICE],
  );
  assert(r.rows[0].status === "held", `expected held, got ${r.rows[0].status}`);
});

const firstThread = (await db.query(`select id from threads where slug = 'first-thread'`)).rows[0].id;

await test("approving the held thread releases the hold permanently", async () => {
  await db.query(`update threads set status = 'visible' where id = $1`, [firstThread]);
  const t = await db.query(`select first_post_held from private.user_trust where user_id = $1`, [ALICE]);
  assert(t.rows[0].first_post_held === false, "first_post_held should now be false");
});

await test("a later post by the same member publishes immediately", async () => {
  const r = await db.query(
    `insert into posts (thread_id, author_id, body_md) values ($1, $2, 'Following, because I am looking too.')
     returning id, status`,
    [firstThread, ALICE],
  );
  assert(r.rows[0].status === "visible", `expected visible, got ${r.rows[0].status}`);
});

await test("reply_count is maintained by trigger", async () => {
  const t = await db.query(`select reply_count, last_reply_at from threads where id = $1`, [firstThread]);
  assert(t.rows[0].reply_count === 1, `expected 1, got ${t.rows[0].reply_count}`);
  assert(t.rows[0].last_reply_at !== null, "last_reply_at should be set");
});

await test("hiding a post decrements reply_count", async () => {
  const postId = (await db.query(`select id from posts where thread_id = $1 limit 1`, [firstThread])).rows[0].id;
  await db.query(`update posts set status = 'hidden' where id = $1`, [postId]);
  const t = await db.query(`select reply_count from threads where id = $1`, [firstThread]);
  assert(t.rows[0].reply_count === 0, `expected 0, got ${t.rows[0].reply_count}`);
  await db.query(`update posts set status = 'visible' where id = $1`, [postId]);
});

await test("editing a post records a revision and increments the count", async () => {
  const postId = (await db.query(`select id from posts where thread_id = $1 limit 1`, [firstThread])).rows[0].id;
  await db.query(`update posts set body_md = 'Following, and I have seen the same car.' where id = $1`, [postId]);
  const p = await db.query(`select edit_count, edited_at from posts where id = $1`, [postId]);
  assert(p.rows[0].edit_count === 1, `expected edit_count 1, got ${p.rows[0].edit_count}`);
  assert(p.rows[0].edited_at !== null, "edited_at should be set");
  const rev = await db.query(`select count(*)::int as n from post_revisions where post_id = $1`, [postId]);
  assert(rev.rows[0].n === 1, `expected 1 revision, got ${rev.rows[0].n}`);
});

await test("a post with more than three links is refused", async () => {
  await expectError(
    `insert into posts (thread_id, author_id, body_md) values ($1, $2, $3)`,
    [firstThread, ALICE, "see http://a.example http://b.example http://c.example http://d.example"],
    "too many links",
  );
});

await test("a second question thread can be created", async () => {
  const r = await db.query(
    `insert into threads (category_id, author_id, title, slug, body_md, kind)
     values ($1, $2, 'Which Vezel grade should I buy', 'second-thread', 'Grade X or Z.', 'question')
     returning id`,
    [CATEGORY, ALICE],
  );
  assert(r.rows.length === 1, "thread should have been created");
});

await test("an accepted answer must belong to its own thread", async () => {
  const other = (await db.query(`select id from threads where slug = 'second-thread'`)).rows[0].id;
  const foreignPost = (await db.query(`select id from posts where thread_id = $1 limit 1`, [firstThread])).rows[0].id;
  await expectError(
    `update threads set accepted_post_id = $1 where id = $2`,
    [foreignPost, other],
    "must be a post in this thread",
  );
});

await test("an author cannot insert an article already published", async () => {
  const r = await db.query(
    `insert into articles (author_id, slug, title, dek, body_md, status, published_at)
     values ($1, 'self-published', 'A title long enough to pass', 'A dek long enough to pass the check', 'body', 'published', now())
     returning status`,
    [ALICE],
  );
  assert(r.rows[0].status === "draft", `expected the status to be forced to draft, got ${r.rows[0].status}`);
});

await test("a non-administrator cannot publish an article", async () => {
  await expectError(
    `update articles set status = 'published', reviewed_by = $1 where slug = 'self-published'`,
    [ALICE],
    "Only an administrator",
  );
});

await test("an administrator can publish an article", async () => {
  const r = await db.query(
    `update articles set status = 'published', reviewed_by = $1 where slug = 'self-published'
     returning status, published_at, reviewed_at`,
    [ADMIN],
  );
  assert(r.rows[0].status === "published", "status should be published");
  assert(r.rows[0].published_at !== null, "published_at should be set");
  assert(r.rows[0].reviewed_at !== null, "reviewed_at should be set");
});

await test("the thread rate limit holds at three per day", async () => {
  await db.query(
    `insert into threads (category_id, author_id, title, slug, body_md)
     values ($1, $2, 'Third thread today about brakes', 'third-thread', 'Squealing when cold.')`,
    [CATEGORY, ALICE],
  );
  await expectError(
    `insert into threads (category_id, author_id, title, slug, body_md)
     values ($1, $2, 'Fourth thread today about tyres', 'fourth-thread', 'Which brand lasts longest?')`,
    [CATEGORY, ALICE],
    "Rate limit",
  );
});

// ---------------------------------------------------------------------------
// Security assertions
//
// These are the checks that answer "is it safe", as opposed to "does it work". Each one corresponds
// to a way a Supabase project leaks: RLS switched off, a permissive write policy, a function that
// the world can call, a SECURITY DEFINER that resolves its tables through the caller's search_path,
// a view that bypasses the policies underneath it, or a personal column left in the exposed schema.
// ---------------------------------------------------------------------------

console.log("");
console.log("  Security");

await test("the private schema exists", async () => {
  const r = await db.query(`select 1 from pg_namespace where nspname = 'private'`);
  assert(r.rows.length === 1, "no private schema, so nothing is out of the API's reach");
});

await test("no table anywhere lacks row level security", async () => {
  const r = await db.query(`
    select n.nspname, c.relname
    from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname in ('public', 'private') and c.relkind = 'r' and not c.relrowsecurity
  `);
  assert(
    r.rows.length === 0,
    `RLS disabled on: ${r.rows.map((x) => `${x.nspname}.${x.relname}`).join(", ")}`,
  );
});

await test("the sensitive tables are not in the exposed schema", async () => {
  const r = await db.query(`
    select c.relname, n.nspname
    from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where c.relkind = 'r'
      and c.relname in ('leads', 'auth_events', 'user_identities', 'user_push_tokens', 'user_trust', 'reports')
  `);
  const stillPublic = r.rows.filter((x) => x.nspname === 'public').map((x) => x.relname);
  assert(stillPublic.length === 0, `still reachable through the API: ${stillPublic.join(", ")}`);
  assert(r.rows.length === 6, `expected 6 sensitive tables, found ${r.rows.length}`);
});

await test("no contact details remain in the exposed schema", async () => {
  const r = await db.query(`
    select table_name, column_name
    from information_schema.columns
    where table_schema = 'public'
      and column_name in ('email', 'phone', 'phone_verified_at', 'email_verified_at')
  `);
  assert(
    r.rows.length === 0,
    `found in public: ${r.rows.map((x) => `${x.table_name}.${x.column_name}`).join(", ")}`,
  );

  const moved = await db.query(`
    select count(*)::int as n from information_schema.columns
    where table_schema = 'private' and table_name = 'profile_contacts'
      and column_name in ('email', 'phone')
  `);
  assert(moved.rows[0].n === 2, "private.profile_contacts should hold both email and phone");
});

await test("anon holds no write privilege on any public table", async () => {
  const r = await db.query(`
    select table_name, privilege_type
    from information_schema.role_table_grants
    where grantee = 'anon' and table_schema = 'public'
      and privilege_type in ('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE', 'REFERENCES', 'TRIGGER')
  `);
  assert(
    r.rows.length === 0,
    `anon can write: ${r.rows.map((x) => `${x.table_name}:${x.privilege_type}`).join(", ")}`,
  );
});

await test("anon cannot execute any function", async () => {
  const r = await db.query(`
    select n.nspname, p.proname
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname in ('public', 'private')
      and has_function_privilege('anon', p.oid, 'EXECUTE')
  `);
  assert(
    r.rows.length === 0,
    `anon can call: ${r.rows.map((x) => `${x.nspname}.${x.proname}`).join(", ")}`,
  );
});

await test("every SECURITY DEFINER function pins its search_path", async () => {
  const r = await db.query(`
    select n.nspname, p.proname
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname in ('public', 'private')
      and p.prosecdef
      and not exists (
        select 1 from unnest(coalesce(p.proconfig, array[]::text[])) c
        where c like 'search_path=%'
      )
  `);
  assert(
    r.rows.length === 0,
    `unpinned: ${r.rows.map((x) => `${x.nspname}.${x.proname}`).join(", ")}`,
  );
});

await test("no write policy is written as using (true)", async () => {
  const r = await db.query(`
    select schemaname, tablename, policyname, cmd
    from pg_policies
    where schemaname in ('public', 'private')
      and cmd in ('INSERT', 'UPDATE', 'DELETE', 'ALL')
      and (
        coalesce(with_check, '') ~ '^\\s*\\(?\\s*true\\s*\\)?\\s*$'
        or coalesce(qual, '') ~ '^\\s*\\(?\\s*true\\s*\\)?\\s*$'
      )
  `);
  assert(
    r.rows.length === 0,
    `permissive writes: ${r.rows.map((x) => `${x.tablename}.${x.policyname}`).join(", ")}`,
  );
});

await test("no view bypasses the policies underneath it", async () => {
  const r = await db.query(`
    select n.nspname, c.relname
    from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname in ('public', 'private')
      and c.relkind = 'v'
      and coalesce(array_to_string(c.reloptions, ','), '') not like '%security_invoker=%'
  `);
  assert(
    r.rows.length === 0,
    `views without security_invoker: ${r.rows.map((x) => `${x.nspname}.${x.relname}`).join(", ")}`,
  );
});

// ---------------------------------------------------------------------------
// The catalogue seed
//
// Generated by tools/seed-catalogue.mjs. Running it here proves three things that reading it cannot:
// that it parses, that it satisfies the real constraints, and that running it twice does not create a
// second Suzuki. That last one matters because the file is regenerated every time a model is added,
// and somebody will run it twice.
// ---------------------------------------------------------------------------

const CATALOGUE_SQL = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../../data/catalogue.sql");

if (fs.existsSync(CATALOGUE_SQL)) {
  const raw = fs.readFileSync(CATALOGUE_SQL, "utf8");
  const statements = splitStatements(raw);

  await test(`the catalogue seed executes (${statements.length} statements)`, async () => {
    // Executed as one unit rather than statement by statement, because the file is wrapped in a
    // transaction. One failed statement aborts the whole block, and the useful error is the first
    // one, not the "current transaction is aborted" that follows it.
    try {
      await db.exec(raw);
      total += statements.length;
    } catch (error) {
      await db.exec("rollback").catch(() => {});
      const message = String(error.message).split("\n")[0];
      failures.push({ file: "data/catalogue.sql", line: 0, message, snippet: "" });
      throw new Error(message);
    }
  });

  let c = { makes: 0, models: 0, variants: 0 };
  try {
    const counts = await db.query(`
      select (select count(*) from public.makes)::int as makes,
             (select count(*) from public.models)::int as models,
             (select count(*) from public.variants)::int as variants
    `);
    c = counts.rows[0];
  } catch (error) {
    failures.push({
      file: "counts",
      line: 0,
      message: String(error.message).split("\n")[0],
      snippet: "could not count makes, models and variants",
    });
  }

  await test(`the catalogue loaded: ${c.makes} makes, ${c.models} models, ${c.variants} variants`, async () => {
    assert(c.makes > 0 && c.models > 0 && c.variants > 0, "the catalogue loaded nothing");
    assert(c.variants > c.models, "there should be more variants than models");
  });

  await test("running the catalogue twice does not duplicate anything", async () => {
    try {
      await db.exec(raw);
    } catch (error) {
      await db.exec("rollback").catch(() => {});
      throw new Error(`the second run failed: ${String(error.message).split("\n")[0]}`);
    }
    const again = await db.query(`
      select (select count(*) from public.makes)::int as makes,
             (select count(*) from public.models)::int as models,
             (select count(*) from public.variants)::int as variants
    `);
    const a = again.rows[0];
    assert(
      a.makes === c.makes && a.models === c.models && a.variants === c.variants,
      `second run changed the counts: ${c.makes}/${c.models}/${c.variants} became ${a.makes}/${a.models}/${a.variants}`,
    );
  });
}

console.log("");
console.log(`  ${passed} tests passed, ${failedTests} failed`);

if (failures.length || failedTests) {
  console.log(`  FAILED: ${failed} of ${total} statements, ${failedTests} behaviour tests\n`);
  for (const f of failures) {
    console.log(`  ${f.file}, near line ${f.line}`);
    console.log(`    ${f.message}`);
    console.log(`    ${f.snippet}`);
    console.log("");
  }
  process.exit(1);
}

console.log(`  All ${total} statements executed and all behaviour tests passed. No failures.\n`);
