-- V14 shared turn-based state for Tic-Tac-Toe and Snakes & Ladders.
-- Apply to Staging only after checking the existing schema and migration history.
create table if not exists public.game_room_states (
  room_id uuid primary key references public.game_rooms(id) on delete cascade,
  game_state jsonb not null,
  version bigint not null default 1,
  updated_at timestamptz not null default now()
);

alter table public.game_room_states enable row level security;
revoke all on table public.game_room_states from public, anon, authenticated;
drop policy if exists game_room_states_member_read on public.game_room_states;
create policy game_room_states_member_read on public.game_room_states
  for select to authenticated
  using (exists (
    select 1 from public.game_room_players gp
    where gp.room_id = game_room_states.room_id and gp.user_id = auth.uid()
  ));
grant select on public.game_room_states to authenticated;

create or replace function public.get_game_state_v14(p_room_code text)
returns jsonb
language plpgsql security definer
set search_path = pg_catalog, public
as $$
declare
  v_uid uuid := auth.uid();
  v_room public.game_rooms%rowtype;
  v_state jsonb;
  v_players jsonb;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  select * into v_room from public.game_rooms where room_code = trim(p_room_code);
  if not found then raise exception 'room not found'; end if;
  if not exists (select 1 from public.game_room_players gp where gp.room_id=v_room.id and gp.user_id=v_uid) then
    raise exception 'room membership required';
  end if;

  if v_room.game_type = 'tic_tac_toe' then
    insert into public.game_room_states(room_id, game_state)
    values (v_room.id, jsonb_build_object(
      'game_type','tic_tac_toe','board',jsonb_build_array(0,0,0,0,0,0,0,0,0),
      'current_seat',1,'winner_seat',null,'status','waiting','last_move',null
    )) on conflict (room_id) do nothing;
  elsif v_room.game_type = 'snakes_ladders' then
    insert into public.game_room_states(room_id, game_state)
    values (v_room.id, jsonb_build_object(
      'game_type','snakes_ladders','positions',jsonb_build_array(0,0,0,0),
      'current_seat',1,'winner_seat',null,'status','waiting','last_dice',null,'last_move',null
    )) on conflict (room_id) do nothing;
  else
    insert into public.game_room_states(room_id, game_state)
    values (v_room.id, jsonb_build_object(
      'game_type',v_room.game_type,'status','engine_unavailable',
      'message','موتور قوانین این بازی هنوز در این نسخه فعال نشده.'
    )) on conflict (room_id) do nothing;
  end if;

  select game_state into v_state from public.game_room_states where room_id=v_room.id;
  select coalesce(jsonb_agg(jsonb_build_object(
    'user_id',gp.user_id,'seat',gp.seat,'name',coalesce(p.name,'کاربر پاتوق')
  ) order by gp.seat),'[]'::jsonb) into v_players
  from public.game_room_players gp left join public.profiles p on p.id=gp.user_id
  where gp.room_id=v_room.id;

  if jsonb_array_length(v_players) >= 2 and v_state->>'status'='waiting' then
    v_state := v_state || jsonb_build_object('status','active');
    update public.game_room_states set game_state=v_state,version=version+1,updated_at=now() where room_id=v_room.id;
  end if;
  return jsonb_build_object(
    'room_id',v_room.id,'room_code',v_room.room_code,'game_type',v_room.game_type,
    'max_players',v_room.max_players,'players',v_players,'state',v_state
  );
end;
$$;

