-- Patogh v12 Market Release / Multi-user core
-- Run AFTER schema.sql and migrations v6 -> v11.
-- Idempotent where practical.

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------------
-- Media assets: every upload first goes to pending-media and must be validated
-- by the validate-media Edge Function before it is linked to content.
-- ---------------------------------------------------------------------------
create table if not exists public.media_assets (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  storage_path text not null unique,
  media_type text not null check (media_type in ('image','video','audio')),
  mime_type text not null,
  size_bytes bigint not null check (size_bytes >= 0),
  duration_ms bigint,
  scope text not null check (scope in ('post','story','community','memory')),
  status text not null default 'approved' check (status in ('approved','rejected','quarantined')),
  created_at timestamptz not null default now()
);

create table if not exists public.timeline_post_media (
  post_id uuid not null references public.timeline_posts(id) on delete cascade,
  media_id uuid not null references public.media_assets(id) on delete cascade,
  sort_order int not null default 0,
  primary key(post_id, media_id)
);

create table if not exists public.story_media (
  story_id uuid not null references public.stories(id) on delete cascade,
  media_id uuid not null references public.media_assets(id) on delete cascade,
  sort_order int not null default 0,
  primary key(story_id, media_id)
);

create table if not exists public.chat_message_media (
  message_id bigint not null references public.chat_messages(id) on delete cascade,
  media_id uuid not null references public.media_assets(id) on delete cascade,
  sort_order int not null default 0,
  primary key(message_id, media_id)
);

create table if not exists public.user_blocks (
  blocker_id uuid not null references auth.users(id) on delete cascade,
  blocked_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);

create table if not exists public.account_deletion_audit (
  user_id uuid primary key,
  requested_at timestamptz not null default now(),
  completed_at timestamptz
);

-- Media-only posts/messages are legal. Media linkage enforces actual content.
alter table public.timeline_posts drop constraint if exists timeline_posts_text_check;
alter table public.timeline_posts add constraint timeline_posts_text_check check (char_length(text) <= 4000);
alter table public.chat_messages drop constraint if exists chat_messages_text_check;
alter table public.chat_messages alter column text set default '';
alter table public.chat_messages add constraint chat_messages_text_check check (char_length(text) <= 4000);

-- Storage buckets. Product limits are stricter than the technical bucket cap.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('pending-media','pending-media',false,104857600,array['image/jpeg','image/png','image/webp','image/gif','video/mp4','video/quicktime','audio/mpeg','audio/mp4','audio/wav','audio/ogg']),
  ('social-media','social-media',false,104857600,array['image/jpeg','image/png','image/webp','image/gif','video/mp4','video/quicktime','audio/mpeg','audio/mp4','audio/wav','audio/ogg'])
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------
alter table public.media_assets enable row level security;
alter table public.timeline_post_media enable row level security;
alter table public.story_media enable row level security;
alter table public.chat_message_media enable row level security;
alter table public.user_blocks enable row level security;
alter table public.account_deletion_audit enable row level security;

