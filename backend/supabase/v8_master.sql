-- Patogh v8 master migration
-- Run after schema.sql, v6_roles_social.sql and v7_ecosystem.sql.

create table if not exists public.user_roles (
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('participant','venue','coordinator','organizer','admin')),
  status text not null default 'active' check (status in ('pending','active','rejected','suspended')),
  approved_by uuid references auth.users(id),
  approved_at timestamptz,
  created_at timestamptz not null default now(),
  primary key(user_id, role)
);

insert into public.user_roles (user_id, role, status)
select id, 'participant', 'active' from public.profiles
on conflict do nothing;

create table if not exists public.social_links (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  platform text not null,
  handle_or_url text not null,
  visibility text not null default 'public'
    check (visibility in ('public','shared_event','circle','mutual','private')),
  is_verified boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.circles (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null default 'حلقه من',
  created_at timestamptz not null default now()
);

create table if not exists public.circle_members (
  circle_id uuid not null references public.circles(id) on delete cascade,
  member_user_id uuid not null references auth.users(id) on delete cascade,
  relation_label text,
  status text not null default 'pending' check (status in ('pending','accepted','blocked')),
  notify_on_owner_event_join boolean not null default false,
  notify_on_member_event_join boolean not null default false,
  created_at timestamptz not null default now(),
  primary key(circle_id, member_user_id)
);

create table if not exists public.provinces (
  id bigserial primary key,
  code text unique,
  name text not null unique,
  active boolean not null default true
);

create table if not exists public.cities (
  id bigserial primary key,
  province_id bigint not null references public.provinces(id) on delete restrict,
  code text,
  name text not null,
  latitude numeric,
  longitude numeric,
  active boolean not null default true,
  unique(province_id, name)
);

alter table public.profiles add column if not exists province_id bigint references public.provinces(id);
alter table public.profiles add column if not exists city_id bigint references public.cities(id);
alter table public.patogh_events add column if not exists province_id bigint references public.provinces(id);
alter table public.patogh_events add column if not exists city_id bigint references public.cities(id);
alter table public.patogh_events add column if not exists event_code text;
alter table public.patogh_events add column if not exists exact_address text;
alter table public.patogh_events add column if not exists address_reveal_at timestamptz;
alter table public.patogh_events add column if not exists visibility text not null default 'public'
  check (visibility in ('public','private_link','invite_only','member_only','organization','sponsored','matched_only'));

create table if not exists public.user_connections (
  user_a uuid not null references auth.users(id) on delete cascade,
  user_b uuid not null references auth.users(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','mutual','blocked')),
  shared_event_count int not null default 0,
  created_at timestamptz not null default now(),
  primary key(user_a, user_b),
  check (user_a <> user_b)
);

create table if not exists public.repeat_intents (
  event_id text not null references public.patogh_events(id) on delete cascade,
  requester_id uuid not null references auth.users(id) on delete cascade,
  target_user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(event_id, requester_id, target_user_id)
);

create table if not exists public.event_time_polls (
  id uuid primary key default gen_random_uuid(),
  event_request_id uuid,
  title text not null,
  status text not null default 'open' check (status in ('open','closed')),
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.event_time_options (
  id uuid primary key default gen_random_uuid(),
  poll_id uuid not null references public.event_time_polls(id) on delete cascade,
  starts_at timestamptz not null
);

create table if not exists public.event_time_votes (
  option_id uuid not null references public.event_time_options(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  vote text not null check (vote in ('yes','maybe','no')),
  primary key(option_id, user_id)
);

create table if not exists public.registration_questions (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references public.patogh_events(id) on delete cascade,
  label text not null,
  question_type text not null check (question_type in ('text','number','single','multi','checkbox','consent','emergency_contact')),
  required boolean not null default false,
  options jsonb not null default '[]'::jsonb,
  sort_order int not null default 0
);

create table if not exists public.registration_answers (
  reservation_id uuid not null references public.reservations(id) on delete cascade,
  question_id uuid not null references public.registration_questions(id) on delete cascade,
  answer jsonb not null,
  primary key(reservation_id, question_id)
);

create table if not exists public.event_terms (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references public.patogh_events(id) on delete cascade,
  version int not null default 1,
  title text not null,
  body text not null,
  required boolean not null default true,
  created_at timestamptz not null default now(),
  unique(event_id, version)
);

create table if not exists public.event_consents (
  event_term_id uuid not null references public.event_terms(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  accepted_at timestamptz not null default now(),
  ip_hash text,
  primary key(event_term_id, user_id)
);

create table if not exists public.membership_clubs (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references auth.users(id) on delete set null,
  title text not null,
  description text not null default '',
  monthly_price bigint not null default 0,
  visibility text not null default 'public',
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.club_memberships (
  club_id uuid not null references public.membership_clubs(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'active' check (status in ('pending','active','cancelled','expired')),
  starts_at timestamptz not null default now(),
  ends_at timestamptz,
  primary key(club_id, user_id)
);

create table if not exists public.event_album_media (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references public.patogh_events(id) on delete cascade,
  uploader_id uuid not null references auth.users(id) on delete cascade,
  object_key text not null,
  media_type text not null check (media_type in ('image','video')),
  caption text,
  approved boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.event_staff (
  event_id text not null references public.patogh_events(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  staff_role text not null check (staff_role in ('manager','coordinator','checkin_only','finance','support')),
  created_at timestamptz not null default now(),
  primary key(event_id, user_id, staff_role)
);

create table if not exists public.venue_billing_policies (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid not null references public.venues(id) on delete cascade,
  policy_type text not null check (policy_type in ('preorder','pay_on_site','minimum_order','fixed_package','separate_bill','group_bill')),
  minimum_amount bigint not null default 0,
  description text,
  active boolean not null default true
);

alter table public.user_roles enable row level security;
alter table public.social_links enable row level security;
alter table public.circles enable row level security;
alter table public.circle_members enable row level security;
alter table public.user_connections enable row level security;
alter table public.repeat_intents enable row level security;
alter table public.membership_clubs enable row level security;
alter table public.club_memberships enable row level security;
alter table public.event_album_media enable row level security;
alter table public.event_staff enable row level security;

create policy "roles_self_read" on public.user_roles for select
using (auth.uid() = user_id or public.is_admin());

create policy "social_links_owner_all" on public.social_links for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "social_links_public_read" on public.social_links for select
using (visibility = 'public' or auth.uid() = user_id);

create policy "circles_owner" on public.circles for all
using (auth.uid() = owner_id)
with check (auth.uid() = owner_id);

create policy "circle_members_related" on public.circle_members for select
using (
  auth.uid() = member_user_id
  or exists (select 1 from public.circles c where c.id = circle_id and c.owner_id = auth.uid())
);

create policy "connections_related" on public.user_connections for select
using (auth.uid() in (user_a, user_b));

create policy "repeat_requester" on public.repeat_intents for all
using (auth.uid() = requester_id)
with check (auth.uid() = requester_id);

create policy "clubs_public_read" on public.membership_clubs for select
using (active = true);

create policy "club_members_self" on public.club_memberships for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "album_authenticated_read" on public.event_album_media for select
using (auth.role() = 'authenticated');

create policy "album_verified_attendee_insert" on public.event_album_media for insert
with check (
  auth.uid() = uploader_id
  and exists (
    select 1 from public.reservations r
    where r.user_id = auth.uid()
      and r.event_id = event_album_media.event_id
      and r.status in ('reserved','confirmed')
  )
);

create policy "event_staff_self_read" on public.event_staff for select
using (auth.uid() = user_id or public.is_admin());
