-- RELCO Wheels, vehicle catalogue
-- Source: data/catalogue.json
-- Generated: 2026-10-31T17:41:50.366Z
--
-- Idempotent: re-running updates names and engine sizes rather than duplicating a make.
-- Run this after the three migrations, in the Supabase SQL editor, or with psql.

begin;

-- Suzuki / Alto, 3 variants
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
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('VXR', 'vxr', 660, 'manual', 'petrol', 'Hatchback', 4),
    ('VXR-AGS', 'vxr-ags', 660, 'automatic', 'petrol', 'Hatchback', 4),
    ('VXL-AGS', 'vxl-ags', 660, 'automatic', 'petrol', 'Hatchback', 4)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'suzuki') and slug = 'alto')
   and v.slug not in ('vxr', 'vxr-ags', 'vxl-ags')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Suzuki / Cultus, 3 variants
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
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('VXR', 'vxr', 1000, 'manual', 'petrol', 'Hatchback', 5),
    ('VXL', 'vxl', 1000, 'manual', 'petrol', 'Hatchback', 5),
    ('VXL AGS', 'vxl-ags', 1000, 'automatic', 'petrol', 'Hatchback', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'suzuki') and slug = 'cultus')
   and v.slug not in ('vxr', 'vxl', 'vxl-ags')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Suzuki / Wagon R, 3 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Suzuki', 'suzuki', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Wagon R', 'wagon-r')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('VXR', 'vxr', 1000, 'manual', 'petrol', 'Hatchback', 5),
    ('VXL', 'vxl', 1000, 'manual', 'petrol', 'Hatchback', 5),
    ('VXL AGS', 'vxl-ags', 1000, 'automatic', 'petrol', 'Hatchback', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'suzuki') and slug = 'wagon-r')
   and v.slug not in ('vxr', 'vxl', 'vxl-ags')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Suzuki / Swift, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Suzuki', 'suzuki', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Swift', 'swift')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('GL', 'gl', 1200, 'manual', 'petrol', 'Hatchback', 5),
    ('GLX', 'glx', 1200, 'automatic', 'petrol', 'Hatchback', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'suzuki') and slug = 'swift')
   and v.slug not in ('gl', 'glx')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Suzuki / Mehran, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Suzuki', 'suzuki', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Mehran', 'mehran')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('VX', 'vx', 800, 'manual', 'petrol', 'Hatchback', 4),
    ('VXR', 'vxr', 800, 'manual', 'petrol', 'Hatchback', 4)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'suzuki') and slug = 'mehran')
   and v.slug not in ('vx', 'vxr')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Suzuki / Bolan, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Suzuki', 'suzuki', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Bolan', 'bolan')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('Cargo', 'cargo', 800, 'manual', 'petrol', 'Van', 7)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'suzuki') and slug = 'bolan')
   and v.slug not in ('cargo')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Suzuki / Every, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Suzuki', 'suzuki', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Every', 'every')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('Join', 'join', 660, 'automatic', 'petrol', 'Van', 7),
    ('PA', 'pa', 660, 'automatic', 'petrol', 'Van', 7)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'suzuki') and slug = 'every')
   and v.slug not in ('join', 'pa')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Suzuki / Jimny, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Suzuki', 'suzuki', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Jimny', 'jimny')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('JLX', 'jlx', 1500, 'manual', 'petrol', 'SUV', 4),
    ('GLX', 'glx', 1500, 'automatic', 'petrol', 'SUV', 4)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'suzuki') and slug = 'jimny')
   and v.slug not in ('jlx', 'glx')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Toyota / Corolla, 4 variants
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
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('XLi 1.3', 'xli-1-3', 1300, 'manual', 'petrol', 'Sedan', 5),
    ('GLi 1.3', 'gli-1-3', 1300, 'manual', 'petrol', 'Sedan', 5),
    ('Altis 1.6 Automatic', 'altis-1-6-automatic', 1600, 'automatic', 'petrol', 'Sedan', 5),
    ('Altis Grande 1.8', 'altis-grande-1-8', 1800, 'automatic', 'petrol', 'Sedan', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'toyota') and slug = 'corolla')
   and v.slug not in ('xli-1-3', 'gli-1-3', 'altis-1-6-automatic', 'altis-grande-1-8')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Toyota / Yaris, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Toyota', 'toyota', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Yaris', 'yaris')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('1.3 ATIV', '1-3-ativ', 1300, 'manual', 'petrol', 'Sedan', 5),
    ('1.5 ATIV X CVT', '1-5-ativ-x-cvt', 1500, 'automatic', 'petrol', 'Sedan', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'toyota') and slug = 'yaris')
   and v.slug not in ('1-3-ativ', '1-5-ativ-x-cvt')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Toyota / Prius, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Toyota', 'toyota', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Prius', 'prius')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('S', 's', 1800, 'automatic', 'hybrid', 'Hatchback', 5),
    ('S Touring Selection', 's-touring-selection', 1800, 'automatic', 'hybrid', 'Hatchback', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'toyota') and slug = 'prius')
   and v.slug not in ('s', 's-touring-selection')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Toyota / Vitz, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Toyota', 'toyota', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Vitz', 'vitz')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('F', 'f', 1000, 'automatic', 'petrol', 'Hatchback', 5),
    ('FL', 'fl', 1000, 'automatic', 'petrol', 'Hatchback', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'toyota') and slug = 'vitz')
   and v.slug not in ('f', 'fl')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Toyota / Fortuner, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Toyota', 'toyota', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Fortuner', 'fortuner')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('2.7 VVTi', '2-7-vvti', 2700, 'automatic', 'petrol', 'SUV', 7),
    ('2.8 Sigma 4', '2-8-sigma-4', 2800, 'automatic', 'diesel', 'SUV', 7)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'toyota') and slug = 'fortuner')
   and v.slug not in ('2-7-vvti', '2-8-sigma-4')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Toyota / Prado, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Toyota', 'toyota', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Prado', 'prado')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('TX', 'tx', 2700, 'automatic', 'petrol', 'SUV', 7),
    ('TX L Package', 'tx-l-package', 2700, 'automatic', 'petrol', 'SUV', 7)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'toyota') and slug = 'prado')
   and v.slug not in ('tx', 'tx-l-package')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Toyota / Land Cruiser, 2 variants
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
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('V8 ZX', 'v8-zx', 4600, 'automatic', 'petrol', 'SUV', 7),
    ('V8 VX', 'v8-vx', 4600, 'automatic', 'petrol', 'SUV', 7)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'toyota') and slug = 'land-cruiser')
   and v.slug not in ('v8-zx', 'v8-vx')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Toyota / Hilux, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Toyota', 'toyota', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Hilux', 'hilux')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('Single Cabin', 'single-cabin', 2800, 'manual', 'diesel', 'Pick Up', 2),
    ('Revo Double Cabin', 'revo-double-cabin', 2800, 'automatic', 'diesel', 'Double Cabin', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'toyota') and slug = 'hilux')
   and v.slug not in ('single-cabin', 'revo-double-cabin')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Toyota / Hiace, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Toyota', 'toyota', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Hiace', 'hiace')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('Standard', 'standard', 2700, 'manual', 'diesel', 'Van', 12),
    ('Grand Cabin', 'grand-cabin', 2700, 'manual', 'diesel', 'Van', 14)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'toyota') and slug = 'hiace')
   and v.slug not in ('standard', 'grand-cabin')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Toyota / Camry, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Toyota', 'toyota', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Camry', 'camry')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('2.4', '2-4', 2400, 'automatic', 'petrol', 'Sedan', 5),
    ('2.5 Hybrid', '2-5-hybrid', 2500, 'automatic', 'hybrid', 'Sedan', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'toyota') and slug = 'camry')
   and v.slug not in ('2-4', '2-5-hybrid')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Toyota / Raize, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Toyota', 'toyota', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Raize', 'raize')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('X', 'x', 1000, 'automatic', 'petrol', 'SUV', 5),
    ('Z', 'z', 1000, 'automatic', 'petrol', 'SUV', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'toyota') and slug = 'raize')
   and v.slug not in ('x', 'z')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Toyota / Passo, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Toyota', 'toyota', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Passo', 'passo')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('X', 'x', 1000, 'automatic', 'petrol', 'Hatchback', 5),
    ('Moda G', 'moda-g', 1000, 'automatic', 'petrol', 'Hatchback', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'toyota') and slug = 'passo')
   and v.slug not in ('x', 'moda-g')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Honda / Civic, 3 variants
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
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('VTi 1.8', 'vti-1-8', 1800, 'manual', 'petrol', 'Sedan', 5),
    ('Oriel 1.8 i-VTEC CVT', 'oriel-1-8-i-vtec-cvt', 1800, 'automatic', 'petrol', 'Sedan', 5),
    ('RS Turbo', 'rs-turbo', 1500, 'automatic', 'petrol', 'Sedan', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'honda') and slug = 'civic')
   and v.slug not in ('vti-1-8', 'oriel-1-8-i-vtec-cvt', 'rs-turbo')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Honda / City, 3 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Honda', 'honda', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'City', 'city')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('1.3 i-VTEC', '1-3-i-vtec', 1300, 'manual', 'petrol', 'Sedan', 5),
    ('1.3 i-VTEC Prosmatec', '1-3-i-vtec-prosmatec', 1300, 'automatic', 'petrol', 'Sedan', 5),
    ('1.5 Aspire CVT', '1-5-aspire-cvt', 1500, 'automatic', 'petrol', 'Sedan', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'honda') and slug = 'city')
   and v.slug not in ('1-3-i-vtec', '1-3-i-vtec-prosmatec', '1-5-aspire-cvt')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Honda / BR-V, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Honda', 'honda', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'BR-V', 'br-v')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('i-VTEC S', 'i-vtec-s', 1500, 'manual', 'petrol', 'SUV', 7)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'honda') and slug = 'br-v')
   and v.slug not in ('i-vtec-s')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Honda / HR-V, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Honda', 'honda', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'HR-V', 'hr-v')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('VTi-S', 'vti-s', 1500, 'automatic', 'petrol', 'Crossover', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'honda') and slug = 'hr-v')
   and v.slug not in ('vti-s')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Honda / Vezel, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Honda', 'honda', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Vezel', 'vezel')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('X Honda Sensing', 'x-honda-sensing', 1500, 'automatic', 'hybrid', 'Crossover', 5),
    ('Z', 'z', 1500, 'automatic', 'hybrid', 'Crossover', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'honda') and slug = 'vezel')
   and v.slug not in ('x-honda-sensing', 'z')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Honda / Accord, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Honda', 'honda', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Accord', 'accord')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('2.4', '2-4', 2400, 'automatic', 'petrol', 'Sedan', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'honda') and slug = 'accord')
   and v.slug not in ('2-4')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- KIA / Sportage, 3 variants
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
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('FWD', 'fwd', 2000, 'automatic', 'petrol', 'SUV', 5),
    ('AWD', 'awd', 2000, 'automatic', 'petrol', 'SUV', 5),
    ('Alpha', 'alpha', 2000, 'automatic', 'petrol', 'SUV', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'kia') and slug = 'sportage')
   and v.slug not in ('fwd', 'awd', 'alpha')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- KIA / Picanto, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('KIA', 'kia', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Picanto', 'picanto')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('1.0 Manual', '1-0-manual', 1000, 'manual', 'petrol', 'Hatchback', 5),
    ('1.0 Automatic', '1-0-automatic', 1000, 'automatic', 'petrol', 'Hatchback', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'kia') and slug = 'picanto')
   and v.slug not in ('1-0-manual', '1-0-automatic')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- KIA / Stonic, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('KIA', 'kia', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Stonic', 'stonic')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('EX', 'ex', 1400, 'automatic', 'petrol', 'Crossover', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'kia') and slug = 'stonic')
   and v.slug not in ('ex')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Hyundai / Tucson, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Hyundai', 'hyundai', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Tucson', 'tucson')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('FWD GLS Sport', 'fwd-gls-sport', 2000, 'automatic', 'petrol', 'SUV', 5),
    ('AWD Ultimate', 'awd-ultimate', 2000, 'automatic', 'petrol', 'SUV', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'hyundai') and slug = 'tucson')
   and v.slug not in ('fwd-gls-sport', 'awd-ultimate')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Hyundai / Elantra, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Hyundai', 'hyundai', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Elantra', 'elantra')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('GLS', 'gls', 2000, 'automatic', 'petrol', 'Sedan', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'hyundai') and slug = 'elantra')
   and v.slug not in ('gls')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Hyundai / Santro, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Hyundai', 'hyundai', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Santro', 'santro')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('GL', 'gl', 1000, 'manual', 'petrol', 'Hatchback', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'hyundai') and slug = 'santro')
   and v.slug not in ('gl')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Hyundai / Sonata, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Hyundai', 'hyundai', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Sonata', 'sonata')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('2.5', '2-5', 2500, 'automatic', 'petrol', 'Sedan', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'hyundai') and slug = 'sonata')
   and v.slug not in ('2-5')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Daihatsu / Mira, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Daihatsu', 'daihatsu', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Mira', 'mira')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('L SA III', 'l-sa-iii', 660, 'automatic', 'petrol', 'Hatchback', 4),
    ('X', 'x', 660, 'automatic', 'petrol', 'Hatchback', 4)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'daihatsu') and slug = 'mira')
   and v.slug not in ('l-sa-iii', 'x')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Daihatsu / Cuore, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Daihatsu', 'daihatsu', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Cuore', 'cuore')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('CX', 'cx', 850, 'manual', 'petrol', 'Hatchback', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'daihatsu') and slug = 'cuore')
   and v.slug not in ('cx')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Daihatsu / Move, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Daihatsu', 'daihatsu', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Move', 'move')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('L', 'l', 660, 'automatic', 'petrol', 'Hatchback', 4)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'daihatsu') and slug = 'move')
   and v.slug not in ('l')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Nissan / Dayz, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Nissan', 'nissan', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Dayz', 'dayz')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('Highway Star', 'highway-star', 660, 'automatic', 'petrol', 'Hatchback', 4),
    ('X', 'x', 660, 'automatic', 'petrol', 'Hatchback', 4)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'nissan') and slug = 'dayz')
   and v.slug not in ('highway-star', 'x')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Nissan / Note, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Nissan', 'nissan', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Note', 'note')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('e-Power', 'e-power', 1200, 'automatic', 'hybrid', 'Hatchback', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'nissan') and slug = 'note')
   and v.slug not in ('e-power')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Changan / Alsvin, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Changan', 'changan', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Alsvin', 'alsvin')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('Comfort', 'comfort', 1400, 'manual', 'petrol', 'Sedan', 5),
    ('Lumiere', 'lumiere', 1500, 'automatic', 'petrol', 'Sedan', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'changan') and slug = 'alsvin')
   and v.slug not in ('comfort', 'lumiere')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Changan / Oshan X7, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Changan', 'changan', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Oshan X7', 'oshan-x7')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('Comfort', 'comfort', 1500, 'automatic', 'petrol', 'SUV', 7),
    ('FutureSense', 'futuresense', 1500, 'automatic', 'petrol', 'SUV', 7)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'changan') and slug = 'oshan-x7')
   and v.slug not in ('comfort', 'futuresense')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Changan / Karvaan, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Changan', 'changan', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Karvaan', 'karvaan')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('Base', 'base', 1000, 'manual', 'petrol', 'Van', 7)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'changan') and slug = 'karvaan')
   and v.slug not in ('base')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- MG / HS, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('MG', 'mg', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'HS', 'hs')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('1.5 Turbo', '1-5-turbo', 1500, 'automatic', 'petrol', 'SUV', 5),
    ('Trophy', 'trophy', 1500, 'automatic', 'petrol', 'SUV', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'mg') and slug = 'hs')
   and v.slug not in ('1-5-turbo', 'trophy')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- MG / ZS, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('MG', 'mg', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'ZS', 'zs')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('1.5', '1-5', 1500, 'automatic', 'petrol', 'SUV', 5),
    ('EV', 'ev', null, 'automatic', 'electric', 'SUV', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'mg') and slug = 'zs')
   and v.slug not in ('1-5', 'ev')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Haval / H6, 3 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Haval', 'haval', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'H6', 'h6')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('1.5 Turbo', '1-5-turbo', 1500, 'automatic', 'petrol', 'SUV', 5),
    ('HEV', 'hev', 1500, 'automatic', 'hybrid', 'SUV', 5),
    ('PHEV', 'phev', 1500, 'automatic', 'hybrid', 'SUV', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'haval') and slug = 'h6')
   and v.slug not in ('1-5-turbo', 'hev', 'phev')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Haval / Jolion, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Haval', 'haval', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Jolion', 'jolion')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('1.5 Turbo', '1-5-turbo', 1500, 'automatic', 'petrol', 'Crossover', 5),
    ('HEV', 'hev', 1500, 'automatic', 'hybrid', 'Crossover', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'haval') and slug = 'jolion')
   and v.slug not in ('1-5-turbo', 'hev')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Jaecoo / J5, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Jaecoo', 'jaecoo', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'J5', 'j5')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('Premium', 'premium', 1500, 'automatic', 'petrol', 'SUV', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'jaecoo') and slug = 'j5')
   and v.slug not in ('premium')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Jaecoo / J7, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Jaecoo', 'jaecoo', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'J7', 'j7')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('SHS', 'shs', 1600, 'automatic', 'hybrid', 'SUV', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'jaecoo') and slug = 'j7')
   and v.slug not in ('shs')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Chery / Tiggo 8 Pro, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Chery', 'chery', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Tiggo 8 Pro', 'tiggo-8-pro')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('1.6 DEX Plus', '1-6-dex-plus', 1600, 'automatic', 'petrol', 'SUV', 7)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'chery') and slug = 'tiggo-8-pro')
   and v.slug not in ('1-6-dex-plus')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Chery / Tiggo 4 Pro, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Chery', 'chery', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Tiggo 4 Pro', 'tiggo-4-pro')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('Comfort', 'comfort', 1500, 'automatic', 'petrol', 'Crossover', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'chery') and slug = 'tiggo-4-pro')
   and v.slug not in ('comfort')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- BYD / Atto 3, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('BYD', 'byd', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Atto 3', 'atto-3')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('Standard', 'standard', null, 'automatic', 'electric', 'SUV', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'byd') and slug = 'atto-3')
   and v.slug not in ('standard')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- BYD / Sealion 6, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('BYD', 'byd', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Sealion 6', 'sealion-6')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('DM-i', 'dm-i', 1500, 'automatic', 'hybrid', 'SUV', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'byd') and slug = 'sealion-6')
   and v.slug not in ('dm-i')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Mercedes Benz / C Class, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Mercedes Benz', 'mercedes-benz', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'C Class', 'c-class')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('C180', 'c180', 1600, 'automatic', 'petrol', 'Sedan', 5),
    ('C200', 'c200', 2000, 'automatic', 'petrol', 'Sedan', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'mercedes-benz') and slug = 'c-class')
   and v.slug not in ('c180', 'c200')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Mercedes Benz / E Class, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Mercedes Benz', 'mercedes-benz', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'E Class', 'e-class')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('E200', 'e200', 2000, 'automatic', 'petrol', 'Sedan', 5),
    ('E250', 'e250', 2000, 'automatic', 'petrol', 'Sedan', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'mercedes-benz') and slug = 'e-class')
   and v.slug not in ('e200', 'e250')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Mercedes Benz / S Class, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Mercedes Benz', 'mercedes-benz', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'S Class', 's-class')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('S500', 's500', 4700, 'automatic', 'petrol', 'Sedan', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'mercedes-benz') and slug = 's-class')
   and v.slug not in ('s500')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Mercedes Benz / G Class, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Mercedes Benz', 'mercedes-benz', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'G Class', 'g-class')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('G63 AMG', 'g63-amg', 4000, 'automatic', 'petrol', 'SUV', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'mercedes-benz') and slug = 'g-class')
   and v.slug not in ('g63-amg')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- BMW / 3 Series, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('BMW', 'bmw', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), '3 Series', '3-series')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('318i', '318i', 1600, 'automatic', 'petrol', 'Sedan', 5),
    ('320i', '320i', 2000, 'automatic', 'petrol', 'Sedan', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'bmw') and slug = '3-series')
   and v.slug not in ('318i', '320i')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- BMW / 5 Series, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('BMW', 'bmw', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), '5 Series', '5-series')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('520i', '520i', 2000, 'automatic', 'petrol', 'Sedan', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'bmw') and slug = '5-series')
   and v.slug not in ('520i')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- BMW / X5, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('BMW', 'bmw', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'X5', 'x5')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('xDrive40i', 'xdrive40i', 3000, 'automatic', 'petrol', 'SUV', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'bmw') and slug = 'x5')
   and v.slug not in ('xdrive40i')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Audi / A4, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Audi', 'audi', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'A4', 'a4')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('1.4 TFSI', '1-4-tfsi', 1400, 'automatic', 'petrol', 'Sedan', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'audi') and slug = 'a4')
   and v.slug not in ('1-4-tfsi')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Audi / Q5, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Audi', 'audi', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Q5', 'q5')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('45 TFSI', '45-tfsi', 2000, 'automatic', 'petrol', 'SUV', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'audi') and slug = 'q5')
   and v.slug not in ('45-tfsi')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Lexus / LX, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Lexus', 'lexus', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'LX', 'lx')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('LX570', 'lx570', 5700, 'automatic', 'petrol', 'SUV', 8)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'lexus') and slug = 'lx')
   and v.slug not in ('lx570')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Lexus / RX, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Lexus', 'lexus', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'RX', 'rx')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('RX350', 'rx350', 3500, 'automatic', 'petrol', 'SUV', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'lexus') and slug = 'rx')
   and v.slug not in ('rx350')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Mitsubishi / Pajero, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Mitsubishi', 'mitsubishi', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Pajero', 'pajero')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('GLS', 'gls', 3000, 'automatic', 'petrol', 'SUV', 7)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'mitsubishi') and slug = 'pajero')
   and v.slug not in ('gls')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Mitsubishi / L200, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Mitsubishi', 'mitsubishi', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'L200', 'l200')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('Double Cab', 'double-cab', 2400, 'manual', 'diesel', 'Double Cabin', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'mitsubishi') and slug = 'l200')
   and v.slug not in ('double-cab')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Isuzu / D-Max, 2 variants