-- pending-media: client can only upload under its own user-id folder.
drop policy if exists "pending_media_insert_own" on storage.objects;
create policy "pending_media_insert_own"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'pending-media'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "pending_media_select_own" on storage.objects;
create policy "pending_media_select_own"
on storage.objects for select to authenticated
using (
  bucket_id = 'pending-media'
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- social-media is intentionally NOT directly readable by clients. Signed URLs
-- are issued by get-media-url after access checks.
drop policy if exists "media_assets_owner_select" on public.media_assets;
create policy "media_assets_owner_select"
on public.media_assets for select to authenticated
using (owner_id = auth.uid());

-- Link policies: creator owns both content and media asset.
drop policy if exists "post_media_owner_insert" on public.timeline_post_media;
create policy "post_media_owner_insert"
on public.timeline_post_media for insert to authenticated
with check (
  exists (select 1 from public.timeline_posts p where p.id = post_id and p.user_id = auth.uid())
  and exists (select 1 from public.media_assets m where m.id = media_id and m.owner_id = auth.uid() and m.scope = 'post')
);

drop policy if exists "story_media_owner_insert" on public.story_media;
create policy "story_media_owner_insert"
on public.story_media for insert to authenticated
with check (
  exists (select 1 from public.stories s where s.id = story_id and s.user_id = auth.uid())
  and exists (select 1 from public.media_assets m where m.id = media_id and m.owner_id = auth.uid() and m.scope = 'story')
);

drop policy if exists "chat_media_owner_insert" on public.chat_message_media;
create policy "chat_media_owner_insert"
on public.chat_message_media for insert to authenticated
with check (
  exists (select 1 from public.chat_messages c where c.id = message_id and c.user_id = auth.uid())
  and exists (select 1 from public.media_assets m where m.id = media_id and m.owner_id = auth.uid() and m.scope = 'community')
);

drop policy if exists "blocks_self" on public.user_blocks;
create policy "blocks_self"
on public.user_blocks for all to authenticated
using (blocker_id = auth.uid())
with check (blocker_id = auth.uid());

-- Tighten community/channel message posting. Event/support rooms that are not a
-- community keep the legacy authenticated behavior.
drop policy if exists "chat_self_insert" on public.chat_messages;
create policy "chat_self_insert"
on public.chat_messages for insert to authenticated
with check (
  auth.uid() = user_id
  and (
    not exists (select 1 from public.communities c where c.id::text = room_id)
    or exists (
      select 1
      from public.communities c
      join public.community_members cm on cm.community_id = c.id
      where c.id::text = room_id
        and cm.user_id = auth.uid()
        and (c.community_type = 'group' or cm.member_role in ('owner','admin'))
    )
  )
);

-- ---------------------------------------------------------------------------
-- Hard product limits at DB level. Client limits are UX only; these are final.
-- ---------------------------------------------------------------------------
create or replace function public.enforce_post_media_limit_v12()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count int;
  v_duration bigint;
  v_type text;
begin
  select count(*) into v_count from public.timeline_post_media where post_id = new.post_id;
  if v_count >= 20 then raise exception 'POST_MEDIA_LIMIT_20'; end if;
  select media_type, duration_ms into v_type, v_duration from public.media_assets where id = new.media_id;
  if v_type = 'video' and coalesce(v_duration, 999999999) > 120000 then raise exception 'POST_VIDEO_MAX_120_SECONDS'; end if;
  return new;
end;
$$;

drop trigger if exists trg_post_media_limit_v12 on public.timeline_post_media;
create trigger trg_post_media_limit_v12 before insert on public.timeline_post_media
for each row execute function public.enforce_post_media_limit_v12();

create or replace function public.enforce_story_media_limit_v12()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count int;
  v_duration bigint;
  v_type text;
begin
  select count(*) into v_count from public.story_media where story_id = new.story_id;
  if v_count >= 20 then raise exception 'STORY_MEDIA_LIMIT_20'; end if;
  select media_type, duration_ms into v_type, v_duration from public.media_assets where id = new.media_id;
  if v_type = 'video' and coalesce(v_duration, 999999999) > 120000 then raise exception 'STORY_VIDEO_MAX_120_SECONDS'; end if;
  return new;
end;
$$;

drop trigger if exists trg_story_media_limit_v12 on public.story_media;
create trigger trg_story_media_limit_v12 before insert on public.story_media
for each row execute function public.enforce_story_media_limit_v12();

create or replace function public.enforce_chat_video_limit_v12()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_size bigint;
  v_type text;
begin
  select media_type, size_bytes into v_type, v_size from public.media_assets where id = new.media_id;
  if v_type = 'video' and v_size > 10485760 then raise exception 'COMMUNITY_VIDEO_MAX_10_MIB'; end if;
  return new;
end;
$$;

drop trigger if exists trg_chat_video_limit_v12 on public.chat_message_media;
create trigger trg_chat_video_limit_v12 before insert on public.chat_message_media
for each row execute function public.enforce_chat_video_limit_v12();

-- ---------------------------------------------------------------------------
-- Feed / realtime helper RPCs
-- ---------------------------------------------------------------------------
create or replace function public.list_timeline_feed_v12()
returns setof jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'id', p.id,
    'user_id', p.user_id,
    'author_name', p.author_name,
    'role_label', p.role_label,
    'event_title', p.event_title,
    'text', p.text,
    'created_at', p.created_at,
    'likes_count', (select count(*) from public.timeline_likes l where l.post_id = p.id),
    'media', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', m.id,
        'media_type', m.media_type,
        'mime_type', m.mime_type,
        'size_bytes', m.size_bytes,
        'duration_ms', m.duration_ms,
        'storage_path', m.storage_path
      ) order by pm.sort_order)
      from public.timeline_post_media pm
      join public.media_assets m on m.id = pm.media_id
      where pm.post_id = p.id and m.status = 'approved'
    ), '[]'::jsonb)
  )
  from public.timeline_posts p
  where auth.uid() is not null
    and not exists (
      select 1 from public.user_blocks b
      where (b.blocker_id = auth.uid() and b.blocked_id = p.user_id)
         or (b.blocker_id = p.user_id and b.blocked_id = auth.uid())
    )
  order by p.created_at desc
  limit 100;
