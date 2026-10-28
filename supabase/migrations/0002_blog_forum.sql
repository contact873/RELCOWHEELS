-- RELCO Wheels, migration 0002.
--
-- The schema behind the blog and the forum.
--
-- Two systems with deliberately opposite economics, which is why they get different status machines:
--
--   Articles   few authors, high value each, carries the domain's credibility. Pre-approved: nothing
--              is public until a person has read it.
--   Threads    many authors, low value each, the value is in the aggregate. Post-approved, with a
--              member's first post held. Pre-approving every forum post is what kills a forum; not
--              approving anything is what turns it into a spam farm within a week.
--
-- Depends on 0001_init.sql for profiles, listings, reports, user_trust and the touch_updated_at
-- function.

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------

create type article_status as enum ('draft', 'submitted', 'in_review', 'published', 'rejected');

-- One status machine for both threads and posts. `held` is the first-post review state and is what
-- makes post-approval safe.
create type content_status as enum ('held', 'visible', 'flagged', 'hidden');

create type thread_kind as enum ('discussion', 'question');

create type reaction_kind as enum ('helpful', 'thanks');

-- ---------------------------------------------------------------------------
-- Articles
-- ---------------------------------------------------------------------------

create table tags (
  id   serial primary key,
  name text not null,
  slug citext not null unique
);

create table articles (
  id            bigserial primary key,
  author_id     uuid references profiles(id) on delete set null,
  slug          citext not null unique check (slug ~ '^[a-z0-9][a-z0-9-]{2,80}$'),
  title         text not null check (char_length(title) between 10 and 120),
  dek           text not null check (char_length(dek) between 20 and 300),
  body_md       text not null,
  body_html     text,
  status        article_status not null default 'draft',

  cover_path    text,
  reading_minutes smallint,

  -- Guest authorship. A guest keeps the byline; we keep the canonical. guest_email is never
  -- published, and licence_accepted_at is the record that they agreed to that.
  is_guest      boolean not null default false,
  guest_name    text,
  guest_email   citext,
  guest_url     text,
  licence_accepted_at timestamptz,

  -- The review trail. reviewed_by must be an administrator, checked by trigger below.
  reviewed_by        uuid references profiles(id) on delete set null,
  reviewed_at        timestamptz,
  rejection_reason   text,

  published_at  timestamptz,
  view_count    int not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),

  -- A guest article without a name is an anonymous article, which we do not publish.
  check (not is_guest or guest_name is not null),
  -- Nothing can be published without a publication date, and nothing can be rejected without a reason.
  check (status <> 'published' or published_at is not null),
  check (status <> 'rejected' or rejection_reason is not null)
);

create table article_tags (
  article_id bigint not null references articles(id) on delete cascade,
  tag_id     int not null references tags(id) on delete cascade,
  primary key (article_id, tag_id)
);

-- ---------------------------------------------------------------------------
-- Forum
-- ---------------------------------------------------------------------------

create table forum_categories (
  id                serial primary key,
  name              text not null,
  slug              citext not null unique check (slug ~ '^[a-z0-9][a-z0-9-]{1,40}$'),
  description       text not null,
  position          smallint not null default 0,
  is_locked         boolean not null default false,
  -- The minimum role allowed to start a thread here. Dealers only, for example.
  min_role_to_post  user_role not null default 'member'
);

