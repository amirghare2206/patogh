-- Patogh v6 role/social extension. Run after schema.sql.

alter table public.profiles drop constraint if exists profiles_role_check;
alter table public.profiles
  add constraint profiles_role_check
  check (role in ('participant','venue','coordinator','organizer','admin'));
alter table public.profiles alter column role set default 'participant';

create table if not exists public.categories (
  id text primary key,
  title text not null,
  subtitle text not null default '',
  icon_code_point int,
  color_value bigint,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.role_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  requested_role text not null check (requested_role in ('venue','coordinator','organizer')),
  note text not null default '',
  documents jsonb not null default '{}'::jsonb,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  reviewed_by uuid references auth.users(id),
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.venues (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  city text not null,
  address text,
  description text,
  capacity int not null default 0,
  approved boolean not null default false,
  rating numeric(3,2) not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.organizers (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  description text,
  approved boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.coordinators (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  bio text,
  approved boolean not null default false,
  trust_score int not null default 0,
  created_at timestamptz not null default now()
);

alter table public.patogh_events
  add column if not exists organizer_id uuid references public.organizers(id) on delete set null,
  add column if not exists venue_id uuid references public.venues(id) on delete set null,
  add column if not exists coordinator_id uuid references public.coordinators(id) on delete set null,
  add column if not exists approval_status text not null default 'pending'
    check (approval_status in ('draft','pending','approved','rejected','cancelled'));

create table if not exists public.timeline_posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  event_id text references public.patogh_events(id) on delete set null,
  text text not null check (char_length(text) between 1 and 4000),
  author_name text not null default 'کاربر پاتوق',
  role_label text not null default 'شرکت‌کننده',
  event_title text not null default 'پاتوق',
  media_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.timeline_likes (
  post_id uuid not null references public.timeline_posts(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(post_id,user_id)
);

create table if not exists public.stories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  subtitle text,
  owner_name text not null default 'پاتوق',
  owner_role text not null default 'organizer',
  media_url text,
  event_id text references public.patogh_events(id) on delete set null,
  expires_at timestamptz not null default (now() + interval '24 hours'),
  created_at timestamptz not null default now()
);

create table if not exists public.communities (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text not null default '',
  owner_name text not null default 'کاربر پاتوق',
  member_count int not null default 1,
  community_type text not null check (community_type in ('group','channel')),
  event_id text references public.patogh_events(id) on delete set null,
  is_public boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.community_members (
  community_id uuid not null references public.communities(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  member_role text not null default 'member' check (member_role in ('owner','admin','member')),
  joined_at timestamptz not null default now(),
  primary key(community_id,user_id)
);

create table if not exists public.moderation_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references auth.users(id) on delete cascade,
  target_user_id uuid references auth.users(id) on delete set null,
  event_id text references public.patogh_events(id) on delete set null,
  reason text not null,
  details text,
  status text not null default 'open' check (status in ('open','reviewing','resolved','dismissed')),
  created_at timestamptz not null default now()
);

create table if not exists public.audit_logs (
  id bigint generated by default as identity primary key,
  actor_id uuid references auth.users(id),
  action text not null,
  entity_type text not null,
  entity_id text,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.categories enable row level security;
alter table public.role_requests enable row level security;
alter table public.venues enable row level security;
alter table public.organizers enable row level security;
alter table public.coordinators enable row level security;
alter table public.timeline_posts enable row level security;
alter table public.timeline_likes enable row level security;
alter table public.stories enable row level security;
alter table public.communities enable row level security;
alter table public.community_members enable row level security;
alter table public.moderation_reports enable row level security;
alter table public.audit_logs enable row level security;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path=public as $$
  select exists(select 1 from public.profiles where id=auth.uid() and role='admin');
$$;

drop policy if exists categories_read on public.categories;
create policy categories_read on public.categories for select using (is_active=true or public.is_admin());
drop policy if exists categories_admin_write on public.categories;
create policy categories_admin_write on public.categories for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists role_requests_self_insert on public.role_requests;
create policy role_requests_self_insert on public.role_requests for insert with check (auth.uid()=user_id);
drop policy if exists role_requests_self_or_admin_read on public.role_requests;
create policy role_requests_self_or_admin_read on public.role_requests for select using (auth.uid()=user_id or public.is_admin());
drop policy if exists role_requests_admin_update on public.role_requests;
create policy role_requests_admin_update on public.role_requests for update using (public.is_admin());

drop policy if exists timeline_read on public.timeline_posts;
create policy timeline_read on public.timeline_posts for select using (auth.role()='authenticated');
drop policy if exists timeline_attendee_insert on public.timeline_posts;
create policy timeline_attendee_insert on public.timeline_posts for insert with check (
  auth.uid()=user_id and (
    event_id is null or exists(
      select 1 from public.reservations r
      where r.user_id=auth.uid() and r.event_id=timeline_posts.event_id
        and r.status in ('reserved','confirmed')
    )
  )
);

drop policy if exists timeline_like_self on public.timeline_likes;
create policy timeline_like_self on public.timeline_likes for all using (auth.uid()=user_id) with check (auth.uid()=user_id);

drop policy if exists stories_read_live on public.stories;
create policy stories_read_live on public.stories for select using (expires_at>now());
drop policy if exists stories_venue_organizer_insert on public.stories;
create policy stories_venue_organizer_insert on public.stories for insert with check (
  auth.uid()=user_id and exists(
    select 1 from public.profiles p where p.id=auth.uid() and p.role in ('venue','organizer','admin')
  )
);

drop policy if exists communities_read on public.communities;
create policy communities_read on public.communities for select using (is_public=true or auth.uid()=owner_id);
drop policy if exists communities_create on public.communities;
create policy communities_create on public.communities for insert with check (auth.uid()=owner_id);
drop policy if exists community_members_self on public.community_members;
create policy community_members_self on public.community_members for all using (auth.uid()=user_id) with check (auth.uid()=user_id);

drop policy if exists reports_self_insert on public.moderation_reports;
create policy reports_self_insert on public.moderation_reports for insert with check (auth.uid()=reporter_id);
drop policy if exists reports_admin_read on public.moderation_reports;
create policy reports_admin_read on public.moderation_reports for select using (public.is_admin());
drop policy if exists audit_admin_read on public.audit_logs;
create policy audit_admin_read on public.audit_logs for select using (public.is_admin());

create or replace function public.approve_role_request(p_request_id uuid,p_approve boolean)
returns void language plpgsql security definer set search_path=public as $$
declare v_user uuid; v_role text;
begin
  if not public.is_admin() then raise exception 'ADMIN_REQUIRED'; end if;
  select user_id,requested_role into v_user,v_role from public.role_requests where id=p_request_id for update;
  if v_user is null then raise exception 'REQUEST_NOT_FOUND'; end if;
  update public.role_requests set status=case when p_approve then 'approved' else 'rejected' end,
    reviewed_by=auth.uid(), reviewed_at=now() where id=p_request_id;
  if p_approve then update public.profiles set role=v_role, updated_at=now() where id=v_user; end if;
  insert into public.audit_logs(actor_id,action,entity_type,entity_id,payload)
  values(auth.uid(),case when p_approve then 'approve_role' else 'reject_role' end,'role_request',p_request_id::text,
    jsonb_build_object('user_id',v_user,'role',v_role));
end; $$;

grant execute on function public.approve_role_request(uuid,boolean) to authenticated;
