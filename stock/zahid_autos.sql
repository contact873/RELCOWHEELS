-- RELCO Wheels, dealer stock import
-- Source: dealer-stock-template.csv
-- Dealer: zahid_autos (Zahid Autos)
-- Generated: 2026-10-28T14:01:56.985Z
--
-- Before running this, confirm that zahid_autos has authorised us in writing to publish this
-- stock, and that they own the photographs. See docs/dealer-onboarding.md.
--
-- Photographs are assumed to be uploaded already, to dealers/zahid_autos/ in Supabase Storage.

begin;

-- The dealer record, created if it does not exist.
--
-- owner_id stays null: this is a business record created by us, on the dealer's written authority, and
-- it gets claimed later when the owner signs up and we set owner_id. Migration 0004 made that legal.
insert into public.dealers (name, slug, city_id)
values (
  'Zahid Autos',
  'zahid_autos',
  (select id from public.cities where slug = 'lahore')
)
on conflict (slug) do nothing;

-- ZA-0001 2018 Toyota Corolla Altis 1.6 Automatic
with mk as (
  insert into makes (name, slug, vertical)
  values ('Toyota', 'toyota', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Corolla', 'corolla')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
), vr as (
  insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
  values ((select id from md), 'Altis 1.6 Automatic', 'altis-1-6-automatic',
          1600, 'automatic', 'petrol', 'Sedan', 5)
  on conflict (model_id, slug) do update
    set engine_cc = coalesce(excluded.engine_cc, variants.engine_cc),
        transmission = coalesce(excluded.transmission, variants.transmission),
        fuel = coalesce(excluded.fuel, variants.fuel)
  returning id
), ins as (
  insert into listings (
    reference, seller_id, dealer_id, vertical, variant_id, make_id, model_id, model_year,
    title, description, price_pkr, price_on_call, mileage_km, color, assembly,
    registered_in_city_id, city_id, owner_count, is_accidental
  )
  values (
    'ZA-0001',
    (select p.id from profiles p where p.handle = 'zahid_autos'),
    (select d.id from dealers d where d.slug = 'zahid_autos'),
    'car',
    (select id from vr),
    (select id from mk),
    (select id from md),
    2018,
    '2018 Toyota Corolla Altis 1.6 Automatic',
    'Second owner. Full service history at the authorised workshop. Tyres replaced in March.',
    4850000,
    false,
    194000,
    'Super White',
    'local',
    (select id from cities where slug = 'lahore'),
    (select id from cities where slug = 'lahore'),
    2,
    false
  )
  on conflict (reference) do update set
    title = excluded.title,
    description = excluded.description,
    price_pkr = excluded.price_pkr,
    price_on_call = excluded.price_on_call,
    mileage_km = excluded.mileage_km,
    color = excluded.color,
    updated_at = now()
  returning id
)
insert into listing_photos (listing_id, storage_path, position)
select ins.id, '/dealers/zahid_autos/' || v.file, v.position
from ins, (values (0, 'za-0001-1.jpg'), (1, 'za-0001-2.jpg'), (2, 'za-0001-3.jpg'), (3, 'za-0001-4.jpg'), (4, 'za-0001-5.jpg')) as v(position, file)
on conflict (listing_id, position) do nothing;
-- ZA-0002 2019 Suzuki Cultus VXL
with mk as (
  insert into makes (name, slug, vertical)
  values ('Suzuki', 'suzuki', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Cultus', 'cultus')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
), vr as (
  insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
  values ((select id from md), 'VXL', 'vxl',
          1000, 'manual', 'petrol', 'Hatchback', 5)
  on conflict (model_id, slug) do update
    set engine_cc = coalesce(excluded.engine_cc, variants.engine_cc),
        transmission = coalesce(excluded.transmission, variants.transmission),
        fuel = coalesce(excluded.fuel, variants.fuel)
  returning id
), ins as (
  insert into listings (
    reference, seller_id, dealer_id, vertical, variant_id, make_id, model_id, model_year,
    title, description, price_pkr, price_on_call, mileage_km, color, assembly,
    registered_in_city_id, city_id, owner_count, is_accidental
  )
  values (
    'ZA-0002',
    (select p.id from profiles p where p.handle = 'zahid_autos'),
    (select d.id from dealers d where d.slug = 'zahid_autos'),
    'car',
    (select id from vr),
    (select id from mk),
    (select id from md),
    2019,
    '2019 Suzuki Cultus VXL',
    'One owner from new. Original paint throughout, no accident history.',
    3150000,
    false,
    58000,
    'Graphite Grey',
    'local',
    (select id from cities where slug = 'lahore'),
    (select id from cities where slug = 'lahore'),
    1,
    false
  )
  on conflict (reference) do update set
    title = excluded.title,
    description = excluded.description,
    price_pkr = excluded.price_pkr,
    price_on_call = excluded.price_on_call,
    mileage_km = excluded.mileage_km,
    color = excluded.color,
    updated_at = now()
  returning id
)
insert into listing_photos (listing_id, storage_path, position)
select ins.id, '/dealers/zahid_autos/' || v.file, v.position
from ins, (values (0, 'za-0002-1.jpg'), (1, 'za-0002-2.jpg'), (2, 'za-0002-3.jpg')) as v(position, file)
on conflict (listing_id, position) do nothing;
-- ZA-0003 2020 Honda Civic Oriel 1.8 i-VTEC CVT
with mk as (
  insert into makes (name, slug, vertical)
  values ('Honda', 'honda', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Civic', 'civic')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
), vr as (
  insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
  values ((select id from md), 'Oriel 1.8 i-VTEC CVT', 'oriel-1-8-i-vtec-cvt',
          1800, 'automatic', 'petrol', 'Sedan', 5)
  on conflict (model_id, slug) do update
    set engine_cc = coalesce(excluded.engine_cc, variants.engine_cc),
        transmission = coalesce(excluded.transmission, variants.transmission),
        fuel = coalesce(excluded.fuel, variants.fuel)
  returning id
), ins as (
  insert into listings (
    reference, seller_id, dealer_id, vertical, variant_id, make_id, model_id, model_year,
    title, description, price_pkr, price_on_call, mileage_km, color, assembly,
    registered_in_city_id, city_id, owner_count, is_accidental
  )
  values (
    'ZA-0003',
    (select p.id from profiles p where p.handle = 'zahid_autos'),
    (select d.id from dealers d where d.slug = 'zahid_autos'),
    'car',
    (select id from vr),
    (select id from mk),
    (select id from md),
    2020,
    '2020 Honda Civic Oriel 1.8 i-VTEC CVT',
    'Company maintained, all servicing at the dealer. Sunroof and full leather.',
    7250000,
    false,
    66000,
    'Modern Steel',
    'local',
    (select id from cities where slug = 'lahore'),
    (select id from cities where slug = 'lahore'),
    1,
    false
  )
  on conflict (reference) do update set
    title = excluded.title,
    description = excluded.description,
    price_pkr = excluded.price_pkr,
    price_on_call = excluded.price_on_call,
    mileage_km = excluded.mileage_km,
    color = excluded.color,
    updated_at = now()
  returning id
)
insert into listing_photos (listing_id, storage_path, position)
select ins.id, '/dealers/zahid_autos/' || v.file, v.position
from ins, (values (0, 'za-0003-1.jpg'), (1, 'za-0003-2.jpg'), (2, 'za-0003-3.jpg'), (3, 'za-0003-4.jpg'), (4, 'za-0003-5.jpg')) as v(position, file)
on conflict (listing_id, position) do nothing;
-- ZA-0004 2022 KIA Sportage AWD
with mk as (
  insert into makes (name, slug, vertical)
  values ('KIA', 'kia', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Sportage', 'sportage')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
), vr as (
  insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
  values ((select id from md), 'AWD', 'awd',
          2000, 'automatic', 'petrol', 'SUV', 5)
  on conflict (model_id, slug) do update
    set engine_cc = coalesce(excluded.engine_cc, variants.engine_cc),
        transmission = coalesce(excluded.transmission, variants.transmission),
        fuel = coalesce(excluded.fuel, variants.fuel)
  returning id
), ins as (
  insert into listings (
    reference, seller_id, dealer_id, vertical, variant_id, make_id, model_id, model_year,
    title, description, price_pkr, price_on_call, mileage_km, color, assembly,
    registered_in_city_id, city_id, owner_count, is_accidental
  )
  values (
    'ZA-0004',
    (select p.id from profiles p where p.handle = 'zahid_autos'),
    (select d.id from dealers d where d.slug = 'zahid_autos'),
    'car',
    (select id from vr),
    (select id from mk),
    (select id from md),
    2022,
    '2022 KIA Sportage AWD',
    'Still under manufacturer warranty. First owner, non smoker, garage kept.',
    11800000,
    false,
    31000,
    'Snow White Pearl',
    'local',
    (select id from cities where slug = 'lahore'),
    (select id from cities where slug = 'lahore'),
    1,
    false
  )
  on conflict (reference) do update set
    title = excluded.title,
    description = excluded.description,
    price_pkr = excluded.price_pkr,
    price_on_call = excluded.price_on_call,
    mileage_km = excluded.mileage_km,
    color = excluded.color,
    updated_at = now()
  returning id
)
insert into listing_photos (listing_id, storage_path, position)
select ins.id, '/dealers/zahid_autos/' || v.file, v.position
from ins, (values (0, 'za-0004-1.jpg'), (1, 'za-0004-2.jpg'), (2, 'za-0004-3.jpg'), (3, 'za-0004-4.jpg')) as v(position, file)
on conflict (listing_id, position) do nothing;
-- ZA-0005 2014 Toyota Land Cruiser V8 ZX
with mk as (
  insert into makes (name, slug, vertical)
  values ('Toyota', 'toyota', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Land Cruiser', 'land-cruiser')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
), vr as (
  insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
  values ((select id from md), 'V8 ZX', 'v8-zx',
          4600, 'automatic', 'petrol', 'SUV', 7)
  on conflict (model_id, slug) do update
    set engine_cc = coalesce(excluded.engine_cc, variants.engine_cc),
        transmission = coalesce(excluded.transmission, variants.transmission),
        fuel = coalesce(excluded.fuel, variants.fuel)
  returning id
), ins as (
  insert into listings (
    reference, seller_id, dealer_id, vertical, variant_id, make_id, model_id, model_year,
    title, description, price_pkr, price_on_call, mileage_km, color, assembly,
    registered_in_city_id, city_id, owner_count, is_accidental
  )
  values (
    'ZA-0005',
    (select p.id from profiles p where p.handle = 'zahid_autos'),
    (select d.id from dealers d where d.slug = 'zahid_autos'),
    'car',
    (select id from vr),
    (select id from mk),
    (select id from md),
    2014,
    '2014 Toyota Land Cruiser V8 ZX',
    'Japanese import with the original auction sheet, grade 4.5. Price on application.',
    null,
    true,
    112000,
    'Attitude Black',
    'imported',
    (select id from cities where slug = 'islamabad'),
    (select id from cities where slug = 'lahore'),
    2,
    false
  )
  on conflict (reference) do update set
    title = excluded.title,
    description = excluded.description,
    price_pkr = excluded.price_pkr,
    price_on_call = excluded.price_on_call,
    mileage_km = excluded.mileage_km,
    color = excluded.color,
    updated_at = now()
  returning id
)
insert into listing_photos (listing_id, storage_path, position)
select ins.id, '/dealers/zahid_autos/' || v.file, v.position
from ins, (values (0, 'za-0005-1.jpg'), (1, 'za-0005-2.jpg'), (2, 'za-0005-3.jpg')) as v(position, file)
on conflict (listing_id, position) do nothing;
-- ZA-0006 2020 Suzuki Alto VXL AGS
with mk as (
  insert into makes (name, slug, vertical)
  values ('Suzuki', 'suzuki', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Alto', 'alto')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
), vr as (
  insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
  values ((select id from md), 'VXL AGS', 'vxl-ags',
          660, 'automatic', 'petrol', 'Hatchback', 4)
  on conflict (model_id, slug) do update
    set engine_cc = coalesce(excluded.engine_cc, variants.engine_cc),
        transmission = coalesce(excluded.transmission, variants.transmission),
        fuel = coalesce(excluded.fuel, variants.fuel)
  returning id
), ins as (
  insert into listings (
    reference, seller_id, dealer_id, vertical, variant_id, make_id, model_id, model_year,
    title, description, price_pkr, price_on_call, mileage_km, color, assembly,
    registered_in_city_id, city_id, owner_count, is_accidental
  )
  values (
    'ZA-0006',
    (select p.id from profiles p where p.handle = 'zahid_autos'),
    (select d.id from dealers d where d.slug = 'zahid_autos'),
    'car',
    (select id from vr),
    (select id from mk),
    (select id from md),
    2020,
    '2020 Suzuki Alto VXL AGS',
    'One owner, still under warranty, AGS serviced on schedule.',
    2890000,
    false,
    41000,
    'Pearl White',
    'local',
    (select id from cities where slug = 'lahore'),
    (select id from cities where slug = 'lahore'),
    1,
    false
  )
  on conflict (reference) do update set
    title = excluded.title,
    description = excluded.description,
    price_pkr = excluded.price_pkr,
    price_on_call = excluded.price_on_call,
    mileage_km = excluded.mileage_km,
    color = excluded.color,
    updated_at = now()
  returning id
)
insert into listing_photos (listing_id, storage_path, position)
select ins.id, '/dealers/zahid_autos/' || v.file, v.position
from ins, (values (0, 'za-0006-1.jpg'), (1, 'za-0006-2.jpg'), (2, 'za-0006-3.jpg')) as v(position, file)
on conflict (listing_id, position) do nothing;

commit;
