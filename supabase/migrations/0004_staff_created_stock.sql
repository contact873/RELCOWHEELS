-- RELCO Wheels, migration 0004.
--
-- Staff-created dealers and stock.
--
-- A gap in the schema, not a workaround. The plan is that the first two hundred to three hundred cars
-- go up because somebody walks into a showroom, photographs the cars and posts them on the dealer's
-- behalf. The schema as written in 0001 made that impossible: profiles.id references auth.users, so a
-- profile only exists once a person has signed up, and listings.seller_id was NOT NULL. The result was
-- that no car could be listed until its seller had created an account, which is the opposite of how
-- the cold start has to work.
--
-- Three changes, all in the same direction: a dealer record and a listing must be creatable by us,
-- through the service role, without an auth user behind them.
--
--   1. dealers.owner_id becomes nullable. A dealer row can exist as a business record before anyone
--      has claimed it. When the owner does sign up, the row is claimed by setting owner_id.
--   2. listings.seller_id becomes nullable, and a constraint requires that a listing has either a
--      seller or a dealer. Never neither, which would be an orphan nobody is accountable for.
--   3. leads.seller_id becomes nullable for the same reason: a lead on a dealer-created listing has a
--      dealer_id and no seller_id, and it still has to be deliverable.
--
-- What deliberately does NOT change: profiles.id keeps referencing auth.users. Every row-level
-- security policy compares a column to auth.uid(), and if profiles.id stopped being the auth id, all
-- of them would silently stop matching. The fix is at the dealer and listing level, not the identity
-- level.
--
-- Idempotent: every statement is guarded, so it is safe to re-run.

begin;

-- ---------------------------------------------------------------------------
-- 1. A dealer can exist before its owner has signed up
-- ---------------------------------------------------------------------------

alter table public.dealers alter column owner_id drop not null;

comment on column public.dealers.owner_id is
  'Nullable on purpose. A dealer record can be created by staff before the business has an account, '
  'which is how the first stock arrives. Claimed later by setting this to the owner profile id.';

-- ---------------------------------------------------------------------------
-- 2. A listing needs a seller or a dealer, not necessarily both
-- ---------------------------------------------------------------------------

alter table public.listings alter column seller_id drop not null;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'listings_has_a_seller'
  ) then
    alter table public.listings
      add constraint listings_has_a_seller
      check (seller_id is not null or dealer_id is not null);
  end if;
end $$;

comment on constraint listings_has_a_seller on public.listings is
  'A listing must be attributable to somebody. A staff-posted car has a dealer and no seller; a '
  'private seller has a seller and no dealer. Neither being null is an orphan, which is what this '
  'stops.';

-- ---------------------------------------------------------------------------
-- 3. A lead on a dealer listing has nobody in seller_id
-- ---------------------------------------------------------------------------

alter table private.leads alter column seller_id drop not null;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'leads_has_a_recipient'
  ) then
    alter table private.leads
      add constraint leads_has_a_recipient
      check (seller_id is not null or dealer_id is not null);
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- 4. Let a dealer manage the listings that belong to their business
-- ---------------------------------------------------------------------------
--
-- Before this, the policies only recognised `seller_id = auth.uid()`. A dealer whose stock was posted
-- for them could not edit or price their own cars. These replace the old policies with the same rule
-- plus the dealer route, so ownership works whether the listing was posted by the person or for them.

drop policy if exists listings_insert_own on public.listings;
create policy listings_insert_own on public.listings for insert
  with check (
    seller_id = auth.uid()
    or exists (
      select 1 from public.dealers d where d.id = dealer_id and d.owner_id = auth.uid()
    )
  );

drop policy if exists listings_update_own on public.listings;
create policy listings_update_own on public.listings for update
  using (
    seller_id = auth.uid()
    or exists (select 1 from public.dealers d where d.id = dealer_id and d.owner_id = auth.uid())
    or is_admin()
  )
  with check (
    seller_id = auth.uid()
    or exists (select 1 from public.dealers d where d.id = dealer_id and d.owner_id = auth.uid())
    or is_admin()
  );

drop policy if exists listing_photos_write on public.listing_photos;
create policy listing_photos_write on public.listing_photos for all
  using (
    exists (
      select 1 from public.listings l
      left join public.dealers d on d.id = l.dealer_id
      where l.id = listing_id and (l.seller_id = auth.uid() or d.owner_id = auth.uid() or is_admin())
    )
  )
  with check (
    exists (
      select 1 from public.listings l
      left join public.dealers d on d.id = l.dealer_id
      where l.id = listing_id and (l.seller_id = auth.uid() or d.owner_id = auth.uid() or is_admin())
    )
  );

drop policy if exists listing_features_write on public.listing_features;
create policy listing_features_write on public.listing_features for all
  using (
    exists (
      select 1 from public.listings l
      left join public.dealers d on d.id = l.dealer_id
      where l.id = listing_id and (l.seller_id = auth.uid() or d.owner_id = auth.uid() or is_admin())
    )
  )
  with check (
    exists (
      select 1 from public.listings l
      left join public.dealers d on d.id = l.dealer_id
      where l.id = listing_id and (l.seller_id = auth.uid() or d.owner_id = auth.uid() or is_admin())
    )
  );

-- Claiming a dealer row is an update to dealers, which already has a policy for the owner. Nothing to
-- add: the service role creates it, and the owner claims it later by setting owner_id.

commit;