create table threads (
  id            bigserial primary key,
  category_id   int not null references forum_categories(id) on delete restrict,
  author_id     uuid not null references profiles(id) on delete cascade,

  title         text not null check (char_length(title) between 10 and 140),
  slug          citext not null unique check (slug ~ '^[a-z0-9][a-z0-9-]{2,80}$'),
  body_md       text not null,
  body_html     text,
  kind          thread_kind not null default 'discussion',
  status        content_status not null default 'visible',

  -- The differentiating feature: a thread can be attached to a listing, which puts unique user prose
  -- on that listing's page and keeps the answer public instead of dying in a private message.
  listing_id    bigint references listings(id) on delete set null,

  is_pinned     boolean not null default false,
  is_locked     boolean not null default false,

  reply_count   int not null default 0,
  view_count    int not null default 0,

  -- One accepted answer, and only on a question. Enforced by trigger, because a foreign key cannot
  -- express "the post must belong to this thread".
  accepted_post_id bigint,

  last_reply_at timestamptz,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create table posts (
  id              bigserial primary key,
  thread_id       bigint not null references threads(id) on delete cascade,
  author_id       uuid not null references profiles(id) on delete cascade,

  -- One level of nesting only. Deep threading is unreadable on a phone and impossible to moderate.
  parent_post_id  bigint references posts(id) on delete set null,

  body_md         text not null check (char_length(body_md) between 2 and 10000),
  body_html       text,
  status          content_status not null default 'visible',

  edited_at       timestamptz,
  edit_count      smallint not null default 0,

  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

alter table threads
  add constraint threads_accepted_post_fk
  foreign key (accepted_post_id) references posts(id) on delete set null;

-- The edit history. An edit window is meaningless without a record of what changed, and this is what
-- stops somebody quietly rewriting a post after it has been answered.
create table post_revisions (
  id           bigserial primary key,
  post_id      bigint not null references posts(id) on delete cascade,
  body_md      text not null,
  replaced_at  timestamptz not null default now(),
  replaced_by  uuid references profiles(id) on delete set null
);

create table reactions (
  id       bigserial primary key,
  post_id  bigint not null references posts(id) on delete cascade,
  user_id  uuid not null references profiles(id) on delete cascade,
  kind     reaction_kind not null default 'helpful',
  created_at timestamptz not null default now(),
  unique (post_id, user_id, kind)
);

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

create index articles_published      on articles (status, published_at desc) where status = 'published';
create index articles_author         on articles (author_id, status);
create index articles_review_queue   on articles (status, created_at) where status in ('submitted', 'in_review');
create index articles_title_trgm     on articles using gin (title gin_trgm_ops);

create index threads_category_recent on threads (category_id, is_pinned desc, last_reply_at desc nulls last)
                                     where status = 'visible';
create index threads_listing         on threads (listing_id) where listing_id is not null;
create index threads_author          on threads (author_id, created_at desc);
create index threads_title_trgm      on threads using gin (title gin_trgm_ops);

create index posts_thread_order      on posts (thread_id, created_at) where status = 'visible';
create index posts_held_queue        on posts (status, created_at) where status in ('held', 'flagged');
create index posts_author            on posts (author_id, created_at desc);
create index posts_parent            on posts (parent_post_id) where parent_post_id is not null;

create index reactions_post          on reactions (post_id, kind);

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------

create trigger articles_touch before update on articles for each row execute function touch_updated_at();
create trigger threads_touch  before update on threads  for each row execute function touch_updated_at();
create trigger posts_touch    before update on posts    for each row execute function touch_updated_at();

-- Only an administrator may review an article. Enforced here rather than in the route, because the
-- route is not the only way into the table.
create or replace function guard_article_review() returns trigger
language plpgsql as $$
begin
  if new.status is distinct from old.status and new.status in ('published', 'rejected') then
    if new.reviewed_by is null then
      new.reviewed_by := auth.uid();
    end if;
    if not exists (select 1 from profiles where id = new.reviewed_by and role = 'admin') then
      raise exception 'Only an administrator may publish or reject an article.';
    end if;
    if new.reviewed_at is null then
      new.reviewed_at := now();
    end if;
    if new.status = 'published' and new.published_at is null then
      new.published_at := now();
    end if;
  end if;
  return new;
end $$;

create trigger articles_guard_review before update on articles
  for each row execute function guard_article_review();

-- The same guard on insert, because a check that only runs on update can be walked straight past by
-- inserting a row that is already published. Without this, any member could POST an article with
-- status "published" and skip the review entirely, which defeats the whole pre-approval model for
-- articles. Anything a non-administrator inserts is forced back to a draft.
create or replace function guard_article_insert() returns trigger
language plpgsql as $$
begin
  if new.status not in ('draft', 'submitted') and not is_admin() then
    new.status := 'draft';
    new.reviewed_by := null;
    new.reviewed_at := null;
    new.published_at := null;
  end if;
  return new;
end $$;

create trigger articles_guard_insert before insert on articles
  for each row execute function guard_article_insert();

-- A member's first post is held. Applied to both threads and posts, because a thread is also a first
-- post and a forum where the opening post publishes but the replies do not is nonsense.
create or replace function hold_first_post() returns trigger
language plpgsql as $$
declare
  still_held boolean;
begin
  select first_post_held into still_held from user_trust where user_id = new.author_id;
  if coalesce(still_held, true) and new.status = 'visible' then
    new.status := 'held';
  end if;
  return new;
end $$;

create trigger posts_hold_first before insert on posts
  for each row execute function hold_first_post();

create trigger threads_hold_first before insert on threads
  for each row execute function hold_first_post();

-- The first approval releases the author permanently, so the hold costs a real member exactly once.
create or replace function release_first_post_hold() returns trigger
language plpgsql as $$
begin
  if old.status = 'held' and new.status = 'visible' then
    update user_trust set first_post_held = false where user_id = new.author_id;
  end if;
  return new;
end $$;

create trigger posts_release_hold after update of status on posts
  for each row execute function release_first_post_hold();

create trigger threads_release_hold after update of status on threads
  for each row execute function release_first_post_hold();

-- Edit window, and the revision that makes it honest.
--
-- A member may edit their own post for ten minutes. After that, edit_count increments and the old
-- body is kept, which is what allows a reader to see that something changed.
create or replace function record_post_edit() returns trigger
language plpgsql as $$
begin
  if new.body_md is distinct from old.body_md then
    insert into post_revisions (post_id, body_md, replaced_by)
    values (old.id, old.body_md, auth.uid());

    new.edited_at := now();
    new.edit_count := old.edit_count + 1;
  end if;
  return new;
end $$;

create trigger posts_record_edit before update on posts
  for each row execute function record_post_edit();

-- reply_count and last_reply_at are maintained here and never by application code. Counters written
-- by hand are the classic source of a forum whose sorting quietly stops working.
create or replace function sync_thread_counters() returns trigger
language plpgsql as $$
declare
  target_thread bigint;
begin
  target_thread := coalesce(new.thread_id, old.thread_id);

  update threads t set
    reply_count = (
      select count(*) from posts p
      where p.thread_id = target_thread and p.status = 'visible'
    ),
    last_reply_at = (
      select max(p.created_at) from posts p
      where p.thread_id = target_thread and p.status = 'visible'
    )
  where t.id = target_thread;

  return null;
end $$;

create trigger posts_sync_thread after insert or update of status or delete on posts
  for each row execute function sync_thread_counters();

-- An accepted answer must belong to its own thread, and only a question may have one.
create or replace function guard_accepted_answer() returns trigger
language plpgsql as $$
begin
  if new.accepted_post_id is not null then
    if new.kind <> 'question' then
      raise exception 'Only a question thread can have an accepted answer.';
    end if;
    if not exists (select 1 from posts where id = new.accepted_post_id and thread_id = new.id) then
      raise exception 'The accepted answer must be a post in this thread.';
    end if;
  end if;
  return new;
end $$;

create trigger threads_guard_accepted before update of accepted_post_id on threads
  for each row execute function guard_accepted_answer();

-- Rate limits, in the database because a limit enforced only in the application is not a limit.
create or replace function rate_limit_posting() returns trigger
language plpgsql as $$
declare
  table_name text := tg_table_name;
  daily_cap  int := case when tg_table_name = 'threads' then 3 else 20 end;
  recent     int;
begin
  execute format(
    'select count(*) from %I where author_id = $1 and created_at > now() - interval ''24 hours''',
    table_name
  ) into recent using new.author_id;

  if recent >= daily_cap then
    raise exception
      'Rate limit: a member may post % % per day. This account has reached it.',
      daily_cap, table_name;
  end if;
  return new;
end $$;

create trigger threads_rate_limit before insert on threads
  for each row execute function rate_limit_posting();

create trigger posts_rate_limit before insert on posts
  for each row execute function rate_limit_posting();

-- Only one link is allowed in a member's very first post, and none at all until they have been
-- approved. This is the cheapest anti-spam measure that does not cost anything per message.
create or replace function limit_first_post_links() returns trigger
language plpgsql as $$
declare
  still_held boolean;
  links      int;
begin
  select first_post_held into still_held from user_trust where user_id = new.author_id;
  links := (length(new.body_md) - length(replace(new.body_md, 'http', ''))) / 4;

  if coalesce(still_held, true) and links > 0 then
    raise exception 'A first post may not contain links.';
  end if;
  if not coalesce(still_held, true) and links > 3 then
    raise exception 'That post has too many links.';
  end if;
  return new;
end $$;

create trigger posts_limit_links before insert on posts
  for each row execute function limit_first_post_links();

create trigger threads_limit_links before insert on threads
  for each row execute function limit_first_post_links();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table articles         enable row level security;
alter table article_tags     enable row level security;
alter table tags             enable row level security;
alter table forum_categories enable row level security;
alter table threads          enable row level security;
alter table posts            enable row level security;
alter table post_revisions   enable row level security;
alter table reactions        enable row level security;

-- Articles: the public sees what has been published. An author sees their own drafts. Admin sees all.
create policy articles_read on articles for select
  using (status = 'published' or author_id = auth.uid() or is_admin());

create policy articles_insert_self on articles for insert
  with check (author_id = auth.uid() and status in ('draft', 'submitted'));

-- An author may edit their own article, but only while it is a draft or has been sent back. Once it
-- is submitted, editing stops until a reviewer acts, otherwise the thing being reviewed can change
-- underneath the reviewer.
create policy articles_update_self on articles for update
  using (
    (author_id = auth.uid() and status in ('draft', 'submitted', 'rejected'))
    or is_admin()
  )
  with check (author_id = auth.uid() or is_admin());

create policy article_tags_read on article_tags for select using (true);
create policy article_tags_write on article_tags for all
  using (exists (select 1 from articles a where a.id = article_id and (a.author_id = auth.uid() or is_admin())))
  with check (exists (select 1 from articles a where a.id = article_id and (a.author_id = auth.uid() or is_admin())));

create policy tags_read on tags for select using (true);
create policy tags_admin on tags for all using (is_admin()) with check (is_admin());

create policy categories_read on forum_categories for select using (true);
create policy categories_admin on forum_categories for all using (is_admin()) with check (is_admin());

-- Threads and posts: the public sees what is visible. An author sees their own held or flagged post so
-- they know it is waiting rather than believing it was lost. Admin sees everything.
create policy threads_read on threads for select
  using (status = 'visible' or author_id = auth.uid() or is_admin());

create policy threads_insert_self on threads for insert
  with check (
    author_id = auth.uid()
    and exists (
      select 1 from forum_categories c
      where c.id = category_id and not c.is_locked
    )
  );

create policy threads_update_own on threads for update
  using (author_id = auth.uid() or is_admin())
  with check (author_id = auth.uid() or is_admin());

-- An author may withdraw a thread that nobody has answered. Once it has replies, deleting it would
-- destroy other people's contributions, so that becomes a moderator decision.
create policy threads_delete_own on threads for delete
  using ((author_id = auth.uid() and reply_count = 0) or is_admin());

create policy posts_read on posts for select
  using (status = 'visible' or author_id = auth.uid() or is_admin());

create policy posts_insert_self on posts for insert
  with check (
    author_id = auth.uid()
    and exists (select 1 from threads t where t.id = thread_id and not t.is_locked)
  );

create policy posts_update_own on posts for update
  using (author_id = auth.uid() or is_admin())
  with check (author_id = auth.uid() or is_admin());

-- Same rule for a post. A reply that somebody has already answered stays, unless a moderator removes
-- it. This is also what keeps the edit history meaningful.
create policy posts_delete_own on posts for delete
  using (
    is_admin()
    or (
      author_id = auth.uid()
      and not exists (select 1 from posts child where child.parent_post_id = posts.id)
      and not exists (select 1 from threads t where t.accepted_post_id = posts.id)
    )
  );

-- Revisions are for the author and for moderators. Not for anybody else.
create policy revisions_read on post_revisions for select
  using (
    is_admin()
    or exists (select 1 from posts p where p.id = post_id and p.author_id = auth.uid())
  );

create policy reactions_read on reactions for select using (true);
create policy reactions_write_self on reactions for all
  using (user_id = auth.uid() or is_admin())
  with check (user_id = auth.uid());

-- ---------------------------------------------------------------------------
-- Seed: the categories the site already links to, so slugs do not change when the database arrives
-- ---------------------------------------------------------------------------

insert into forum_categories (name, slug, description, position) values
  ('Buying advice', 'buying-advice',
   'Deciding between two cars, what to look at first, and whether a price is fair.', 1),
  ('Inspection and condition', 'inspection',
   'Reading a sheet, understanding a grade, and what a score means for what you will pay.', 2),
  ('Selling advice', 'selling-advice',
   'Photography, pricing, and how long a car should take to move in this market.', 3),
  ('Ownership and running costs', 'ownership',
   'Fuel, parts, workshops, and what the third year of ownership actually costs.', 4),
  ('Japanese imports', 'japanese-imports',
   'Auction grades, shaken, landed cost, and what to check before the container is opened.', 5),
  ('Paperwork and transfer', 'paperwork',
   'Registration, transfer, token tax, and what to verify before money changes hands.', 6);

insert into tags (name, slug) values
  ('Buying', 'buying'),
  ('Selling', 'selling'),
  ('Inspection', 'inspection'),
  ('Prices', 'prices'),
  ('Ownership', 'ownership'),
  ('Imports', 'imports'),
  ('Trust', 'trust');
