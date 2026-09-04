-- ════════════════════════════════════════════════════════════════
-- Control de Cargas — esquema, seguridad (RLS) y funciones para
-- el acceso de los atletas (Modo Jugador) sin necesidad de login.
--
-- Este script se puede correr las veces que haga falta sin romper
-- nada (borra y recrea policies/funciones antes de crearlas).
-- ════════════════════════════════════════════════════════════════

create table if not exists public.athletes (
  id text primary key,
  coach_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  first_name text not null,
  last_name text not null,
  bodyweight numeric,
  sport text,
  next_match date,
  pin text,
  notes text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.exercises (
  id text primary key,
  coach_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null,
  bodyweight_relative boolean not null default false,
  increment numeric not null default 2.5,
  created_at timestamptz not null default now()
);

create table if not exists public.records (
  id text primary key,
  coach_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  athlete_id text not null references public.athletes(id) on delete cascade,
  exercise_id text not null,
  date date not null,
  load numeric not null,
  reps integer not null,
  note text,
  source text not null default 'test',
  current boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.templates (
  id text primary key,
  coach_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  label text not null,
  phase text,
  notes text,
  items jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.weeks (
  id text primary key,
  coach_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  athlete_id text not null references public.athletes(id) on delete cascade,
  label text not null,
  phase text,
  notes text,
  start_date date not null,
  template_id text references public.templates(id) on delete set null,
  items jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.coach_settings (
  coach_id uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  coach_name text,
  org text,
  formula text not null default 'epley',
  coach_pin text
);

create index if not exists idx_records_athlete
  on public.records(athlete_id);
create index if not exists idx_records_athlete_exercise
  on public.records(athlete_id, exercise_id);
create index if not exists idx_weeks_athlete
  on public.weeks(athlete_id);

-- ── Seguridad: cada coach solo ve/edita sus propios datos ──────────
alter table public.athletes enable row level security;
alter table public.exercises enable row level security;
alter table public.records enable row level security;
alter table public.templates enable row level security;
alter table public.weeks enable row level security;
alter table public.coach_settings enable row level security;

drop policy if exists "coach_athletes" on public.athletes;
create policy "coach_athletes" on public.athletes
  for all
  using (coach_id = auth.uid())
  with check (coach_id = auth.uid());

drop policy if exists "coach_exercises" on public.exercises;
create policy "coach_exercises" on public.exercises
  for all
  using (coach_id = auth.uid())
  with check (coach_id = auth.uid());

drop policy if exists "coach_records" on public.records;
create policy "coach_records" on public.records
  for all
  using (coach_id = auth.uid())
  with check (coach_id = auth.uid());

drop policy if exists "coach_templates" on public.templates;
create policy "coach_templates" on public.templates
  for all
  using (coach_id = auth.uid())
  with check (coach_id = auth.uid());

drop policy if exists "coach_weeks" on public.weeks;
create policy "coach_weeks" on public.weeks
  for all
  using (coach_id = auth.uid())
  with check (coach_id = auth.uid());

drop policy if exists "coach_settings_rls" on public.coach_settings;
create policy "coach_settings_rls" on public.coach_settings
  for all
  using (coach_id = auth.uid())
  with check (coach_id = auth.uid());

-- ── Funciones para Modo Jugador (sin login, solo con PIN) ──────────
-- Corren con privilegios elevados (bypassean RLS) pero verifican el
-- PIN del atleta adentro, y solo devuelven/tocan los datos de ESE
-- atleta puntual, nunca los de otros.

create or replace function public.player_list_athletes()
returns jsonb
language sql
security definer
set search_path = public
as $$
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', id,
        'firstName', first_name,
        'lastName', last_name,
        'sport', sport,
        'hasPin', (pin is not null and pin <> '')
      )
      order by first_name
    ),
    '[]'::jsonb
  )
  from public.athletes
  where active = true;
$$;

create or replace function public.player_get_state(p_athlete_id text, p_pin text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pin text;
  v_coach uuid;
  v_athlete jsonb;
  v_exercises jsonb;
  v_weeks jsonb;
  v_records jsonb;
  v_formula text;
begin
  select pin, coach_id into v_pin, v_coach
  from public.athletes
  where id = p_athlete_id and active = true;

  if v_coach is null then
    raise exception 'not_found';
  end if;

  if v_pin is not null and v_pin <> '' and v_pin is distinct from p_pin then
    raise exception 'invalid_pin';
  end if;

  select jsonb_build_object(
    'id', id,
    'firstName', first_name,
    'lastName', last_name,
    'bodyweight', bodyweight,
    'sport', sport,
    'nextMatch', next_match,
    'notes', notes,
    'active', active
  )
  into v_athlete
  from public.athletes
  where id = p_athlete_id;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', id,
        'name', name,
        'bodyweightRelative', bodyweight_relative,
        'increment', increment
      )
    ),
    '[]'::jsonb
  )
  into v_exercises
  from public.exercises
  where coach_id = v_coach;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', id,
        'athleteId', athlete_id,
        'label', label,
        'phase', phase,
        'notes', notes,
        'startDate', start_date,
        'templateId', template_id,
        'items', items
      )
      order by start_date desc
    ),
    '[]'::jsonb
  )
  into v_weeks
  from public.weeks
  where athlete_id = p_athlete_id;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', id,
        'athleteId', athlete_id,
        'exerciseId', exercise_id,
        'date', date,
        'load', load,
        'reps', reps,
        'note', note,
        'source', source,
        'current', current
      )
    ),
    '[]'::jsonb
  )
  into v_records
  from public.records
  where athlete_id = p_athlete_id;

  select formula into v_formula
  from public.coach_settings
  where coach_id = v_coach;

  return jsonb_build_object(
    'athlete', v_athlete,
    'exercises', v_exercises,
    'weeks', v_weeks,
    'records', v_records,
    'formula', coalesce(v_formula, 'epley')
  );