$$;

grant execute on function public.list_timeline_feed_v12() to authenticated;

create or replace function public.list_active_stories_v12()
returns setof jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'id', s.id,
    'user_id', s.user_id,
    'owner_name', s.owner_name,
    'owner_role', s.owner_role,
    'title', s.title,
    'subtitle', s.subtitle,
    'created_at', s.created_at,
    'expires_at', s.expires_at,
    'media', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', m.id,
        'media_type', m.media_type,
        'mime_type', m.mime_type,
        'size_bytes', m.size_bytes,
        'duration_ms', m.duration_ms,
        'storage_path', m.storage_path
      ) order by sm.sort_order)
      from public.story_media sm
      join public.media_assets m on m.id = sm.media_id
      where sm.story_id = s.id and m.status = 'approved'
    ), '[]'::jsonb)
  )
  from public.stories s
  where auth.uid() is not null and s.expires_at > now()
    and not exists (
      select 1 from public.user_blocks b
      where (b.blocker_id = auth.uid() and b.blocked_id = s.user_id)
         or (b.blocker_id = s.user_id and b.blocked_id = auth.uid())
    )
  order by s.created_at desc;
$$;

grant execute on function public.list_active_stories_v12() to authenticated;

create or replace function public.list_communities_v12()
returns setof jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'id', c.id,
    'title', c.title,
    'description', c.description,
    'community_type', c.community_type,
    'owner_name', c.owner_name,
    'member_count', (select count(*) from public.community_members cm where cm.community_id = c.id),
    'joined', exists(select 1 from public.community_members cm where cm.community_id = c.id and cm.user_id = auth.uid())
  )
  from public.communities c
  where auth.uid() is not null and (c.is_public = true or c.owner_id = auth.uid() or exists(
    select 1 from public.community_members cm where cm.community_id = c.id and cm.user_id = auth.uid()
  ))
  order by c.created_at desc;
$$;

grant execute on function public.list_communities_v12() to authenticated;

