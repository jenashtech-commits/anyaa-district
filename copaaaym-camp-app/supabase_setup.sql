-- ============================================================
--  The COP AAAYM Camp App — Catalyst 2026
--  Run this ONCE in your Supabase project:
--  Dashboard  ->  SQL Editor  ->  New query  ->  paste  ->  Run
--
--  ALREADY ran an earlier version? Just run these three lines once
--  to add the new columns, then you're done:
--    alter table public.registrations add column if not exists area text;
--    alter table public.registrations add column if not exists checked_in boolean not null default false;
--    alter table public.registrations add column if not exists checked_in_at timestamptz;
--  (and make sure the "admin can update" policy in step 4b exists)
-- ============================================================

create extension if not exists "pgcrypto";

-- 1. The registrations table
create table if not exists public.registrations (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  age           int,
  gender        text,
  email         text,
  phone         text,
  area          text,
  district      text,
  assembly      text,
  allergy       text,
  emergency     text,
  registered_by text,
  checked_in    boolean not null default false,
  checked_in_at timestamptz,
  created_at    timestamptz not null default now()
);

-- 2. Lock the table down (Row Level Security)
alter table public.registrations enable row level security;

-- 3. Anyone (even not logged in) may submit a registration
drop policy if exists "anyone can register" on public.registrations;
create policy "anyone can register"
  on public.registrations
  for insert
  to anon, authenticated
  with check (true);

-- 4a. ONLY the admin email may read the personal data
drop policy if exists "only admin can read" on public.registrations;
create policy "only admin can read"
  on public.registrations
  for select
  to authenticated
  using ( (auth.jwt() ->> 'email') = 'thecopaaaym@gmail.com' );

-- 4b. ONLY the admin email may update (used for marking check-in at the gate)
drop policy if exists "only admin can update" on public.registrations;
create policy "only admin can update"
  on public.registrations
  for update
  to authenticated
  using ( (auth.jwt() ->> 'email') = 'thecopaaaym@gmail.com' )
  with check ( (auth.jwt() ->> 'email') = 'thecopaaaym@gmail.com' );

-- 5. A public counter that returns ONLY the number (no personal data)
create or replace function public.registration_count()
returns integer
language sql
security definer
set search_path = public
as $$ select count(*)::int from public.registrations $$;

grant execute on function public.registration_count() to anon, authenticated;

-- 6. Turn on realtime so the admin console updates instantly
alter publication supabase_realtime add table public.registrations;