with mk as (
  insert into makes (name, slug, vertical)
  values ('Isuzu', 'isuzu', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'D-Max', 'd-max')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('Single Cab', 'single-cab', 2500, 'manual', 'diesel', 'Pick Up', 2),
    ('Double Cab', 'double-cab', 2500, 'manual', 'diesel', 'Double Cabin', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'isuzu') and slug = 'd-max')
   and v.slug not in ('single-cab', 'double-cab')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Mazda / CX-5, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Mazda', 'mazda', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'CX-5', 'cx-5')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('2.0', '2-0', 2000, 'automatic', 'petrol', 'SUV', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'mazda') and slug = 'cx-5')
   and v.slug not in ('2-0')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Mazda / MX-5, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Mazda', 'mazda', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'MX-5', 'mx-5')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('Roadster', 'roadster', 1500, 'manual', 'petrol', 'Convertible', 2)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'mazda') and slug = 'mx-5')
   and v.slug not in ('roadster')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Land Rover / Range Rover, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Land Rover', 'land-rover', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Range Rover', 'range-rover')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('Vogue', 'vogue', 3000, 'automatic', 'petrol', 'SUV', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'land-rover') and slug = 'range-rover')
   and v.slug not in ('vogue')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Land Rover / Defender, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Land Rover', 'land-rover', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Defender', 'defender')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('110', '110', 2000, 'automatic', 'petrol', 'SUV', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'land-rover') and slug = 'defender')
   and v.slug not in ('110')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Volkswagen / Golf, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Volkswagen', 'volkswagen', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Golf', 'golf')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('1.4 TSI', '1-4-tsi', 1400, 'automatic', 'petrol', 'Hatchback', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'volkswagen') and slug = 'golf')
   and v.slug not in ('1-4-tsi')
   and not exists (select 1 from listings l where l.variant_id = v.id);