create or replace function public.toggle_community_membership_v12(p_community_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  if exists(select 1 from public.community_members where community_id = p_community_id and user_id = auth.uid()) then
    if exists(select 1 from public.community_members where community_id = p_community_id and user_id = auth.uid() and member_role = 'owner') then
      raise exception 'OWNER_CANNOT_LEAVE_WITH_THIS_ACTION';
    end if;
    delete from public.community_members where community_id = p_community_id and user_id = auth.uid();
  else
    insert into public.community_members(community_id,user_id,member_role) values(p_community_id,auth.uid(),'member');
  end if;
end;
$$;

grant execute on function public.toggle_community_membership_v12(uuid) to authenticated;

create or replace function public.toggle_timeline_like_v12(p_post_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  if exists(select 1 from public.timeline_likes where post_id = p_post_id and user_id = auth.uid()) then
    delete from public.timeline_likes where post_id = p_post_id and user_id = auth.uid();
  else
    insert into public.timeline_likes(post_id,user_id) values(p_post_id,auth.uid());
  end if;
end;
$$;

grant execute on function public.toggle_timeline_like_v12(uuid) to authenticated;

create or replace function public.list_chat_messages_v12(p_room_id text)
returns setof jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'id', c.id,
    'user_id', c.user_id,
    'text', c.text,
    'created_at', c.created_at,
    'media', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', m.id,
        'media_type', m.media_type,
        'mime_type', m.mime_type,
        'size_bytes', m.size_bytes,
        'duration_ms', m.duration_ms,
        'storage_path', m.storage_path
      ) order by cm.sort_order)
      from public.chat_message_media cm
      join public.media_assets m on m.id = cm.media_id
      where cm.message_id = c.id and m.status = 'approved'
    ), '[]'::jsonb)
  )
  from public.chat_messages c
  where c.room_id = p_room_id
    and auth.uid() is not null
    and (
      not exists(select 1 from public.communities x where x.id::text = p_room_id)
      or exists(select 1 from public.community_members x where x.community_id::text = p_room_id and x.user_id = auth.uid())
    )
  order by c.created_at asc
  limit 500;
$$;

grant execute on function public.list_chat_messages_v12(text) to authenticated;

-- Make tables available to Supabase Realtime (ignore duplicate publication errors manually if needed).
do $$
begin
  begin alter publication supabase_realtime add table public.chat_messages; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.timeline_posts; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.stories; exception when duplicate_object then null; end;
end $$;

