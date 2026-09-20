-- Patogh v11 engagement/story/route extension
-- Run after previous v11 migrations.

create table if not exists public.engagement_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  discovery_xp int not null default 0,
  social_xp int not null default 0,
  culture_xp int not null default 0,
  contribution_xp int not null default 0,
  social_rhythm_months int not null default 0,
  attendance_streak int not null default 0,
  updated_at timestamptz not null default now()
);

create table if not exists public.quests (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  category text not null,
  target int not null default 1,
  reward_xp int not null default 0,
  start_at timestamptz,
  end_at timestamptz,
  city_id text,
  sponsored boolean not null default false,
  sponsor_label text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.quest_progress (
  quest_id uuid not null references public.quests(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  progress int not null default 0,
  completed_at timestamptz,
  primary key(quest_id, user_id)
);

create table if not exists public.passport_stamps (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  province_id text,
  city_id text,
  stamp_key text not null,
  title text not null,
  unlocked_at timestamptz not null default now(),
  evidence jsonb not null default '{}'::jsonb,
  unique(user_id, stamp_key)
);

create table if not exists public.place_stories (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  summary text not null default '',
  body text not null,
  story_type text not null,
  province_id text,
  city_id text,
  latitude double precision,
  longitude double precision,
  trigger_radius_m int not null default 1500,
  audio_url text,
  offline_asset_key text,
  author_user_id uuid references auth.users(id) on delete set null,
  author_label text,
  source_url text,
  source_note text,
  rights_status text not null default 'review_required',
  verification_status text not null default 'pending',
  active boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.story_listens (
  story_id uuid not null references public.place_stories(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  listened_at timestamptz not null default now(),
  completed boolean not null default false,
  primary key(story_id, user_id)
);

create table if not exists public.route_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  origin_city_id text,
  destination_city_id text,
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  location_retention_mode text not null default 'ephemeral'
    check (location_retention_mode in ('ephemeral','summary_only','user_saved'))
);

create table if not exists public.event_story_blueprints (
  id uuid primary key default gen_random_uuid(),
  event_id text references public.patogh_events(id) on delete cascade,
  promise text not null default '',
  chapters jsonb not null default '[]'::jsonb,
  memory_prompt text not null default '',
  created_at timestamptz not null default now()
);

alter table public.engagement_profiles enable row level security;
alter table public.quests enable row level security;
alter table public.quest_progress enable row level security;
alter table public.passport_stamps enable row level security;
alter table public.place_stories enable row level security;
alter table public.story_listens enable row level security;
alter table public.route_sessions enable row level security;
alter table public.event_story_blueprints enable row level security;

create policy "engagement_profile_self" on public.engagement_profiles
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "quests_read_active" on public.quests
for select using (active = true or public.is_admin());

create policy "quests_admin_write" on public.quests
for all using (public.is_admin()) with check (public.is_admin());

create policy "quest_progress_self" on public.quest_progress
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "passport_self_read" on public.passport_stamps
for select using (auth.uid() = user_id);

create policy "place_stories_public_verified" on public.place_stories
for select using (active = true and verification_status = 'verified');

create policy "place_stories_authenticated_submit" on public.place_stories
for insert with check (auth.uid() = author_user_id);

create policy "place_stories_admin_review" on public.place_stories
for update using (public.is_admin());

create policy "story_listens_self" on public.story_listens
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "route_sessions_self" on public.route_sessions
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "event_story_read" on public.event_story_blueprints
for select using (auth.role() = 'authenticated');

create policy "event_story_admin_write" on public.event_story_blueprints
for all using (public.is_admin()) with check (public.is_admin());

-- Privacy principle: raw GPS points are intentionally not modeled here.
-- Production clients should evaluate nearby story triggers on-device where practical.
