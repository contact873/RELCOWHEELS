-- RELCO Wheels, vehicle catalogue
-- Source: data/catalogue.json
-- Generated: 2026-10-28T12:16:16.673Z
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
    ('VXL', 'vxl', 660, 'manual', 'petrol', 'Hatchback', 4),
    ('VXL AGS', 'vxl-ags', 660, 'automatic', 'petrol', 'Hatchback', 4)
) as v(name, slug, engine_cc, transmission, fuel, body_type, seats)
on conflict (model_id, slug) do update set
  name = excluded.name,
  engine_cc = excluded.engine_cc,
  transmission = excluded.transmission,
  fuel = excluded.fuel,
  body_type = excluded.body_type,
  seats = excluded.seats;
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

commit;
