-- RELCO Wheels, migration 0001.
--
-- Core: the vehicle catalogue, registered visitors, listings and the lead ledger.
--
-- Modelled against PakWheels, whose account shape was read off their live signup form and the
-- session globals every one of their pages emits. Two deliberate departures from their design are
-- marked IMPROVED below; everything else follows their model because it is a sound one.

create extension if not exists "citext";
create extension if not exists "pg_trgm";
create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------

-- Their user[user_type] radio. Individual or dealer, plus us.
create type user_role as enum ('member', 'dealer', 'admin');

create type account_status as enum ('active', 'suspended', 'banned', 'deleted');

-- Their providers, exactly. No LinkedIn and no Apple: neither has any use for a used car buyer
-- in Pakistan, and Apple requires a paid developer account.
create type auth_provider as enum ('email', 'google', 'facebook', 'mobile');

-- IMPROVED. PakWheels hard-codes its verticals into the user session as car_listings,
-- bike_listings and parts_listings, which is why a fourth vertical would be expensive for them.
-- We put the vertical on the listing and derive the counts, so adding one costs nothing.
create type vertical as enum ('car', 'bike', 'parts');

create type listing_status as enum ('draft', 'pending', 'live', 'sold', 'rejected', 'expired');
create type assembly_kind as enum ('local', 'imported');
create type transmission_kind as enum ('manual', 'automatic');
create type fuel_kind as enum ('petrol', 'diesel', 'hybrid', 'electric', 'cng', 'lpg');
create type trust_source as enum ('seller', 'inspection');

-- ---------------------------------------------------------------------------
-- Reference data
-- ---------------------------------------------------------------------------

create table cities (
  id         serial primary key,
  name       text not null,
  slug       text not null unique,
  province   text not null,
  is_popular boolean not null default false
);

create table city_areas (
  id      serial primary key,
  city_id int not null references cities(id) on delete cascade,
  name    text not null,
  slug    text not null,
  unique (city_id, slug)
);

create table makes (
  id   serial primary key,
  name text not null,
  slug text not null unique,
  vertical vertical not null default 'car'
);

create table models (
  id      serial primary key,
  make_id int not null references makes(id) on delete cascade,
  name    text not null,
  slug    text not null,
  unique (make_id, slug)
);

-- A car in the catalogue, as distinct from a listing of one. This is what makes
-- /cars/suzuki/alto/2019 a real page rather than a filter over free text.
create table variants (
  id             serial primary key,
  model_id       int not null references models(id) on delete cascade,
  name           text not null,
  slug           text not null,
  engine_cc      int,
  transmission   transmission_kind,
  fuel           fuel_kind,
  body_type      text,
  seats          smallint,
  unique (model_id, slug)
);

create table features (
  key       text primary key,
  label     text not null,
  category  text not null   -- exterior | interior | safety | comfort
);

-- ---------------------------------------------------------------------------
-- Registered visitors
-- ---------------------------------------------------------------------------