end;
$$;

create or replace function public.player_add_record(
  p_athlete_id text,
  p_pin text,
  p_id text,
  p_exercise_id text,
  p_date date,
  p_load numeric,
  p_reps int,
  p_note text,
  p_source text,
  p_set_current boolean
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pin text;
  v_coach uuid;
begin
  select pin, coach_id into v_pin, v_coach
  from public.athletes
  where id = p_athlete_id and active = true;

  if v_coach is null then
    raise exception 'not_found';
  end if;

  if v_pin is not null and v_pin <> '' and v_pin is distinct from p_pin then
    raise exception 'invalid_pin';
  end if;

  if p_set_current then
    update public.records
    set current = false
    where athlete_id = p_athlete_id and exercise_id = p_exercise_id;
  end if;

  insert into public.records(
    id, coach_id, athlete_id, exercise_id, date, load, reps, note, source, current
  )
  values (
    p_id, v_coach, p_athlete_id, p_exercise_id, p_date, p_load, p_reps, p_note, p_source, p_set_current
  );
end;
$$;

create or replace function public.player_update_week_item(
  p_athlete_id text,
  p_pin text,
  p_week_id text,
  p_item_id text,
  p_patch jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pin text;
  v_items jsonb;
  v_new_items jsonb := '[]'::jsonb;
  v_item jsonb;
  v_week_athlete text;
begin
  select pin into v_pin
  from public.athletes
  where id = p_athlete_id and active = true;

  if v_pin is not null and v_pin <> '' and v_pin is distinct from p_pin then
    raise exception 'invalid_pin';
  end if;

  select athlete_id, items into v_week_athlete, v_items
  from public.weeks
  where id = p_week_id;

  if v_week_athlete is null or v_week_athlete <> p_athlete_id then
    raise exception 'not_found';
  end if;

  for v_item in select * from jsonb_array_elements(coalesce(v_items, '[]'::jsonb)) loop
    if v_item->>'id' = p_item_id then
      v_item := v_item || p_patch;
    end if;
    v_new_items := v_new_items || jsonb_build_array(v_item);
  end loop;

  update public.weeks set items = v_new_items where id = p_week_id;

  return v_new_items;
end;
$$;

-- ── Permisos: los atletas usan estas funciones sin haber iniciado
--    sesión, así que el rol "anon" necesita poder ejecutarlas.
grant usage
  on schema public
  to anon, authenticated;

grant execute
  on function public.player_list_athletes()
  to anon, authenticated;

grant execute
  on function public.player_get_state(text, text)
  to anon, authenticated;

grant execute
  on function public.player_add_record(
    text, text, text, text, date, numeric, int, text, text, boolean
  )
  to anon, authenticated;

grant execute
  on function public.player_update_week_item(text, text, text, text, jsonb)
  to anon, authenticated;
