-- L'Atelier des Écoliers — schéma Supabase
-- À exécuter UNE FOIS dans le SQL Editor du projet Supabase.

-- ============================================================================
-- TABLES
-- ============================================================================

create table if not exists public.slots (
  id bigserial primary key,
  format text not null check (format in ('individuel', 'collectif', 'stage')),
  starts_at timestamptz not null,
  duration_minutes int not null default 60,
  capacity int not null default 1 check (capacity >= 1),
  title text,
  notes text,
  created_at timestamptz default now()
);
create index if not exists slots_starts_at_idx on public.slots(starts_at);
create index if not exists slots_format_idx on public.slots(format);

create table if not exists public.bookings (
  id bigserial primary key,
  slot_id bigint not null references public.slots(id) on delete cascade,
  parent_name text not null,
  parent_email text not null,
  parent_phone text,
  child_name text,
  child_level text,
  notes text,
  created_at timestamptz default now()
);
create index if not exists bookings_slot_id_idx on public.bookings(slot_id);

-- ============================================================================
-- VUE : créneaux avec compteur de réservations
-- ============================================================================

create or replace view public.slots_with_count as
select
  s.*,
  coalesce(b.cnt, 0) as booked,
  greatest(s.capacity - coalesce(b.cnt, 0), 0) as seats_left
from public.slots s
left join (
  select slot_id, count(*)::int as cnt
  from public.bookings
  group by slot_id
) b on b.slot_id = s.id;

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================

alter table public.slots enable row level security;
alter table public.bookings enable row level security;

-- SLOTS
-- Public : lecture des créneaux futurs uniquement
drop policy if exists "public reads upcoming slots" on public.slots;
create policy "public reads upcoming slots" on public.slots
  for select using (starts_at > now());

-- Admin (authentifié) : tous droits
drop policy if exists "admin manages slots" on public.slots;
create policy "admin manages slots" on public.slots
  for all using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

-- BOOKINGS
-- Public : insertion uniquement, sur des slots futurs non complets
drop policy if exists "public creates booking" on public.bookings;
create policy "public creates booking" on public.bookings
  for insert with check (
    exists (
      select 1 from public.slots_with_count sc
      where sc.id = slot_id
        and sc.starts_at > now()
        and sc.seats_left > 0
    )
  );

-- Admin (authentifié) : tous droits sur les réservations
drop policy if exists "admin reads bookings" on public.bookings;
create policy "admin reads bookings" on public.bookings
  for select using (auth.role() = 'authenticated');

drop policy if exists "admin updates bookings" on public.bookings;
create policy "admin updates bookings" on public.bookings
  for update using (auth.role() = 'authenticated');

drop policy if exists "admin deletes bookings" on public.bookings;
create policy "admin deletes bookings" on public.bookings
  for delete using (auth.role() = 'authenticated');

-- ============================================================================
-- NOTES
-- ============================================================================
-- 1) Après exécution, créer un utilisateur admin via Authentication > Users > Add user
--    avec l'email de Sophie (sophie@latelierdesecoliers.com). Activer "Auto Confirm".
-- 2) Dans Authentication > URL Configuration, ajouter à "Redirect URLs":
--    https://reeskgroup.github.io/atelier-des-ecoliers/admin.html
-- 3) Dans Authentication > Providers > Email, activer "Confirm email" si souhaité.
