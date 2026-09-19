-- Patogh v11 Time & Occasion Engine + Memorial
-- Run after v10_surprise_golrizon.sql

create table if not exists public.calendar_sources (
  id uuid primary key default gen_random_uuid(),
  source_key text unique not null,
  title text not null,
  source_type text not null check (source_type in ('official','religious','heritage','global','sports','seasonal','manual','organization')),
  provider_name text,
  source_version text,
  enabled boolean not null default true,
  last_synced_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.calendar_occasions (
  id uuid primary key default gen_random_uuid(),
  source_id uuid references public.calendar_sources(id) on delete set null,
  external_id text,
  title text not null,
  description text not null default '',
  layer text not null,
  calendar_system text not null default 'gregorian',
  starts_at timestamptz,
  ends_at timestamptz,
  all_day boolean not null default true,
  region_scope jsonb not null default '{}'::jsonb,
  source_version text,
  certainty numeric(4,3) not null default 1,
  event_generation_enabled boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  last_updated_at timestamptz not null default now(),
  unique(source_id, external_id)
);

create table if not exists public.personal_occasions (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  occasion_type text not null,
  event_date date not null,
  calendar_system text not null default 'jalali',
  repeats_yearly boolean not null default true,
  visibility text not null default 'private' check (visibility in ('private','family','close_friends','circle','public')),
  suggest_events boolean not null default true,
  notify_audience boolean not null default false,
  circle_id uuid,
  created_at timestamptz not null default now()
);

create table if not exists public.occasion_reminders (
  id uuid primary key default gen_random_uuid(),
  personal_occasion_id uuid references public.personal_occasions(id) on delete cascade,
  calendar_occasion_id uuid references public.calendar_occasions(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  audience_type text not null default 'owner',
  offset_minutes int not null,
  delivery_channels text[] not null default array['push']::text[],
  status text not null default 'scheduled' check (status in ('scheduled','sent','cancelled','failed')),
  scheduled_for timestamptz,
  sent_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.sports_seasonal_events (
  id uuid primary key default gen_random_uuid(),
  source_id uuid references public.calendar_sources(id) on delete set null,
  external_id text,
  title text not null,
  event_type text not null check (event_type in ('sports','seasonal','cultural','expo','festival','other')),
  starts_at timestamptz,
  ends_at timestamptz,
  geography jsonb not null default '{}'::jsonb,
  participants jsonb not null default '[]'::jsonb,
  status text not null default 'scheduled',
  metadata jsonb not null default '{}'::jsonb,
  last_updated_at timestamptz not null default now(),
  unique(source_id, external_id)
);

create table if not exists public.event_templates (
  id uuid primary key default gen_random_uuid(),
  template_key text unique not null,
  title text not null,
  category_id text,
  suitable_venue_types text[] not null default '{}',
  registration_schema jsonb not null default '{}'::jsonb,
  default_reminders jsonb not null default '[]'::jsonb,
  generation_rules jsonb not null default '{}'::jsonb,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.event_opportunities (
  id uuid primary key default gen_random_uuid(),
  trigger_type text not null,
  trigger_id text,
  title text not null,
  reason text not null default '',
  province_id text,
  city_id text,
  demand_count int not null default 0,
  matching_host_count int not null default 0,
  opportunity_score int not null default 0 check (opportunity_score between 0 and 100),
  suggested_template_id uuid references public.event_templates(id) on delete set null,
  status text not null default 'open' check (status in ('open','claimed','converted','expired','dismissed')),
  expires_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.event_generation_rules (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  trigger_type text not null,
  trigger_filter jsonb not null default '{}'::jsonb,
  minimum_demand int not null default 0,
  minimum_matching_hosts int not null default 0,
  template_id uuid references public.event_templates(id) on delete set null,
  auto_notify_hosts boolean not null default false,
  auto_create_draft boolean not null default false,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.memorials (
  id uuid primary key default gen_random_uuid(),
  created_by uuid not null references auth.users(id) on delete cascade,
  person_name text not null,
  birth_date date,
  death_date date,
  life_summary text not null default '',
  creator_relation text not null,
  visibility text not null default 'family_only' check (visibility in ('family_only','invited','public')),
  verification_status text not null default 'pending' check (verification_status in ('pending','verified','rejected','archived')),
  anniversary_reminders_enabled boolean not null default true,
  official_family_contact uuid references auth.users(id) on delete set null,
  linked_golrizon_id uuid,
  created_at timestamptz not null default now(),
  verified_at timestamptz
);

create table if not exists public.memorial_members (
  memorial_id uuid not null references public.memorials(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  member_role text not null default 'viewer' check (member_role in ('owner','family_admin','contributor','viewer')),
  invited_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  primary key(memorial_id, user_id)
);

create table if not exists public.memorial_entries (
  id uuid primary key default gen_random_uuid(),
  memorial_id uuid not null references public.memorials(id) on delete cascade,
  author_id uuid not null references auth.users(id) on delete cascade,
  entry_type text not null default 'text' check (entry_type in ('text','photo','video','audio','condolence')),
  text_content text,
  media_url text,
  visibility text not null default 'members' check (visibility in ('private','family','members','public')),
  moderation_status text not null default 'visible' check (moderation_status in ('pending','visible','hidden','removed')),
  created_at timestamptz not null default now()
);

create table if not exists public.memorial_anniversaries (
  id uuid primary key default gen_random_uuid(),
  memorial_id uuid not null references public.memorials(id) on delete cascade,
  anniversary_year int not null,
  event_id text references public.patogh_events(id) on delete set null,
  reminder_started_at timestamptz,
  created_at timestamptz not null default now(),
  unique(memorial_id, anniversary_year)
);

alter table public.calendar_sources enable row level security;
alter table public.calendar_occasions enable row level security;
alter table public.personal_occasions enable row level security;
alter table public.occasion_reminders enable row level security;
alter table public.sports_seasonal_events enable row level security;
alter table public.event_templates enable row level security;
alter table public.event_opportunities enable row level security;
alter table public.event_generation_rules enable row level security;
alter table public.memorials enable row level security;
alter table public.memorial_members enable row level security;
alter table public.memorial_entries enable row level security;
alter table public.memorial_anniversaries enable row level security;

create policy "calendar_sources_authenticated_read" on public.calendar_sources
for select using (auth.role() = 'authenticated');

create policy "calendar_occasions_authenticated_read" on public.calendar_occasions
for select using (auth.role() = 'authenticated');

create policy "personal_occasions_owner" on public.personal_occasions
for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create policy "occasion_reminders_owner" on public.occasion_reminders
for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "sports_events_authenticated_read" on public.sports_seasonal_events
for select using (auth.role() = 'authenticated');

create policy "event_templates_authenticated_read" on public.event_templates
for select using (auth.role() = 'authenticated');

create policy "opportunities_authenticated_read" on public.event_opportunities
for select using (auth.role() = 'authenticated');

create policy "memorial_read" on public.memorials
for select using (
  visibility = 'public'
  or created_by = auth.uid()
  or exists (
    select 1 from public.memorial_members mm
    where mm.memorial_id = memorials.id and mm.user_id = auth.uid()
  )
  or public.is_admin()
);

create policy "memorial_create" on public.memorials
for insert with check (created_by = auth.uid());

create policy "memorial_owner_update" on public.memorials
for update using (created_by = auth.uid() or public.is_admin());

create policy "memorial_members_visible" on public.memorial_members
for select using (
  user_id = auth.uid()
  or exists (
    select 1 from public.memorial_members me
    where me.memorial_id = memorial_members.memorial_id
      and me.user_id = auth.uid()
      and me.member_role in ('owner','family_admin')
  )
  or public.is_admin()
);

create policy "memorial_entries_read" on public.memorial_entries
for select using (
  visibility = 'public'
  or author_id = auth.uid()
  or exists (
    select 1 from public.memorial_members mm
    where mm.memorial_id = memorial_entries.memorial_id
      and mm.user_id = auth.uid()
  )
  or public.is_admin()
);

create policy "memorial_entries_insert" on public.memorial_entries
for insert with check (
  author_id = auth.uid()
  and exists (
    select 1 from public.memorial_members mm
    where mm.memorial_id = memorial_entries.memorial_id
      and mm.user_id = auth.uid()
  )
);

create policy "admin_calendar_write" on public.calendar_sources
for all using (public.is_admin()) with check (public.is_admin());

create policy "admin_calendar_occasions_write" on public.calendar_occasions
for all using (public.is_admin()) with check (public.is_admin());

create policy "admin_sports_write" on public.sports_seasonal_events
for all using (public.is_admin()) with check (public.is_admin());

create policy "admin_templates_write" on public.event_templates
for all using (public.is_admin()) with check (public.is_admin());

create policy "admin_opportunities_write" on public.event_opportunities
for all using (public.is_admin()) with check (public.is_admin());

create policy "admin_generation_rules_write" on public.event_generation_rules
for all using (public.is_admin()) with check (public.is_admin());

create or replace function public.approve_memorial(p_memorial_id uuid, p_approve boolean)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'ADMIN_REQUIRED';
  end if;

  update public.memorials
  set verification_status = case when p_approve then 'verified' else 'rejected' end,
      verified_at = case when p_approve then now() else null end
  where id = p_memorial_id;

  insert into public.audit_logs(actor_id, action, entity_type, entity_id)
  values(auth.uid(), case when p_approve then 'approve_memorial' else 'reject_memorial' end, 'memorial', p_memorial_id::text);
end;
$$;

grant execute on function public.approve_memorial(uuid, boolean) to authenticated;

insert into public.event_templates(template_key, title, suitable_venue_types, default_reminders)
values
  ('watch-football', 'تماشای گروهی فوتبال', array['کافه','رستوران','هتل','باشگاه'], '["24h","3h","45m"]'::jsonb),
  ('yalda-night', 'شب یلدا', array['کافه','رستوران','هتل','بوم‌گردی','خانه'], '["7d","24h"]'::jsonb),
  ('kids-creative', 'کارگاه خلاق کودک', array['خانه بازی','شهربازی','مهدکودک','مرکز آموزشی'], '["24h","3h"]'::jsonb),
  ('memorial-anniversary', 'مراسم سالگرد یادبود', array['مسجد','تالار','خانه','مرکز فرهنگی'], '["7d","24h"]'::jsonb)
on conflict (template_key) do nothing;
