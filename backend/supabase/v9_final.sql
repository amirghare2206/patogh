-- Patogh v9 Final Reference
-- Run after schema.sql, v6_roles_social.sql, v7_ecosystem.sql and v8_master.sql.

-- Event modes now cover normal Patogh events, private life events and large conferences.
alter table public.patogh_events
  add column if not exists event_mode text not null default 'community'
  check (event_mode in ('community','private_family','conference','corporate','sponsored'));

alter table public.patogh_events
  add column if not exists anniversary_enabled boolean not null default false,
  add column if not exists default_memory_retention_days int not null default 365,
  add column if not exists guestbook_enabled boolean not null default true;

-- Private/family event details: wedding, birthday, memorial, graduation, etc.
create table if not exists public.private_event_details (
  event_id text primary key references public.patogh_events(id) on delete cascade,
  host_user_id uuid not null references auth.users(id) on delete cascade,
  ceremony_type text not null,
  invitation_title text,
  invitation_message text,
  dress_code text,
  allow_plus_one boolean not null default false,
  plus_one_limit int not null default 0,
  host_covers_hosting_cost boolean not null default true,
  exact_address_visible_to_confirmed_only boolean not null default true,
  created_at timestamptz not null default now()
);

-- Invite by Patogh user, username/handle, phone, or circle.
create table if not exists public.event_invitations (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references public.patogh_events(id) on delete cascade,
  inviter_id uuid not null references auth.users(id) on delete cascade,
  invitee_user_id uuid references auth.users(id) on delete cascade,
  invitee_phone text,
  invitee_username text,
  invitation_token uuid not null default gen_random_uuid(),
  delivery_channel text not null default 'patogh'
    check (delivery_channel in ('patogh','sms','circle','share_link')),
  status text not null default 'invited'
    check (status in ('invited','accepted','declined','maybe','expired','revoked')),
  plus_one_limit int not null default 0,
  plus_one_count int not null default 0,
  responded_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  check (
    invitee_user_id is not null
    or invitee_phone is not null
    or invitee_username is not null
  )
);

create index if not exists event_invitations_event_idx
  on public.event_invitations(event_id);
create index if not exists event_invitations_user_idx
  on public.event_invitations(invitee_user_id);

-- Memory capsule persists the identity of a past event even when shared media expires.
create table if not exists public.memory_capsules (
  event_id text primary key references public.patogh_events(id) on delete cascade,
  created_by uuid references auth.users(id) on delete set null,
  anniversary_enabled boolean not null default true,
  anniversary_month int,
  anniversary_day int,
  cover_object_key text,
  memory_count int not null default 0,
  created_at timestamptz not null default now()
);

-- Memories support image/video/text/audio/guestbook and independent privacy/retention.
create table if not exists public.event_memories (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references public.patogh_events(id) on delete cascade,
  author_id uuid not null references auth.users(id) on delete cascade,
  memory_type text not null
    check (memory_type in ('image','video','text','audio','guestbook')),
  object_key text,
  body text,
  visibility text not null default 'event_members'
    check (visibility in ('private','event_members','circle','public_timeline')),
  retention_until timestamptz,
  keep_personal_copy boolean not null default true,
  shared_to_timeline boolean not null default false,
  verified_attendance boolean not null default false,
  moderation_status text not null default 'visible'
    check (moderation_status in ('visible','pending','hidden','removed')),
  created_at timestamptz not null default now()
);

create index if not exists event_memories_event_idx
  on public.event_memories(event_id, created_at desc);

-- Specific grants allow a private memory to be shared with selected people later.
create table if not exists public.memory_access_grants (
  memory_id uuid not null references public.event_memories(id) on delete cascade,
  grantee_user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(memory_id, grantee_user_id)
);