create or replace function public.submit_game_action_v14(p_room_code text, p_action jsonb)
returns jsonb
language plpgsql security definer
set search_path = pg_catalog, public
as $$
declare
  v_uid uuid := auth.uid();
  v_room public.game_rooms%rowtype;
  v_state jsonb;
  v_board jsonb;
  v_positions jsonb;
  v_players jsonb;
  v_seat integer;
  v_count integer;
  v_current integer;
  v_cell integer;
  v_old integer;
  v_new integer;
  v_dice integer;
  v_winner integer := null;
  v_status text;
  v_line integer[][] := array[
    array[0,1,2],array[3,4,5],array[6,7,8],array[0,3,6],array[1,4,7],array[2,5,8],array[0,4,8],array[2,4,6]
  ];
  i integer;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  select * into v_room from public.game_rooms where room_code=trim(p_room_code) for update;
  if not found or v_room.status='closed' then raise exception 'room not found'; end if;
  select seat into v_seat from public.game_room_players where room_id=v_room.id and user_id=v_uid;
  if v_seat is null then raise exception 'room membership required'; end if;
  select count(*)::integer into v_count from public.game_room_players where room_id=v_room.id;
  if v_count < 2 then raise exception 'wait for another player'; end if;
  select game_state into v_state from public.game_room_states where room_id=v_room.id for update;
  if v_state is null then raise exception 'open the game room first'; end if;
  if v_state->>'status' <> 'active' then raise exception 'game is not active'; end if;
  v_current := (v_state->>'current_seat')::integer;
  if v_current <> v_seat then raise exception 'not your turn'; end if;

  if v_room.game_type='tic_tac_toe' then
    if p_action is null or p_action->>'cell' is null or (p_action->>'cell') !~ '^[0-8]$' then
      raise exception 'invalid cell';
    end if;
    v_cell := (p_action->>'cell')::integer;
    if v_cell < 0 or v_cell > 8 then raise exception 'invalid cell'; end if;
    v_board := v_state->'board';
    if (v_board->>v_cell)::integer <> 0 then raise exception 'cell already used'; end if;
    v_board := jsonb_set(v_board,array[v_cell::text],to_jsonb(v_seat),false);
    for i in 1..8 loop
      if (v_board->>(v_line[i][1]-1))::integer=v_seat
        and (v_board->>(v_line[i][2]-1))::integer=v_seat
        and (v_board->>(v_line[i][3]-1))::integer=v_seat then
        v_winner := v_seat; exit;
      end if;
    end loop;
    if v_winner is not null then
      v_status := 'won';
    elsif not exists (select 1 from jsonb_array_elements_text(v_board) e(value) where e.value='0') then
      v_status := 'draw';
    else
      v_status := 'active';
    end if;
    v_state := v_state || jsonb_build_object(
      'board',v_board,'winner_seat',v_winner,'status',v_status,
      'current_seat',case when v_seat=1 then 2 else 1 end,
      'last_move',jsonb_build_object('seat',v_seat,'cell',v_cell,'at',now())
    );
  elsif v_room.game_type='snakes_ladders' then
    if coalesce(p_action->>'type','') <> 'roll' then raise exception 'invalid action'; end if;
    v_dice := floor(random()*6)::integer+1;
    v_positions := v_state->'positions';
    v_old := coalesce((v_positions->>(v_seat-1))::integer,0);
    v_new := case when v_old+v_dice <= 100 then v_old+v_dice else v_old end;
    v_new := case v_new
      when 4 then 14 when 9 then 31 when 20 then 38 when 28 then 84
      when 40 then 59 when 51 then 67 when 63 then 81 when 71 then 91
      when 17 then 7 when 54 then 34 when 62 then 19 when 64 then 60
      when 87 then 24 when 93 then 73 when 95 then 75 when 99 then 78
      else v_new end;
    v_positions := jsonb_set(v_positions,array[(v_seat-1)::text],to_jsonb(v_new),false);
    if v_new=100 then v_winner := v_seat; v_status := 'won'; else v_status := 'active'; end if;
    v_state := v_state || jsonb_build_object(
      'positions',v_positions,'last_dice',v_dice,'winner_seat',v_winner,'status',v_status,
      'current_seat',case when v_seat>=v_count then 1 else v_seat+1 end,
      'last_move',jsonb_build_object('seat',v_seat,'from',v_old,'to',v_new,'dice',v_dice,'at',now())
    );
  else
    raise exception 'game engine not yet available for this game';
  end if;

  update public.game_room_states set game_state=v_state,version=version+1,updated_at=now() where room_id=v_room.id;
  select coalesce(jsonb_agg(jsonb_build_object(
    'user_id',gp.user_id,'seat',gp.seat,'name',coalesce(p.name,'کاربر پاتوق')
  ) order by gp.seat),'[]'::jsonb) into v_players
  from public.game_room_players gp left join public.profiles p on p.id=gp.user_id where gp.room_id=v_room.id;
  return jsonb_build_object('room_id',v_room.id,'room_code',v_room.room_code,
    'game_type',v_room.game_type,'players',v_players,'state',v_state);
end;
$$;

revoke all on function public.get_game_state_v14(text) from public, anon;
revoke all on function public.submit_game_action_v14(text,jsonb) from public, anon;
grant execute on function public.get_game_state_v14(text) to authenticated;
grant execute on function public.submit_game_action_v14(text,jsonb) to authenticated;

do $$
begin
  if exists (select 1 from pg_publication where pubname='supabase_realtime')
    and not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='game_room_states') then
    execute 'alter publication supabase_realtime add table public.game_room_states';
  end if;
end $$;
