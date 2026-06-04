-- L'Atelier des Écoliers — table des demandes de rendez-vous
-- À exécuter dans le SQL Editor du projet Supabase APRÈS schema.sql.

create table if not exists public.appointment_requests (
  id bigserial primary key,
  parent_name text not null,
  parent_email text not null,
  parent_phone text,
  child_name text,
  child_level text,
  format_preference text,         -- 'individuel' | 'collectif' | 'stage' | null
  time_preference text,           -- créneaux libres saisis par le parent
  notes text,
  status text not null default 'new'  -- 'new' | 'contacted' | 'archived'
    check (status in ('new', 'contacted', 'archived')),
  created_at timestamptz default now()
);

create index if not exists appointment_requests_created_at_idx
  on public.appointment_requests(created_at desc);
create index if not exists appointment_requests_status_idx
  on public.appointment_requests(status);

alter table public.appointment_requests enable row level security;

-- Public : peut créer une demande (un visiteur du site)
drop policy if exists "public creates request" on public.appointment_requests;
create policy "public creates request" on public.appointment_requests
  for insert with check (true);

-- Admin (authentifié) : lecture / mise à jour / suppression
drop policy if exists "admin reads requests" on public.appointment_requests;
create policy "admin reads requests" on public.appointment_requests
  for select using (auth.role() = 'authenticated');

drop policy if exists "admin updates requests" on public.appointment_requests;
create policy "admin updates requests" on public.appointment_requests
  for update using (auth.role() = 'authenticated');

drop policy if exists "admin deletes requests" on public.appointment_requests;
create policy "admin deletes requests" on public.appointment_requests
  for delete using (auth.role() = 'authenticated');
