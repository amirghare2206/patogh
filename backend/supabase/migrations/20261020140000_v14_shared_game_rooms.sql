-- Shared game rooms for the ten-person beta. This migration enables real room
-- creation/joining across devices; it does not provide board/rules engines.
create table if not exists public.game_rooms (
  id uuid primary key default gen_random_uuid(),
  game_type text not null check (game_type in ('chess', 'tic_tac_toe', 'snakes_ladders', 'backgammon')),
  room_code text not null unique check (room_code ~ '^[0-9]{6}$'),
  host_user_id uuid not null references auth.users(id) on delete cascade,
  is_private boolean not null default false,
  max_players integer not null default 2 check (max_players between 2 and 4),
  status text not null default 'open' check (status in ('open', 'full', 'closed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.game_room_players (
  room_id uuid not null references public.game_rooms(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  seat smallint not null check (seat between 1 and 4),
  joined_at timestamptz not null default now(),
  primary key (room_id, user_id),
  unique (room_id, seat)
);

create index if not exists game_rooms_public_list_idx
  on public.game_rooms(game_type, status, is_private, created_at desc);
create index if not exists game_room_players_user_idx
  on public.game_room_players(user_id, joined_at desc);

alter table public.game_rooms enable row level security;
alter table public.game_room_players enable row level security;
revoke all on table public.game_rooms from public, anon, authenticated;
revoke all on table public.game_room_players from public, anon, authenticated;

drop policy if exists game_rooms_select_visible on public.game_rooms;
create policy game_rooms_select_visible on public.game_rooms
for select to authenticated
using (
  (is_private = false and status in ('open', 'full'))
  or host_user_id = auth.uid()
  or exists (
    select 1 from public.game_room_players mine
    where mine.room_id = game_rooms.id and mine.user_id = auth.uid()
  )
);

drop policy if exists game_room_players_select_self on public.game_room_players;
create policy game_room_players_select_self on public.game_room_players
for select to authenticated
using (user_id = auth.uid());

grant select on public.game_rooms to authenticated;
grant select on public.game_room_players to authenticated;

create or replace function public.create_game_room_v14(
  p_game_type text,
  p_max_players integer default 2,
  p_is_private boolean default false
) returns jsonb
language plpgsql security definer
set search_path = pg_catalog, public
as $$
declare
  v_uid uuid := auth.uid();
  v_code text;
  v_room public.game_rooms%rowtype;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  if p_game_type not in ('chess', 'tic_tac_toe', 'snakes_ladders', 'backgammon') then
    raise exception 'unsupported game type';
  end if;
  if p_game_type = 'snakes_ladders' then
    if p_max_players < 2 or p_max_players > 4 then raise exception 'invalid player count'; end if;
  elsif p_max_players <> 2 then
    raise exception 'this game supports two players';
  end if;
  if not exists (select 1 from public.profiles p where p.id = v_uid and p.onboarding_completed = true) then
    raise exception 'complete profile first';
  end if;
  loop
    v_code := lpad((floor(random() * 1000000))::integer::text, 6, '0');
    exit when not exists (select 1 from public.game_rooms r where r.room_code = v_code);
  end loop;
  insert into public.game_rooms(game_type, room_code, host_user_id, is_private, max_players)
  values (p_game_type, v_code, v_uid, coalesce(p_is_private, false), p_max_players)
  returning * into v_room;
  insert into public.game_room_players(room_id, user_id, seat) values (v_room.id, v_uid, 1);
  return jsonb_build_object('id', v_room.id, 'game_type', v_room.game_type,
    'room_code', v_room.room_code, 'host_user_id', v_room.host_user_id,
    'is_private', v_room.is_private, 'max_players', v_room.max_players,
    'players', 1, 'status', v_room.status);
end;
$$;

create or replace function public.list_game_rooms_v14(p_game_type text)
returns setof jsonb
language sql stable security definer
set search_path = pg_catalog, public
as $$
  select jsonb_build_object(
    'id', r.id, 'game_type', r.game_type, 'room_code', r.room_code,
    'host_name', coalesce(p.name, 'کاربر پاتوق'), 'host_user_id', r.host_user_id,
    'is_private', r.is_private, 'max_players', r.max_players,
    'players', (select count(*)::integer from public.game_room_players gp where gp.room_id = r.id),
    'status', r.status, 'created_at', r.created_at
  )
  from public.game_rooms r
  join public.profiles p on p.id = r.host_user_id
  where r.game_type = p_game_type and r.status = 'open' and r.is_private = false
    and (select count(*) from public.game_room_players gp where gp.room_id = r.id) < r.max_players
  order by r.created_at desc
  limit 50;
$$;

create or replace function public.join_game_room_v14(p_room_code text)
returns jsonb
language plpgsql security definer
set search_path = pg_catalog, public
as $$
declare
  v_uid uuid := auth.uid();
  v_room public.game_rooms%rowtype;
  v_count integer;
  v_seat integer;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  select * into v_room from public.game_rooms where room_code = p_room_code for update;
  if not found then raise exception 'room not found'; end if;
  if v_room.status = 'closed' then raise exception 'room not found'; end if;
  if exists (select 1 from public.game_room_players gp where gp.room_id = v_room.id and gp.user_id = v_uid) then
    select count(*)::integer into v_count from public.game_room_players gp where gp.room_id = v_room.id;
    return jsonb_build_object('id', v_room.id, 'game_type', v_room.game_type, 'room_code', v_room.room_code,
      'host_user_id', v_room.host_user_id, 'is_private', v_room.is_private, 'max_players', v_room.max_players,
      'players', v_count, 'status', v_room.status);
  end if;
  select count(*)::integer into v_count from public.game_room_players gp where gp.room_id = v_room.id;
  if v_count >= v_room.max_players then raise exception 'room is full'; end if;
  select seats.seat_no into v_seat
  from generate_series(1, v_room.max_players) as seats(seat_no)
  where not exists (select 1 from public.game_room_players gp where gp.room_id = v_room.id and gp.seat = seats.seat_no)
  order by seats.seat_no limit 1;
  insert into public.game_room_players(room_id, user_id, seat) values (v_room.id, v_uid, v_seat);
  v_count := v_count + 1;
  update public.game_rooms set status = case when v_count >= max_players then 'full' else 'open' end,
    updated_at = now() where id = v_room.id returning * into v_room;
  return jsonb_build_object('id', v_room.id, 'game_type', v_room.game_type, 'room_code', v_room.room_code,
    'host_user_id', v_room.host_user_id, 'is_private', v_room.is_private, 'max_players', v_room.max_players,
    'players', v_count, 'status', v_room.status);
end;
$$;

create or replace function public.leave_game_room_v14(p_room_id uuid)
returns boolean
language plpgsql security definer
set search_path = pg_catalog, public
as $$
declare
  v_uid uuid := auth.uid();
  v_host uuid;
  v_count integer;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  select host_user_id into v_host from public.game_rooms where id = p_room_id for update;
  if v_host is null then return false; end if;
  delete from public.game_room_players where room_id = p_room_id and user_id = v_uid;
  if v_host = v_uid then
    update public.game_rooms set status = 'closed', updated_at = now() where id = p_room_id;
  else
    select count(*)::integer into v_count from public.game_room_players where room_id = p_room_id;
    update public.game_rooms set status = case when v_count < max_players then 'open' else 'full' end,
      updated_at = now() where id = p_room_id and status <> 'closed';
  end if;
  return true;
end;
$$;

revoke all on function public.create_game_room_v14(text, integer, boolean) from public, anon;
revoke all on function public.list_game_rooms_v14(text) from public, anon;
revoke all on function public.join_game_room_v14(text) from public, anon;
revoke all on function public.leave_game_room_v14(uuid) from public, anon;
grant execute on function public.create_game_room_v14(text, integer, boolean) to authenticated;
grant execute on function public.list_game_rooms_v14(text) to authenticated;
grant execute on function public.join_game_room_v14(text) to authenticated;
grant execute on function public.leave_game_room_v14(uuid) to authenticated;

do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='game_rooms') then
      execute 'alter publication supabase_realtime add table public.game_rooms';
    end if;
    if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='game_room_players') then
      execute 'alter publication supabase_realtime add table public.game_room_players';
    end if;
  end if;
end $$;
