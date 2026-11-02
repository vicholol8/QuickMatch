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

-- Un anuncio puede invitar a uno de los partidos de su autor
alter table public.anuncios
  add column if not exists partido_id bigint references public.partidos (id) on delete set null;
create index if not exists anuncios_partido_id_idx on public.anuncios (partido_id);

alter table public.anuncios enable row level security;

drop policy if exists "anuncios_select_todos" on public.anuncios;
create policy "anuncios_select_todos" on public.anuncios
  for select to authenticated
  using (true);

drop policy if exists "anuncios_insert_propios" on public.anuncios;
create policy "anuncios_insert_propios" on public.anuncios
  for insert to authenticated
  with check (
    auth.uid() = user_id
    and (partido_id is null or exists (
      select 1 from public.partidos p
      where p.id = partido_id and p.user_id = auth.uid()
    ))
  );

drop policy if exists "anuncios_update_propios" on public.anuncios;
create policy "anuncios_update_propios" on public.anuncios
  for update to authenticated
  using (auth.uid() = user_id)
  with check (
    auth.uid() = user_id
    and (partido_id is null or exists (
      select 1 from public.partidos p
      where p.id = partido_id and p.user_id = auth.uid()
    ))
  );

drop policy if exists "anuncios_delete_propios" on public.anuncios;
create policy "anuncios_delete_propios" on public.anuncios
  for delete to authenticated
  using (auth.uid() = user_id);

-- =========================================================
-- Partidos publicados en el feed: los ve cualquiera con sesión,
-- para que puedan sumarse. Los demás siguen siendo privados.
-- Se usan funciones security definer para que las políticas de
-- partidos y anuncios no se llamen entre sí en un ciclo.
-- =========================================================
create or replace function public.partido_publicado(pid bigint)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.anuncios where partido_id = pid);
$$;

drop policy if exists "partidos_select_publicados" on public.partidos;
create policy "partidos_select_publicados" on public.partidos
  for select to authenticated
  using (public.partido_publicado(id));

-- =========================================================
-- Asistentes: quienes se suman a un partido publicado.
-- No se puede pasar de los cupos ni sumarse al partido propio.
-- =========================================================
create table if not exists public.asistentes (
  partido_id  bigint not null references public.partidos (id) on delete cascade,
  user_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  nombre      text not null check (char_length(nombre) between 1 and 60),
  created_at  timestamptz not null default now(),
  primary key (partido_id, user_id)
);

create index if not exists asistentes_user_id_idx on public.asistentes (user_id);

alter table public.asistentes enable row level security;

create or replace function public.quedan_cupos(pid bigint)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    (select p.cupos > (select count(*) from public.asistentes a where a.partido_id = p.id)
     from public.partidos p where p.id = pid),
    false
  );
$$;

revoke execute on function public.partido_publicado(bigint) from anon, public;
revoke execute on function public.quedan_cupos(bigint) from anon, public;
grant execute on function public.partido_publicado(bigint) to authenticated;
grant execute on function public.quedan_cupos(bigint) to authenticated;

drop policy if exists "asistentes_select_todos" on public.asistentes;
create policy "asistentes_select_todos" on public.asistentes
  for select to authenticated
  using (true);

drop policy if exists "asistentes_insert_propios" on public.asistentes;
create policy "asistentes_insert_propios" on public.asistentes
  for insert to authenticated
  with check (
    auth.uid() = user_id
    and public.partido_publicado(partido_id)
    and public.quedan_cupos(partido_id)
    and not exists (
      select 1 from public.partidos p
      where p.id = partido_id and p.user_id = auth.uid()
    )
  );

drop policy if exists "asistentes_delete_propios" on public.asistentes;
create policy "asistentes_delete_propios" on public.asistentes
  for delete to authenticated
  using (auth.uid() = user_id);

-- =========================================================
-- Comentarios de los anuncios: los ven todos los usuarios con
-- sesión y cada uno puede borrar solo los suyos.
-- =========================================================
create table if not exists public.comentarios (
  id          bigint generated always as identity primary key,
  anuncio_id  bigint not null references public.anuncios (id) on delete cascade,
  user_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  autor       text not null check (char_length(autor) between 1 and 60),
  texto       text not null check (char_length(texto) between 1 and 300),
  created_at  timestamptz not null default now()
);

create index if not exists comentarios_anuncio_id_idx on public.comentarios (anuncio_id);
create index if not exists comentarios_user_id_idx on public.comentarios (user_id);

alter table public.comentarios enable row level security;

drop policy if exists "comentarios_select_todos" on public.comentarios;
create policy "comentarios_select_todos" on public.comentarios
  for select to authenticated
  using (true);

drop policy if exists "comentarios_insert_propios" on public.comentarios;
create policy "comentarios_insert_propios" on public.comentarios
  for insert to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "comentarios_delete_propios" on public.comentarios;
create policy "comentarios_delete_propios" on public.comentarios
  for delete to authenticated
  using (auth.uid() = user_id);

-- =========================================================
-- Quien se sumó a un partido lo sigue viendo en su calendario,
-- aunque después se borre el anuncio que lo publicaba.
-- =========================================================
create or replace function public.estoy_sumado(pid bigint)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.asistentes
    where partido_id = pid and user_id = auth.uid()
  );
$$;

drop policy if exists "partidos_select_sumados" on public.partidos;
create policy "partidos_select_sumados" on public.partidos
  for select to authenticated
  using (public.estoy_sumado(id));

-- =========================================================
-- Chat grupal de cada partido: lo leen y escriben solo el
-- organizador y quienes se sumaron. Los mensajes llegan en vivo.
-- =========================================================
create or replace function public.soy_del_partido(pid bigint)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.partidos where id = pid and user_id = auth.uid()
  ) or exists (
    select 1 from public.asistentes where partido_id = pid and user_id = auth.uid()
  );
$$;

revoke execute on function public.estoy_sumado(bigint) from anon, public;
revoke execute on function public.soy_del_partido(bigint) from anon, public;
grant execute on function public.estoy_sumado(bigint) to authenticated;
grant execute on function public.soy_del_partido(bigint) to authenticated;

create table if not exists public.mensajes (
  id          bigint generated always as identity primary key,
  partido_id  bigint not null references public.partidos (id) on delete cascade,
  user_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  autor       text not null check (char_length(autor) between 1 and 60),
  texto       text not null check (char_length(texto) between 1 and 500),
  created_at  timestamptz not null default now()
);

create index if not exists mensajes_partido_id_idx on public.mensajes (partido_id, created_at);
create index if not exists mensajes_user_id_idx on public.mensajes (user_id);

alter table public.mensajes enable row level security;

drop policy if exists "mensajes_select_miembros" on public.mensajes;
create policy "mensajes_select_miembros" on public.mensajes
  for select to authenticated
  using (public.soy_del_partido(partido_id));

drop policy if exists "mensajes_insert_miembros" on public.mensajes;
create policy "mensajes_insert_miembros" on public.mensajes
  for insert to authenticated
  with check (auth.uid() = user_id and public.soy_del_partido(partido_id));

-- Realtime: avisa a la app cuando llega un mensaje nuevo
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'mensajes'
  ) then
    alter publication supabase_realtime add table public.mensajes;
  end if;
end $$;
