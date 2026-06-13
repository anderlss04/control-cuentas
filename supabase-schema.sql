-- ========================================================================
-- Control de Cuentas — esquema de base de datos (Supabase / PostgreSQL)
-- Ejecuta TODO este bloque una vez en:  Supabase → SQL Editor → New query → Run
-- ========================================================================

create extension if not exists pgcrypto;

-- Tabla principal: una fila por cuenta, ligada al usuario que la creó.
create table if not exists public.accounts (
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  id          text not null,                 -- id generado por la app
  alias       text not null,
  firm        text,
  program     text,
  type        text,
  status      text,
  size        numeric,
  platform    text,
  start_bal   numeric,
  cur_bal     numeric,
  target      numeric,
  cost        numeric,
  maxdd       text,
  dll         text,
  inact       integer,
  last_traded date,
  min_days    integer,
  cycle_start date,
  days_done   integer default 0,
  payout      text,
  login       text,
  notes       text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  primary key (user_id, id)
);

-- Mantener updated_at al día automáticamente.
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_accounts_updated on public.accounts;
create trigger trg_accounts_updated
  before update on public.accounts
  for each row execute function public.set_updated_at();

-- ------------------------------------------------------------------------
-- SEGURIDAD POR FILA (RLS): cada usuario SOLO puede ver y tocar sus cuentas.
-- Sin esto, cualquiera con la anon key podría leer datos ajenos.
-- ------------------------------------------------------------------------
alter table public.accounts enable row level security;

drop policy if exists "accounts_select_own" on public.accounts;
create policy "accounts_select_own" on public.accounts
  for select using (auth.uid() = user_id);

drop policy if exists "accounts_insert_own" on public.accounts;
create policy "accounts_insert_own" on public.accounts
  for insert with check (auth.uid() = user_id);

drop policy if exists "accounts_update_own" on public.accounts;
create policy "accounts_update_own" on public.accounts
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "accounts_delete_own" on public.accounts;
create policy "accounts_delete_own" on public.accounts
  for delete using (auth.uid() = user_id);

-- ========================================================================
-- LISTO. Después de ejecutar esto:
--  1) Authentication → Users → "Add user": pon tu email y contraseña,
--     marca "Auto Confirm User".  (Ese será tu único login.)
--  2) Authentication → Providers → Email: DESACTIVA "Allow new users to
--     sign up"  → así nadie más puede registrarse.
--  3) Authentication → URL Configuration → Site URL:
--     https://controldecuentas.netlify.app
-- ========================================================================
