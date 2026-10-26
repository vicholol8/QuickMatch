-- Esquema de QuickMatch
-- Se pega completo en Supabase > SQL Editor y se ejecuta una vez.

-- =========================================================
-- Partidos: cada usuario guarda y administra los suyos.
-- Solo el dueño puede verlos, crearlos, editarlos y borrarlos.
-- =========================================================
create table if not exists public.partidos (
  id          bigint generated always as identity primary key,
  user_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  deporte     text not null,
  lugar       text not null,
  fecha       timestamptz not null,
  cupos       int  not null check (cupos between 1 and 50),
  notas       text,
  created_at  timestamptz not null default now()
);

alter table public.partidos enable row level security;

drop policy if exists "partidos_select_propios" on public.partidos;
create policy "partidos_select_propios" on public.partidos
  for select to authenticated
  using (auth.uid() = user_id);

drop policy if exists "partidos_insert_propios" on public.partidos;
create policy "partidos_insert_propios" on public.partidos
  for insert to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "partidos_update_propios" on public.partidos;
create policy "partidos_update_propios" on public.partidos
  for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "partidos_delete_propios" on public.partidos;
create policy "partidos_delete_propios" on public.partidos
  for delete to authenticated
  using (auth.uid() = user_id);

-- =========================================================
-- Anuncios: el feed lo ven todos los usuarios con sesión,
-- pero cada uno solo puede editar o borrar lo que publicó.
-- =========================================================
create table if not exists public.anuncios (
  id          bigint generated always as identity primary key,
  user_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  autor       text not null,
  titulo      text not null,
  descripcion text not null,
  created_at  timestamptz not null default now()
);

alter table public.anuncios enable row level security;

drop policy if exists "anuncios_select_todos" on public.anuncios;
create policy "anuncios_select_todos" on public.anuncios
  for select to authenticated
  using (true);

drop policy if exists "anuncios_insert_propios" on public.anuncios;
create policy "anuncios_insert_propios" on public.anuncios
  for insert to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "anuncios_update_propios" on public.anuncios;
create policy "anuncios_update_propios" on public.anuncios
  for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "anuncios_delete_propios" on public.anuncios;
create policy "anuncios_delete_propios" on public.anuncios
  for delete to authenticated
  using (auth.uid() = user_id);
