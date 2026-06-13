-- ============================================================
-- Migración: reglas personales de disciplina + diario de disciplina
-- Ejecuta este bloque UNA vez en Supabase → SQL Editor → New query → Run.
-- Es idempotente: puedes ejecutarlo varias veces sin romper nada.
-- ============================================================

-- 1) Reglas personales por cuenta (anti-overtrading + riesgo diario propio)
alter table public.accounts add column if not exists max_trades_day integer;
alter table public.accounts add column if not exists risk_per_day   numeric;

-- 2) Diario de disciplina (un registro por día)
create table if not exists public.discipline_log (
  user_id       uuid not null default auth.uid() references auth.users(id) on delete cascade,
  id            text not null,                -- "disc_YYYY-MM-DD"
  date          date not null,
  account_id    text,
  account_alias text,
  trades        integer,
  pnl           numeric,
  followed      boolean,
  note          text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  primary key (user_id, id)
);

-- updated_at automático (reutiliza la función creada en el esquema principal)
drop trigger if exists trg_discipline_updated on public.discipline_log;
create trigger trg_discipline_updated
  before update on public.discipline_log
  for each row execute function public.set_updated_at();

-- Seguridad por fila: cada usuario solo ve/gestiona sus registros
alter table public.discipline_log enable row level security;

drop policy if exists "discipline_select_own" on public.discipline_log;
create policy "discipline_select_own" on public.discipline_log
  for select using (auth.uid() = user_id);

drop policy if exists "discipline_insert_own" on public.discipline_log;
create policy "discipline_insert_own" on public.discipline_log
  for insert with check (auth.uid() = user_id);

drop policy if exists "discipline_update_own" on public.discipline_log;
create policy "discipline_update_own" on public.discipline_log
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "discipline_delete_own" on public.discipline_log;
create policy "discipline_delete_own" on public.discipline_log
  for delete using (auth.uid() = user_id);

-- 3) Ajustes del usuario (meta mensual de P&L, etc.) — 1 fila por usuario
create table if not exists public.app_settings (
  user_id    uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
drop trigger if exists trg_settings_updated on public.app_settings;
create trigger trg_settings_updated
  before update on public.app_settings
  for each row execute function public.set_updated_at();
alter table public.app_settings enable row level security;
drop policy if exists "settings_select_own" on public.app_settings;
create policy "settings_select_own" on public.app_settings
  for select using (auth.uid() = user_id);
drop policy if exists "settings_insert_own" on public.app_settings;
create policy "settings_insert_own" on public.app_settings
  for insert with check (auth.uid() = user_id);
drop policy if exists "settings_update_own" on public.app_settings;
create policy "settings_update_own" on public.app_settings
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- LISTO. Tras ejecutar esto, recarga la web y verás el panel "Disciplina"
-- y los campos "Mis reglas" al editar cada cuenta.