-- Volkswagen / Tiguan, 1 variant
with mk as (
  insert into makes (name, slug, vertical)
  values ('Volkswagen', 'volkswagen', 'car')
  on conflict (slug) do update set name = excluded.name
  returning id
), md as (
  insert into models (make_id, name, slug)
  values ((select id from mk), 'Tiguan', 'tiguan')
  on conflict (make_id, slug) do update set name = excluded.name
  returning id
)
insert into variants (model_id, name, slug, engine_cc, transmission, fuel, body_type, seats)
select (select id from md), v.name, v.slug,
       -- A VALUES list types every column from its contents, and it guesses wrong here in two ways.
       -- The enum columns come out as text. And engine_cc comes out as text whenever a model's whole
       -- variant list is null for it, which happens on the electric cars. Both are cast explicitly.
       v.engine_cc::int,
       v.transmission::transmission_kind,
       v.fuel::fuel_kind,
       v.body_type,
       v.seats::smallint
from (values
    ('2.0 TSI', '2-0-tsi', 2000, 'automatic', 'petrol', 'SUV', 5)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;

-- Prune variants this model no longer has.
--
-- The upsert above updates a variant whose slug already exists and inserts one whose slug does not,
-- but it can never remove one. So renaming a variant leaves the old row in the database for ever,
-- which is how the Alto came to carry a VXL that the manufacturer has not sold for years alongside
-- the VXL-AGS that replaced it. Two spellings of one trim is worse than a missing one, because a
-- buyer searching for the real name finds nothing and a filter offers a car that cannot be bought.
--
-- The guard is not decoration. listings.variant_id has no delete rule, so removing a variant that a
-- listing points at would fail the whole transaction, and removing one that a listing *should* point
-- at would silently detach it. A variant that survives this delete is therefore left in place on
-- purpose, and it is a data question for a human rather than something this file can settle. Find
-- survivors afterwards with:
--
--   select m.name, v.name, count(l.id)
--     from variants v join models m on m.id = v.model_id
--     left join listings l on l.variant_id = v.id
--    group by m.name, v.name
--   having count(l.id) > 0
--    order by m.name;
--
-- and compare that list against data/catalogue.json by eye. An empty overlap is the expected state.
delete from variants v
 where v.model_id = (select id from models where make_id = (select id from makes where slug = 'volkswagen') and slug = 'tiguan')
   and v.slug not in ('2-0-tsi')
   and not exists (select 1 from listings l where l.variant_id = v.id);

commit;