-- Staging anonymous-auth profile helper: anonymous users can still save a
-- display phone/name for closed testing. Production OTP remains real.
create or replace function public.ensure_profile_v12(p_phone text default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  insert into public.profiles(id, phone, name, city, interests, show_age, allow_chat)
  values(auth.uid(), p_phone, 'کاربر پاتوق', 'مشهد', '{}', true, true)
  on conflict(id) do update set phone = coalesce(excluded.phone, public.profiles.phone);
  insert into public.user_roles(user_id, role, status)
  values(auth.uid(),'participant','active')
  on conflict(user_id,role) do nothing;
end;
$$;

grant execute on function public.ensure_profile_v12(text) to authenticated;

-- Multi-role approval: approval activates user_roles; participant remains active.
create or replace function public.approve_role_request(
  p_request_id uuid,
  p_approve boolean
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid;
  v_role text;
begin
  if not public.is_admin() then raise exception 'ADMIN_REQUIRED'; end if;
  select user_id, requested_role into v_user, v_role
  from public.role_requests where id = p_request_id for update;
  if v_user is null then raise exception 'REQUEST_NOT_FOUND'; end if;

  update public.role_requests
  set status = case when p_approve then 'approved' else 'rejected' end,
      reviewed_by = auth.uid(), reviewed_at = now()
  where id = p_request_id;

  if p_approve then
    insert into public.user_roles(user_id, role, status, approved_by, approved_at)
    values(v_user, v_role, 'active', auth.uid(), now())
    on conflict(user_id, role) do update
      set status = 'active', approved_by = excluded.approved_by, approved_at = excluded.approved_at;
    -- Compatibility with older screens/services that still read profiles.role.
    update public.profiles set role = v_role, updated_at = now() where id = v_user;
  else
    insert into public.user_roles(user_id, role, status, approved_by, approved_at)
    values(v_user, v_role, 'rejected', auth.uid(), now())
    on conflict(user_id, role) do update
      set status = 'rejected', approved_by = excluded.approved_by, approved_at = excluded.approved_at;
  end if;
end;
$$;

grant execute on function public.approve_role_request(uuid, boolean) to authenticated;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists(
    select 1 from public.user_roles
    where user_id = auth.uid() and role = 'admin' and status = 'active'
  );
$$;

-- Restrict chat read/write to personal support room, reserved event room,
-- community membership, or admin. This replaces the broad v6 policy.
drop policy if exists "chat_authenticated_read" on public.chat_messages;
create policy "chat_authenticated_read"
on public.chat_messages for select to authenticated
using (
  public.is_admin()
  or room_id = ('support:' || auth.uid()::text)
  or exists(
    select 1 from public.reservations r
    where r.user_id = auth.uid()
      and r.event_id = chat_messages.room_id
      and r.status in ('reserved','confirmed')
  )
  or exists(
    select 1 from public.community_members cm
    where cm.community_id::text = chat_messages.room_id
      and cm.user_id = auth.uid()
  )
);

drop policy if exists "chat_self_insert" on public.chat_messages;
create policy "chat_self_insert"
on public.chat_messages for insert to authenticated
with check (
  auth.uid() = user_id
  and (
    room_id = ('support:' || auth.uid()::text)
    or exists(
      select 1 from public.reservations r
      where r.user_id = auth.uid()
        and r.event_id = chat_messages.room_id
        and r.status in ('reserved','confirmed')
    )
    or exists (
      select 1
      from public.communities c
      join public.community_members cm on cm.community_id = c.id
      where c.id::text = chat_messages.room_id
        and cm.user_id = auth.uid()
        and (c.community_type = 'group' or cm.member_role in ('owner','admin'))
    )
  )
);

create or replace function public.list_chat_messages_v12(p_room_id text)
returns setof jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'id', c.id,
    'user_id', c.user_id,
    'text', c.text,
    'created_at', c.created_at,
    'media', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', m.id,
        'media_type', m.media_type,
        'mime_type', m.mime_type,
        'size_bytes', m.size_bytes,
        'duration_ms', m.duration_ms,
        'storage_path', m.storage_path
      ) order by cm.sort_order)
      from public.chat_message_media cm
      join public.media_assets m on m.id = cm.media_id
      where cm.message_id = c.id and m.status = 'approved'
    ), '[]'::jsonb)
  )
  from public.chat_messages c
  where c.room_id = p_room_id
    and (
      public.is_admin()
      or p_room_id = ('support:' || auth.uid()::text)
      or exists(select 1 from public.reservations r where r.user_id=auth.uid() and r.event_id=p_room_id and r.status in ('reserved','confirmed'))
      or exists(select 1 from public.community_members x where x.community_id::text=p_room_id and x.user_id=auth.uid())
    )
  order by c.created_at asc
  limit 500;
$$;

grant execute on function public.list_chat_messages_v12(text) to authenticated;