-- Anniversary notification preferences are per user and per event.
create table if not exists public.anniversary_subscriptions (
  event_id text not null references public.patogh_events(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  enabled boolean not null default true,
  primary key(event_id, user_id)
);

-- Large conference / seminar mode.
create table if not exists public.conference_details (
  event_id text primary key references public.patogh_events(id) on delete cascade,
  registration_open boolean not null default true,
  certificate_enabled boolean not null default false,
  sponsor_booths_enabled boolean not null default false,
  agenda_public boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.conference_ticket_tiers (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references public.patogh_events(id) on delete cascade,
  title text not null,
  price bigint not null default 0,
  capacity int,
  benefits jsonb not null default '[]'::jsonb,
  active boolean not null default true
);

create table if not exists public.conference_sessions (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references public.patogh_events(id) on delete cascade,
  title text not null,
  starts_at timestamptz,
  ends_at timestamptz,
  room_label text,
  description text
);

create table if not exists public.conference_speakers (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references public.patogh_events(id) on delete cascade,
  name text not null,
  title text,
  bio text,
  avatar_object_key text,
  social_links jsonb not null default '[]'::jsonb
);

create table if not exists public.conference_registrations (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references public.patogh_events(id) on delete cascade,
  user_id uuid references auth.users(id) on delete set null,
  ticket_tier_id uuid references public.conference_ticket_tiers(id) on delete set null,
  registration_code text not null unique,
  checked_in_at timestamptz,
  certificate_object_key text,
  created_at timestamptz not null default now()
);

-- Replace the broad v8 album policy: event media is no longer readable by every logged-in account.
drop policy if exists "album_authenticated_read" on public.event_album_media;
create policy "album_event_member_read"
on public.event_album_media for select
using (
  auth.uid() = uploader_id
  or public.is_admin()
  or exists (
    select 1 from public.reservations r
    where r.event_id = event_album_media.event_id
      and r.user_id = auth.uid()
      and r.status in ('reserved','confirmed')
  )
  or exists (
    select 1 from public.event_staff s
    where s.event_id = event_album_media.event_id
      and s.user_id = auth.uid()
  )
);

alter table public.private_event_details enable row level security;
alter table public.event_invitations enable row level security;
alter table public.memory_capsules enable row level security;
alter table public.event_memories enable row level security;
alter table public.memory_access_grants enable row level security;
alter table public.anniversary_subscriptions enable row level security;
alter table public.conference_details enable row level security;
alter table public.conference_ticket_tiers enable row level security;
alter table public.conference_sessions enable row level security;
alter table public.conference_speakers enable row level security;
alter table public.conference_registrations enable row level security;

create policy "private_event_host_read_write"
on public.private_event_details for all
using (auth.uid() = host_user_id or public.is_admin())
with check (auth.uid() = host_user_id or public.is_admin());

create policy "invitation_related_read"
on public.event_invitations for select
using (
  auth.uid() = inviter_id
  or auth.uid() = invitee_user_id
  or public.is_admin()
);

create policy "invitation_host_insert"
on public.event_invitations for insert
with check (
  auth.uid() = inviter_id
  and exists (
    select 1 from public.private_event_details d
    where d.event_id = event_invitations.event_id
      and d.host_user_id = auth.uid()
  )
);

create policy "invitation_related_update"
on public.event_invitations for update
using (
  auth.uid() = inviter_id
  or auth.uid() = invitee_user_id
  or public.is_admin()
);

create policy "capsule_event_member_read"
on public.memory_capsules for select
using (
  public.is_admin()
  or exists (
    select 1 from public.reservations r
    where r.event_id = memory_capsules.event_id
      and r.user_id = auth.uid()
      and r.status in ('reserved','confirmed')
  )
  or exists (
    select 1 from public.private_event_details d
    where d.event_id = memory_capsules.event_id
      and d.host_user_id = auth.uid()
  )
);

create policy "memory_author_read"
on public.event_memories for select
using (auth.uid() = author_id or public.is_admin());

create policy "memory_event_member_read"
on public.event_memories for select
using (
  visibility = 'event_members'
  and exists (
    select 1 from public.reservations r
    where r.event_id = event_memories.event_id
      and r.user_id = auth.uid()
      and r.status in ('reserved','confirmed')
  )
);

create policy "memory_granted_read"
on public.event_memories for select
using (
  exists (
    select 1 from public.memory_access_grants g
    where g.memory_id = event_memories.id
      and g.grantee_user_id = auth.uid()
  )
);

create policy "memory_public_timeline_read"
on public.event_memories for select
using (visibility = 'public_timeline' and moderation_status = 'visible');

create policy "memory_verified_attendee_insert"
on public.event_memories for insert
with check (
  auth.uid() = author_id
  and (
    exists (
      select 1 from public.reservations r
      where r.event_id = event_memories.event_id
        and r.user_id = auth.uid()
        and r.status in ('reserved','confirmed')
    )
    or exists (
      select 1 from public.private_event_details d
      where d.event_id = event_memories.event_id
        and d.host_user_id = auth.uid()
    )
  )
);

create policy "memory_author_update_delete"
on public.event_memories for all
using (auth.uid() = author_id or public.is_admin())
with check (auth.uid() = author_id or public.is_admin());

create policy "memory_grant_owner"
on public.memory_access_grants for all
using (
  exists (
    select 1 from public.event_memories m
    where m.id = memory_access_grants.memory_id
      and m.author_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.event_memories m
    where m.id = memory_access_grants.memory_id
      and m.author_id = auth.uid()
  )
);

create policy "anniversary_self"
on public.anniversary_subscriptions for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "conference_public_read"
on public.conference_details for select
using (true);

create policy "conference_tiers_public_read"
on public.conference_ticket_tiers for select
using (active = true);

create policy "conference_sessions_public_read"
on public.conference_sessions for select
using (true);

create policy "conference_speakers_public_read"
on public.conference_speakers for select
using (true);

create policy "conference_registration_self"
on public.conference_registrations for select
using (auth.uid() = user_id or public.is_admin());

-- Guest RSVP by invitation token should be exposed through a server/Edge Function,
-- not by granting anonymous direct table updates.