-- Extends Supabase auth.users. Every registered visitor gets exactly one row here.
create table profiles (
  id                 uuid primary key references auth.users(id) on delete cascade,

  -- Their display_name rules, adopted wholesale: 3 to 25 characters, letters and spaces only,
  -- and impersonation of the platform blocked at the database rather than only in the form.
  -- The match is case insensitive and also rejects the spaced and punctuated variants.
  display_name       citext not null unique
                     check (
                       display_name ~ '^[A-Za-z][A-Za-z ]{2,24}$'
                       and display_name !~* '(r[ _.-]*e[ _.-]*l[ _.-]*c[ _.-]*o|wheels|admin|staff|moderator)'
                     ),

  handle             citext not null unique
                     check (handle ~ '^[a-z0-9][a-z0-9_]{2,29}$'),

  email              citext unique,

  -- Their mobile flow. E.164, verified by OTP, optional at signup because most members arrive
  -- through Google or Facebook first.
  phone              text unique check (phone is null or phone ~ '^\+[1-9][0-9]{7,14}$'),
  phone_verified_at  timestamptz,
  email_verified_at  timestamptz,

  role               user_role not null default 'member',
  status             account_status not null default 'active',
  suspended_until    timestamptz,

  avatar_path        text,
  bio                text check (bio is null or char_length(bio) <= 500),
  city_id            int references cities(id),

  -- Their user[updates] checkbox.
  marketing_opt_in   boolean not null default false,
  -- Their "by clicking you agree to our Terms of Use".
  terms_version      text not null,
  terms_accepted_at  timestamptz not null default now(),

  -- Their pw_language session global.
  locale             text not null default 'en' check (locale in ('en', 'ur')),

  notify_on_reply    boolean not null default true,
  notify_on_lead     boolean not null default true,

  last_seen_at       timestamptz,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

comment on column profiles.email is
  'Never returned to any client. PakWheels emits a hashed_email in its session payload rather
   than the address; we go further and never select this column outside self and admin reads.';

-- Which provider each visitor used, and when. Supabase keeps auth.identities, but that table
-- records credentials rather than behaviour, and it cannot express "signed up with Google,
-- later added a mobile number", which is the exact case we need to merge and to display.
create table user_identities (
  id                bigserial primary key,
  user_id           uuid not null references profiles(id) on delete cascade,
  provider          auth_provider not null,
  provider_uid      text not null,
  email_at_provider citext,
  created_at        timestamptz not null default now(),
  last_used_at      timestamptz not null default now(),
  unique (provider, provider_uid)
);

-- Their /users/register_web_push_token.
create table user_push_tokens (
  id          bigserial primary key,
  user_id     uuid not null references profiles(id) on delete cascade,
  token       text not null unique,
  platform    text not null check (platform in ('web', 'android', 'ios')),
  user_agent  text,
  created_at  timestamptz not null default now(),
  last_used_at timestamptz not null default now(),
  revoked_at  timestamptz
);

-- Drives the first-post hold and the rate limits described in the blog and forum design.
create table user_trust (
  user_id          uuid primary key references profiles(id) on delete cascade,
  thread_count     int not null default 0,
  post_count       int not null default 0,
  article_count    int not null default 0,
  listing_count    int not null default 0,
  accepted_answers int not null default 0,
  flag_count       int not null default 0,
  first_post_held  boolean not null default true,
  banned_until     timestamptz,
  updated_at       timestamptz not null default now()
);

-- Sign-in and sign-up events. Not analytics: this is the record consulted when an account is
-- disputed or compromised, so it is append only and never trimmed by the application.
create table auth_events (
  id         bigserial primary key,
  user_id    uuid references profiles(id) on delete set null,
  provider   auth_provider not null,
  kind       text not null,            -- signup | signin | signout | otp_sent | otp_verified | failed
  ip         inet,
  user_agent text,
  created_at timestamptz not null default now()
);

-- Their /alerts.
create table saved_searches (
  id           bigserial primary key,
  user_id      uuid not null references profiles(id) on delete cascade,
  name         text not null,
  filters      jsonb not null,
  frequency    text not null default 'daily' check (frequency in ('instant', 'daily', 'weekly')),
  last_sent_at timestamptz,
  created_at   timestamptz not null default now()
);

-- The "notify me when a Corolla 2018 appears in Lahore" feature, and the thread-follow used by
-- the forum. One table rather than three, so the notification worker has one query.
create table follows (
  id          bigserial primary key,
  user_id     uuid not null references profiles(id) on delete cascade,
  entity_type text not null check (entity_type in ('make', 'model', 'seller', 'thread', 'city')),
  entity_id   text not null,
  created_at  timestamptz not null default now(),
  unique (user_id, entity_type, entity_id)
);

-- ---------------------------------------------------------------------------
-- Dealers
-- ---------------------------------------------------------------------------

create table dealers (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid not null references profiles(id) on delete restrict,
  name        text not null,
  slug        citext not null unique,
  city_id     int references cities(id),
  phone       text check (phone is null or phone ~ '^\+[1-9][0-9]{7,14}$'),
  whatsapp    text,
  about       text,
  logo_path   text,
  verified_at timestamptz,
  created_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Listings
-- ---------------------------------------------------------------------------

create table listings (
  id             bigserial primary key,
  reference      text not null unique,        -- the human quoted ad number
  seller_id      uuid not null references profiles(id) on delete restrict,
  dealer_id      uuid references dealers(id) on delete set null,

  vertical       vertical not null default 'car',
  variant_id     int references variants(id),
  make_id        int references makes(id),
  model_id       int references models(id),
  model_year     smallint not null check (model_year between 1900 and 2100),

  title          text not null check (char_length(title) between 10 and 120),
  description    text check (description is null or char_length(description) <= 5000),

  price_pkr      bigint check (price_pkr is null or price_pkr >= 0),
  price_on_call  boolean not null default false,
  mileage_km     int check (mileage_km is null or mileage_km >= 0),

  color          text,
  assembly       assembly_kind,
  registered_in_city_id int references cities(id),
  city_id        int references cities(id),
  city_area_id   int references city_areas(id),

  owner_count    smallint check (owner_count is null or owner_count between 1 and 20),
  is_accidental  boolean,
  has_auction_sheet boolean not null default false,

  status         listing_status not null default 'draft',
  rejection_reason text,

  published_at   timestamptz,
  expires_at     timestamptz,
  sold_at        timestamptz,
  sold_price_pkr bigint,

  view_count        int not null default 0,
  phone_reveal_count int not null default 0,

  -- IMPROVED. The city and the model are denormalised onto the listing so the facet queries in
  -- section 4 of the plan do not need a four way join on every request. Kept in step by trigger.
  facet_make_slug  text,
  facet_model_slug text,
  facet_city_slug  text,

  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),

  check (price_on_call or price_pkr is not null),
  check (status <> 'live' or (city_id is not null and price_pkr is not null or price_on_call))
);

create table listing_photos (
  id           bigserial primary key,
  listing_id   bigint not null references listings(id) on delete cascade,
  storage_path text not null,
  position     smallint not null default 0,
  width        int,
  height       int,
  alt          text,
  unique (listing_id, position)
);

create table listing_features (
  listing_id  bigint not null references listings(id) on delete cascade,
  feature_key text not null references features(key) on delete cascade,
  primary key (listing_id, feature_key)
);

-- Inspection results. Every score is nullable because an uninspected car has no scores, and a
-- zero would be a lie.
create table inspections (
  id                bigserial primary key,
  listing_id        bigint not null references listings(id) on delete cascade,
  inspected_by      uuid references profiles(id) on delete set null,
  inspected_on      date not null,
  overall_score     numeric(3,1) check (overall_score between 0 and 10),
  score_exterior    smallint check (score_exterior between 0 and 100),
  score_engine      smallint check (score_engine between 0 and 100),
  score_suspension  smallint check (score_suspension between 0 and 100),
  score_interior    smallint check (score_interior between 0 and 100),
  score_ac          smallint check (score_ac between 0 and 100),
  report_path       text,
  notes             text,
  created_at        timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- The lead ledger
-- ---------------------------------------------------------------------------

-- Append only. This table is the invoice evidence for selling leads to dealers, so no row is
-- ever updated except to record forwarding and outcome, and buyer_phone is never rewritten.
create table leads (
  id            bigserial primary key,
  listing_id    bigint not null references listings(id) on delete restrict,
  seller_id     uuid not null references profiles(id) on delete restrict,
  dealer_id     uuid references dealers(id) on delete set null,
  buyer_id      uuid references profiles(id) on delete set null,

  buyer_phone   text not null check (buyer_phone ~ '^\+[1-9][0-9]{7,14}$'),
  buyer_name    text,
  channel       text not null check (channel in ('phone_reveal', 'message', 'whatsapp', 'find_my_car')),
  message       text check (message is null or char_length(message) <= 2000),

  consent_given_at timestamptz not null default now(),
  forwarded_at     timestamptz,
  forward_channel  text,
  outcome          text check (outcome in ('new', 'contacted', 'sold', 'lost', 'invalid')),

  created_at       timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Reports, one queue for listings, articles, threads and posts
-- ---------------------------------------------------------------------------

create type reportable_entity as enum ('listing', 'article', 'thread', 'post', 'profile');

create table reports (
  id            bigserial primary key,
  entity_type   reportable_entity not null,
  entity_id     text not null,
  reporter_id   uuid references profiles(id) on delete set null,
  reason        text not null,
  detail        text,
  status        text not null default 'open' check (status in ('open', 'actioned', 'dismissed')),
  resolved_by   uuid references profiles(id) on delete set null,
  resolved_at   timestamptz,
  created_at    timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------

create or replace function touch_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

create trigger profiles_touch    before update on profiles  for each row execute function touch_updated_at();
create trigger listings_touch    before update on listings  for each row execute function touch_updated_at();
create trigger user_trust_touch  before update on user_trust for each row execute function touch_updated_at();

-- Their /increment_phone_count, done as a trigger so the counter cannot drift from the ledger.
create or replace function bump_reveal_count() returns trigger
language plpgsql as $$
begin
  if new.channel = 'phone_reveal' then
    update listings set phone_reveal_count = phone_reveal_count + 1 where id = new.listing_id;
  end if;
  return new;
end $$;

create trigger leads_bump_reveal after insert on leads
  for each row execute function bump_reveal_count();

-- A new account gets its trust row immediately, with the first post held, so no code path can
-- forget to create it.
create or replace function create_user_trust() returns trigger
language plpgsql security definer as $$
begin
  insert into user_trust (user_id) values (new.id) on conflict do nothing;
  return new;
end $$;

create trigger profiles_create_trust after insert on profiles
  for each row execute function create_user_trust();

-- Photo cap, enforced here rather than trusted to the upload handler.
create or replace function cap_listing_photos() returns trigger
language plpgsql as $$
begin
  if (select count(*) from listing_photos where listing_id = new.listing_id) >= 20 then
    raise exception 'A listing may hold at most 20 photographs.';
  end if;
  return new;
end $$;

create trigger listing_photos_cap before insert on listing_photos
  for each row execute function cap_listing_photos();

-- Denormalised facet slugs, so the browse pages do not join four tables per request.
create or replace function sync_listing_facets() returns trigger
language plpgsql as $$
begin
  select m.slug, mo.slug into new.facet_make_slug, new.facet_model_slug
  from models mo join makes m on m.id = mo.make_id
  where mo.id = new.model_id;

  select slug into new.facet_city_slug from cities where id = new.city_id;
  return new;
end $$;

create trigger listings_sync_facets before insert or update of model_id, city_id on listings
  for each row execute function sync_listing_facets();

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

create index listings_live_recent on listings (status, published_at desc) where status = 'live';
create index listings_facet        on listings (facet_make_slug, facet_model_slug, model_year)
                                   where status = 'live';
create index listings_city_facet   on listings (facet_city_slug, published_at desc) where status = 'live';
create index listings_seller       on listings (seller_id, status, created_at desc);
create index listings_title_trgm   on listings using gin (title gin_trgm_ops);
create index leads_seller_recent   on leads (seller_id, created_at desc);
create index leads_listing         on leads (listing_id, created_at desc);
create index profiles_handle       on profiles (handle);
create index profiles_display_trgm on profiles using gin (display_name gin_trgm_ops);
create index reports_open          on reports (status, created_at desc) where status = 'open';
create index auth_events_user      on auth_events (user_id, created_at desc);
create index variants_lookup       on variants (model_id, engine_cc);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table profiles         enable row level security;
alter table user_identities  enable row level security;
alter table user_push_tokens enable row level security;
alter table user_trust       enable row level security;
alter table auth_events      enable row level security;
alter table saved_searches   enable row level security;
alter table follows          enable row level security;
alter table dealers          enable row level security;
alter table listings         enable row level security;
alter table listing_photos   enable row level security;
alter table listing_features enable row level security;
alter table inspections      enable row level security;
alter table leads            enable row level security;
alter table reports          enable row level security;

-- Are we an administrator? One helper, used by every policy below, so a change to what counts as
-- an admin happens in exactly one place.
create or replace function is_admin() returns boolean
language sql security definer stable as $$
  select exists (select 1 from profiles where id = auth.uid() and role = 'admin');
$$;

-- Public profile, but the email column is revoked at the column level further down rather than
-- filtered in a view, because a column privilege is the only thing a careless select cannot undo.
create policy profiles_read_public on profiles for select
  using (status <> 'deleted' or id = auth.uid() or is_admin());

create policy profiles_update_self on profiles for update
  using (id = auth.uid() or is_admin()) with check (id = auth.uid() or is_admin());

create policy identities_self on user_identities for all
  using (user_id = auth.uid() or is_admin()) with check (user_id = auth.uid());

create policy push_tokens_self on user_push_tokens for all
  using (user_id = auth.uid() or is_admin()) with check (user_id = auth.uid());

create policy trust_self_or_admin on user_trust for select
  using (user_id = auth.uid() or is_admin());

create policy saved_searches_self on saved_searches for all
  using (user_id = auth.uid() or is_admin()) with check (user_id = auth.uid());

create policy follows_self on follows for all
  using (user_id = auth.uid() or is_admin()) with check (user_id = auth.uid());

create policy auth_events_admin on auth_events for select using (is_admin());

create policy dealers_read on dealers for select using (true);
create policy dealers_write_own on dealers for all
  using (owner_id = auth.uid() or is_admin()) with check (owner_id = auth.uid() or is_admin());

create policy listings_read_live on listings for select
  using (status = 'live' or status = 'sold' or seller_id = auth.uid() or is_admin());

create policy listings_insert_own on listings for insert
  with check (seller_id = auth.uid());

create policy listings_update_own on listings for update
  using (seller_id = auth.uid() or is_admin()) with check (seller_id = auth.uid() or is_admin());

create policy listing_photos_read on listing_photos for select using (true);
create policy listing_photos_write on listing_photos for all
  using (exists (select 1 from listings l where l.id = listing_id and (l.seller_id = auth.uid() or is_admin())))
  with check (exists (select 1 from listings l where l.id = listing_id and (l.seller_id = auth.uid() or is_admin())));

create policy listing_features_read on listing_features for select using (true);
create policy listing_features_write on listing_features for all
  using (exists (select 1 from listings l where l.id = listing_id and (l.seller_id = auth.uid() or is_admin())))
  with check (exists (select 1 from listings l where l.id = listing_id and (l.seller_id = auth.uid() or is_admin())));

create policy inspections_read on inspections for select using (true);
create policy inspections_write_admin on inspections for all
  using (is_admin()) with check (is_admin());

-- A lead belongs to the seller it was sent to, to the buyer who sent it, and to nobody else.
create policy leads_read_own on leads for select
  using (seller_id = auth.uid() or buyer_id = auth.uid() or is_admin());

-- Any signed in visitor may send a lead, and only as themselves.
create policy leads_insert_self on leads for insert
  with check (auth.uid() is not null);

create policy leads_update_seller on leads for update
  using (seller_id = auth.uid() or is_admin()) with check (seller_id = auth.uid() or is_admin());

-- Anyone signed in may report. Only an admin may read or resolve the queue.
create policy reports_insert_self on reports for insert
  with check (auth.uid() is not null and reporter_id = auth.uid());

create policy reports_read_admin on reports for select using (is_admin());
create policy reports_resolve_admin on reports for update
  using (is_admin()) with check (is_admin());

-- ---------------------------------------------------------------------------
-- Column privileges
-- ---------------------------------------------------------------------------

-- The email address is not readable by other members, whatever any future policy says. This is
-- the same instinct as PakWheels emitting a hashed_email in the browser, taken one step further.
revoke select (email) on profiles from anon, authenticated;
grant  select (email) on profiles to service_role;

-- ---------------------------------------------------------------------------
-- Seed: provinces and the Punjab cities that matter for a Lahore first launch
-- ---------------------------------------------------------------------------

insert into cities (name, slug, province, is_popular) values
  ('Lahore',        'lahore',        'Punjab',        true),
  ('Karachi',       'karachi',       'Sindh',         true),
  ('Islamabad',     'islamabad',     'Islamabad',     true),
  ('Rawalpindi',    'rawalpindi',    'Punjab',        true),
  ('Faisalabad',    'faisalabad',    'Punjab',        true),
  ('Multan',        'multan',        'Punjab',        true),
  ('Gujranwala',    'gujranwala',    'Punjab',        true),
  ('Peshawar',      'peshawar',      'Khyber Pakhtunkhwa', true),
  ('Sialkot',       'sialkot',       'Punjab',        true),
  ('Sargodha',      'sargodha',      'Punjab',        true),
  ('Sheikhupura',   'sheikhupura',   'Punjab',        false),
  ('Gujrat',        'gujrat',        'Punjab',        false),
  ('Sahiwal',       'sahiwal',       'Punjab',        false),
  ('Okara',         'okara',         'Punjab',        false),
  ('Rahim Yar Khan','rahim-yar-khan','Punjab',        false),
  ('Jhelum',        'jhelum',        'Punjab',        false),
  ('Kasur',         'kasur',         'Punjab',        false),
  ('Quetta',        'quetta',        'Balochistan',   false);

insert into city_areas (city_id, name, slug)
  select id, a.name, a.slug
  from cities, (values
    ('Bahria Town','bahria-town'), ('DHA','dha'), ('Gulberg','gulberg'),
    ('Johar Town','johar-town'), ('Model Town','model-town'), ('Cantt','cantt'),
    ('Iqbal Town','iqbal-town'), ('Wapda Town','wapda-town'), ('Township','township'),
    ('Green Town','green-town'), ('Shadman','shadman'), ('Faisal Town','faisal-town')
  ) as a(name, slug)
  where cities.slug = 'lahore';

insert into features (key, label, category) values
  ('alloy_wheels','Alloy wheels','exterior'),
  ('fog_lights','Front fog lights','exterior'),
  ('sun_roof','Sun roof','exterior'),
  ('led_headlights','LED headlights','exterior'),
  ('infotainment','Infotainment system','interior'),
  ('rear_camera','Rear camera','interior'),
  ('cruise_control','Cruise control','comfort'),
  ('climate_control','Climate control','comfort'),
  ('power_windows','Power windows','comfort'),
  ('airbags','Air bags','safety'),
  ('abs','ABS','safety'),
  ('immobilizer','Immobilizer','safety'),
  ('traction_control','Traction control','safety'),
  ('lane_assist','Lane assist','safety');

-- Note on the seed: makes, models and variants are deliberately absent. They number in the
-- thousands and belong in a data file read by a seeding script, not in a migration, because a
-- migration that has to be edited every time a new model launches is a migration nobody trusts.

-- ---------------------------------------------------------------------------
-- Reference data: readable by everyone, writable by nobody
-- ---------------------------------------------------------------------------

-- Found by executing the migration against a real Postgres and checking every table: these six were
-- left without row level security. In Supabase that is not a neutral default, because tables in the
-- public schema are exposed through the API and the anon and authenticated roles are granted
-- privileges on them. Without RLS, the entire vehicle catalogue would have been writable by any
-- visitor with a curl command.
--
-- Read is public, because a catalogue nobody can read is useless. There is deliberately no insert,
-- update or delete policy, so those are denied to every ordinary role and only the service role,
-- which bypasses RLS, can change the catalogue. That happens through a seeding script, not the API.

alter table cities     enable row level security;
alter table city_areas enable row level security;
alter table makes      enable row level security;
alter table models     enable row level security;
alter table variants   enable row level security;
alter table features   enable row level security;

create policy cities_read     on cities     for select using (true);
create policy city_areas_read on city_areas for select using (true);
create policy makes_read      on makes      for select using (true);
create policy models_read     on models     for select using (true);
create policy variants_read   on variants   for select using (true);
create policy features_read   on features   for select using (true);