create or replace function public.toggle_community_membership_v12(p_community_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_public boolean;
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  select is_public into v_public from public.communities where id=p_community_id;
  if v_public is null then raise exception 'COMMUNITY_NOT_FOUND'; end if;
  if exists(select 1 from public.community_members where community_id=p_community_id and user_id=auth.uid()) then
    if exists(select 1 from public.community_members where community_id=p_community_id and user_id=auth.uid() and member_role='owner') then
      raise exception 'OWNER_CANNOT_LEAVE_WITH_THIS_ACTION';
    end if;
    delete from public.community_members where community_id=p_community_id and user_id=auth.uid();
  else
    if not v_public then raise exception 'INVITE_REQUIRED'; end if;
    insert into public.community_members(community_id,user_id,member_role) values(p_community_id,auth.uid(),'member');
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- v12 release hardening: explicit Data API grants and event-staff chat access.
-- RLS remains the authorization boundary; grants only make the Data API usable.
-- ---------------------------------------------------------------------------
grant usage on schema public to authenticated;
grant select, insert, update, delete on all tables in schema public to authenticated;
grant usage, select on all sequences in schema public to authenticated;
alter default privileges in schema public grant select, insert, update, delete on tables to authenticated;
alter default privileges in schema public grant usage, select on sequences to authenticated;

create or replace function public.can_access_chat_room_v12(
  p_room_id text,
  p_user_id uuid default auth.uid()
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    p_user_id is not null
    and (
      exists(
        select 1 from public.user_roles ur
        where ur.user_id = p_user_id
          and ur.role = 'admin'
          and ur.status = 'active'
      )
      or p_room_id = ('support:' || p_user_id::text)
      or exists(
        select 1 from public.reservations r
        where r.user_id = p_user_id
          and r.event_id = p_room_id
          and r.status in ('reserved','confirmed')
      )
      or exists(
        select 1
        from public.patogh_events e
        left join public.organizers o on o.id = e.organizer_id
        left join public.coordinators c on c.id = e.coordinator_id
        left join public.venues v on v.id = e.venue_id
        where e.id = p_room_id
          and (
            e.host_id = p_user_id
            or o.owner_id = p_user_id
            or c.user_id = p_user_id
            or v.owner_id = p_user_id
          )
      )
      or exists(
        select 1 from public.community_members cm
        where cm.community_id::text = p_room_id
          and cm.user_id = p_user_id
      )
    );
$$;

grant execute on function public.can_access_chat_room_v12(text, uuid) to authenticated;

drop policy if exists "chat_authenticated_read" on public.chat_messages;
create policy "chat_authenticated_read"
on public.chat_messages for select to authenticated
using (public.can_access_chat_room_v12(room_id, auth.uid()));

drop policy if exists "chat_self_insert" on public.chat_messages;
create policy "chat_self_insert"
on public.chat_messages for insert to authenticated
with check (
  auth.uid() = user_id
  and public.can_access_chat_room_v12(room_id, auth.uid())
  and (
    not exists(select 1 from public.communities c where c.id::text = room_id)
    or exists(
      select 1
      from public.communities c
      join public.community_members cm on cm.community_id = c.id
      where c.id::text = room_id
        and cm.user_id = auth.uid()
        and (c.community_type = 'group' or cm.member_role in ('owner','admin'))
    )
  )
);

create or replace function public.list_chat_messages_v12(p_room_id text)
returns setof jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'id', c.id,
    'user_id', c.user_id,
    'text', c.text,
    'created_at', c.created_at,
    'media', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', m.id,
        'media_type', m.media_type,
        'mime_type', m.mime_type,
        'size_bytes', m.size_bytes,
        'duration_ms', m.duration_ms,
        'storage_path', m.storage_path
      ) order by cm.sort_order)
      from public.chat_message_media cm
      join public.media_assets m on m.id = cm.media_id
      where cm.message_id = c.id and m.status = 'approved'
    ), '[]'::jsonb)
  )
  from public.chat_messages c
  where c.room_id = p_room_id
    and public.can_access_chat_room_v12(p_room_id, auth.uid())
  order by c.created_at asc
  limit 500;
$$;

grant execute on function public.list_chat_messages_v12(text) to authenticated;

-- ---------------------------------------------------------------------------
-- Onboarding/legal acceptance hardening.
-- ---------------------------------------------------------------------------
alter table public.profiles
  add column if not exists onboarding_completed boolean not null default false,
  add column if not exists terms_accepted_at timestamptz,
  add column if not exists terms_version text,
  add column if not exists privacy_version text;

-- Existing real profiles from earlier migrations are treated as onboarded;
-- fresh placeholder profiles created by staging keep onboarding_completed=false.
update public.profiles
set onboarding_completed = true
where onboarding_completed = false
  and (
    coalesce(name, '') <> 'کاربر پاتوق'
    or coalesce(cardinality(interests), 0) > 0
  );

create or replace function public.ensure_profile_v12(p_phone text default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  insert into public.profiles(
    id, phone, name, city, interests, show_age, allow_chat, onboarding_completed
  )
  values(
    auth.uid(), p_phone, 'کاربر پاتوق', 'مشهد', '{}', true, true, false
  )
  on conflict(id) do update
  set phone = coalesce(excluded.phone, public.profiles.phone);

  insert into public.user_roles(user_id, role, status)
  values(auth.uid(),'participant','active')
  on conflict(user_id,role) do nothing;
end;
$$;

grant execute on function public.ensure_profile_v12(text) to authenticated;

-- ---------------------------------------------------------------------------
-- RLS coverage for legacy v8 tables that were created before policies existed.
-- ---------------------------------------------------------------------------
alter table public.provinces enable row level security;
alter table public.cities enable row level security;
alter table public.event_time_polls enable row level security;
alter table public.event_time_options enable row level security;
alter table public.event_time_votes enable row level security;
alter table public.registration_questions enable row level security;
alter table public.registration_answers enable row level security;
alter table public.event_terms enable row level security;
alter table public.event_consents enable row level security;
alter table public.venue_billing_policies enable row level security;

drop policy if exists "provinces_authenticated_read" on public.provinces;
create policy "provinces_authenticated_read" on public.provinces for select to authenticated using (active = true);
drop policy if exists "cities_authenticated_read" on public.cities;
create policy "cities_authenticated_read" on public.cities for select to authenticated using (active = true);

drop policy if exists "event_time_polls_read" on public.event_time_polls;
create policy "event_time_polls_read" on public.event_time_polls for select to authenticated using (true);
drop policy if exists "event_time_polls_owner_write" on public.event_time_polls;
create policy "event_time_polls_owner_write" on public.event_time_polls for all to authenticated using (created_by = auth.uid() or public.is_admin()) with check (created_by = auth.uid() or public.is_admin());

drop policy if exists "event_time_options_read" on public.event_time_options;
create policy "event_time_options_read" on public.event_time_options for select to authenticated using (true);
drop policy if exists "event_time_options_poll_owner_write" on public.event_time_options;
create policy "event_time_options_poll_owner_write" on public.event_time_options for all to authenticated
using (exists(select 1 from public.event_time_polls p where p.id = poll_id and (p.created_by = auth.uid() or public.is_admin())))
with check (exists(select 1 from public.event_time_polls p where p.id = poll_id and (p.created_by = auth.uid() or public.is_admin())));

drop policy if exists "event_time_votes_read" on public.event_time_votes;
create policy "event_time_votes_read" on public.event_time_votes for select to authenticated using (true);
drop policy if exists "event_time_votes_self_write" on public.event_time_votes;
create policy "event_time_votes_self_write" on public.event_time_votes for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "registration_questions_read" on public.registration_questions;
create policy "registration_questions_read" on public.registration_questions for select to authenticated using (true);
drop policy if exists "registration_answers_self" on public.registration_answers;
create policy "registration_answers_self" on public.registration_answers for all to authenticated
using (exists(select 1 from public.reservations r where r.id = reservation_id and r.user_id = auth.uid()) or public.is_admin())
with check (exists(select 1 from public.reservations r where r.id = reservation_id and r.user_id = auth.uid()) or public.is_admin());

drop policy if exists "event_terms_read" on public.event_terms;
create policy "event_terms_read" on public.event_terms for select to authenticated using (true);
drop policy if exists "event_consents_self" on public.event_consents;
create policy "event_consents_self" on public.event_consents for all to authenticated using (user_id = auth.uid() or public.is_admin()) with check (user_id = auth.uid() or public.is_admin());

drop policy if exists "venue_billing_policies_read" on public.venue_billing_policies;
create policy "venue_billing_policies_read" on public.venue_billing_policies for select to authenticated using (active = true or public.is_admin());
