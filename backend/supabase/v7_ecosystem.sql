-- Patogh v7 ecosystem extension
-- Run AFTER schema.sql and v6_roles_social.sql
-- Covers: venue taxonomy, audience rules, guardians/dependents, reputation,
-- event demand, group booking, venue menu/orders, campaigns/banners,
-- organizations B2B/B2E, sponsorship, attendance/no-show/debt.

create extension if not exists pgcrypto;

-- ------------------------------------------------------------------
-- Venue taxonomy and capabilities
-- ------------------------------------------------------------------
create table if not exists public.venue_types (
  id text primary key,
  title text not null,
  group_title text not null,
  family_friendly boolean not null default false,
  child_friendly boolean not null default false,
  is_active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

alter table public.venues
  add column if not exists venue_type_id text references public.venue_types(id),
  add column if not exists amenities text[] not null default '{}',
  add column if not exists min_capacity int not null default 1,
  add column if not exists max_capacity int not null default 1,
  add column if not exists corporate_catering boolean not null default false,
  add column if not exists child_safe boolean not null default false,
  add column if not exists accessibility jsonb not null default '{}'::jsonb;

-- ------------------------------------------------------------------
-- Event scope / audience / attendance policy
-- ------------------------------------------------------------------
alter table public.patogh_events
  add column if not exists geographic_level text not null default 'city'
    check (geographic_level in ('local','city','regional','national')),
  add column if not exists geographic_label text,
  add column if not exists min_age int not null default 18,
  add column if not exists max_age int not null default 99,
  add column if not exists gender_policy text not null default 'open'
    check (gender_policy in ('open','women','men','family','custom')),
  add column if not exists attendance_mode text not null default 'adult',
  add column if not exists booking_mode text not null default 'individual_or_group'
    check (booking_mode in ('individual','group','individual_or_group')),
  add column if not exists access_type text not null default 'public'
    check (access_type in ('public','invite','sponsored','corporate','private')),
  add column if not exists no_show_penalty bigint not null default 0,
  add column if not exists late_cancel_penalty bigint not null default 0,
  add column if not exists cancellation_deadline_minutes int not null default 720;

-- ------------------------------------------------------------------
-- Guardians and dependent participants
-- ------------------------------------------------------------------
create table if not exists public.dependents (
  id uuid primary key default gen_random_uuid(),
  guardian_user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  birth_date date,
  age int,
  relation text not null default 'child',
  notes jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.dependent_pickup_people (
  id uuid primary key default gen_random_uuid(),
  dependent_id uuid not null references public.dependents(id) on delete cascade,
  guardian_user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  relation text,
  phone text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------------
-- Reputation, claims and verified feedback
-- ------------------------------------------------------------------
create table if not exists public.reputation_entities (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null
    check (entity_type in ('participant','venue','coordinator','organizer','event','community','sponsor')),
  entity_ref text not null,
  overall_score numeric(4,2) not null default 0,
  verified_reviews int not null default 0,
  confidence_score int not null default 0,
  claim_match_score int not null default 0,
  attendance_score int,
  updated_at timestamptz not null default now(),
  unique(entity_type, entity_ref)
);

create table if not exists public.entity_claims (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null,
  entity_ref text not null,
  claim_key text not null,
  claim_text text not null,
  claimed_value jsonb not null default '{}'::jsonb,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.feedback_reviews (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references public.patogh_events(id) on delete cascade,
  reviewer_user_id uuid not null references auth.users(id) on delete cascade,
  target_type text not null
    check (target_type in ('participant','venue','coordinator','organizer','event','sponsor')),
  target_ref text not null,
  overall_score numeric(3,2) not null check (overall_score between 1 and 5),
  dimensions jsonb not null default '{}'::jsonb,
  public_comment text,
  positive_note text,
  improvement_note text,
  verified_attendance boolean not null default false,
  created_at timestamptz not null default now(),
  unique(event_id, reviewer_user_id, target_type, target_ref)
);

create table if not exists public.reputation_snapshots (
  id bigint generated by default as identity primary key,
  entity_type text not null,
  entity_ref text not null,
  overall_score numeric(4,2) not null,
  confidence_score int not null,
  claim_match_score int not null,
  snapshot_date date not null default current_date,
  metrics jsonb not null default '{}'::jsonb
);

-- ------------------------------------------------------------------
-- User demand / requested events
-- ------------------------------------------------------------------
create table if not exists public.event_requests (
  id uuid primary key default gen_random_uuid(),
  requester_user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  category_id text,
  city text,
  geographic_level text not null default 'city',
  min_age int,
  max_age int,
  preferred_date_range jsonb not null default '{}'::jsonb,
  budget_range jsonb not null default '{}'::jsonb,
  description text,
  status text not null default 'pending'
    check (status in ('pending','reviewing','matched','converted','rejected')),
  converted_event_id text references public.patogh_events(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.event_request_supporters (
  request_id uuid not null references public.event_requests(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(request_id, user_id)
);

-- ------------------------------------------------------------------
-- Group booking with real members
-- ------------------------------------------------------------------
create table if not exists public.booking_groups (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references public.patogh_events(id) on delete cascade,
  leader_user_id uuid not null references auth.users(id) on delete cascade,
  title text,
  payment_mode text not null default 'individual'
    check (payment_mode in ('individual','leader')),
  hold_expires_at timestamptz,
  status text not null default 'forming'
    check (status in ('forming','confirmed','expired','cancelled')),
  created_at timestamptz not null default now()
);

create table if not exists public.booking_group_members (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.booking_groups(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  dependent_id uuid references public.dependents(id) on delete cascade,
  invited_by uuid references auth.users(id),
  status text not null default 'invited'
    check (status in ('invited','accepted','declined','paid','confirmed','cancelled')),
  created_at timestamptz not null default now(),
  check ((user_id is not null) <> (dependent_id is not null))
);

alter table public.reservations
  add column if not exists booking_group_id uuid references public.booking_groups(id) on delete set null,
  add column if not exists participant_user_id uuid references auth.users(id) on delete set null,
  add column if not exists dependent_id uuid references public.dependents(id) on delete set null;

-- ------------------------------------------------------------------
-- Venue menu and event pre-orders
-- ------------------------------------------------------------------
create table if not exists public.venue_menu_categories (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid not null references public.venues(id) on delete cascade,
  title text not null,
  sort_order int not null default 0,
  active boolean not null default true
);

create table if not exists public.venue_menu_items (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid not null references public.venues(id) on delete cascade,
  category_id uuid references public.venue_menu_categories(id) on delete set null,
  title text not null,
  description text,
  price bigint not null check (price >= 0),
  stock_limit int,
  preparation_minutes int,
  image_url text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.event_orders (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references public.patogh_events(id) on delete cascade,
  reservation_id uuid references public.reservations(id) on delete set null,
  buyer_user_id uuid not null references auth.users(id) on delete cascade,
  participant_user_id uuid references auth.users(id),
  dependent_id uuid references public.dependents(id),
  total_amount bigint not null default 0,
  status text not null default 'pending'
    check (status in ('pending','paid','preparing','ready','delivered','cancelled','refunded')),
  created_at timestamptz not null default now()
);

create table if not exists public.event_order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.event_orders(id) on delete cascade,
  menu_item_id uuid not null references public.venue_menu_items(id),
  quantity int not null check (quantity > 0),
  unit_price bigint not null,
  note text
);

-- ------------------------------------------------------------------
-- Growth: campaigns, promo codes, banners
-- ------------------------------------------------------------------
create table if not exists public.campaigns (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  campaign_type text not null default 'discount',
  audience_rules jsonb not null default '{}'::jsonb,
  start_at timestamptz,
  end_at timestamptz,
  active boolean not null default true,
  budget bigint,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.discount_codes (
  id uuid primary key default gen_random_uuid(),
  campaign_id uuid references public.campaigns(id) on delete cascade,
  code text not null unique,
  discount_type text not null check (discount_type in ('percent','fixed')),
  value bigint not null,
  max_discount bigint,
  min_purchase bigint,
  per_user_limit int not null default 1,
  total_limit int,
  used_count int not null default 0,
  rules jsonb not null default '{}'::jsonb,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.discount_usages (
  id uuid primary key default gen_random_uuid(),
  discount_code_id uuid not null references public.discount_codes(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  event_id text references public.patogh_events(id),
  order_id uuid references public.event_orders(id),
  discount_amount bigint not null,
  created_at timestamptz not null default now()
);

create table if not exists public.banners (
  id uuid primary key default gen_random_uuid(),
  campaign_id uuid references public.campaigns(id) on delete set null,
  title text not null,
  subtitle text,
  media_url text,
  action_label text,
  action_type text,
  action_target text,
  sponsored boolean not null default false,
  sponsor_name text,
  audience_rules jsonb not null default '{}'::jsonb,
  start_at timestamptz,
  end_at timestamptz,
  priority int not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.banner_placements (
  banner_id uuid not null references public.banners(id) on delete cascade,
  placement text not null,
  primary key(banner_id, placement)
);

create table if not exists public.banner_events (
  id bigint generated by default as identity primary key,
  banner_id uuid not null references public.banners(id) on delete cascade,
  user_id uuid references auth.users(id),
  event_type text not null check (event_type in ('impression','click','conversion')),
  context jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------------
-- Organizations: B2B / B2E
-- ------------------------------------------------------------------
create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  organization_type text not null default 'company',
  registration_no text,
  city text,
  verified boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.organization_members (
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'employee'
    check (role in ('owner','hr','finance','manager','employee')),
  active boolean not null default true,
  joined_at timestamptz not null default now(),
  primary key(organization_id, user_id)
);

create table if not exists public.organization_budgets (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  title text not null,
  period_start date,
  period_end date,
  total_amount bigint not null default 0,
  used_amount bigint not null default 0,
  rules jsonb not null default '{}'::jsonb
);

create table if not exists public.employee_credits (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  budget_id uuid references public.organization_budgets(id) on delete set null,
  granted_amount bigint not null default 0,
  used_amount bigint not null default 0,
  expires_at timestamptz,
  rules jsonb not null default '{}'::jsonb
);

create table if not exists public.corporate_packages (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid references public.venues(id) on delete cascade,
  organizer_id uuid references public.organizers(id) on delete cascade,
  title text not null,
  min_people int not null default 1,
  max_people int,
  price_model jsonb not null default '{}'::jsonb,
  catering jsonb not null default '{}'::jsonb,
  amenities text[] not null default '{}',
  active boolean not null default true
);

create table if not exists public.corporate_requests (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  created_by uuid not null references auth.users(id),
  title text not null,
  event_type text,
  city text,
  people_count int not null,
  budget bigint,
  preferred_date timestamptz,
  catering_required boolean not null default false,
  private_space boolean not null default false,
  requirements jsonb not null default '{}'::jsonb,
  status text not null default 'open'
    check (status in ('open','collecting','selected','completed','cancelled')),
  created_at timestamptz not null default now()
);

create table if not exists public.corporate_proposals (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.corporate_requests(id) on delete cascade,
  proposer_type text not null check (proposer_type in ('venue','organizer')),
  proposer_ref uuid not null,
  total_price bigint not null,
  proposal jsonb not null default '{}'::jsonb,
  status text not null default 'submitted'
    check (status in ('submitted','shortlisted','accepted','rejected')),
  created_at timestamptz not null default now()
);

create table if not exists public.organization_invoices (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  corporate_request_id uuid references public.corporate_requests(id),
  amount bigint not null,
  status text not null default 'draft'
    check (status in ('draft','issued','paid','cancelled','refunded')),
  invoice_data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------------
-- Sponsorship and invitation engine
-- ------------------------------------------------------------------
create table if not exists public.sponsors (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid references auth.users(id) on delete set null,
  organization_id uuid references public.organizations(id) on delete set null,
  sponsor_type text not null check (sponsor_type in ('person','company','organization','factory','brand','charity')),
  display_name text not null,
  verified boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.event_sponsorships (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references public.patogh_events(id) on delete cascade,
  sponsor_id uuid not null references public.sponsors(id) on delete cascade,
  purpose text not null,
  coverage_type text not null default 'full'
    check (coverage_type in ('full','partial','seat_based','catering_only')),
  sponsored_amount bigint,
  seat_unit_cost bigint,
  audience_rules jsonb not null default '{}'::jsonb,
  disclosure_text text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.sponsored_invitations (
  id uuid primary key default gen_random_uuid(),
  sponsorship_id uuid not null references public.event_sponsorships(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  score int,
  invitation_batch int not null default 1,
  status text not null default 'sent'
    check (status in ('sent','viewed','accepted','declined','expired','stopped_capacity_full')),
  sent_at timestamptz not null default now(),
  responded_at timestamptz,
  unique(sponsorship_id, user_id)
);

-- ------------------------------------------------------------------
-- Attendance, check-in, no-show, debts and appeals
-- ------------------------------------------------------------------
create table if not exists public.attendance_records (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references public.patogh_events(id) on delete cascade,
  reservation_id uuid references public.reservations(id) on delete set null,
  user_id uuid references auth.users(id) on delete cascade,
  dependent_id uuid references public.dependents(id) on delete cascade,
  status text not null default 'expected'
    check (status in ('expected','checked_in','attended','cancelled_on_time','cancelled_late','no_show','excused')),
  checked_in_at timestamptz,
  checked_out_at timestamptz,
  verified_by uuid references auth.users(id),
  verification_method text,
  note text,
  created_at timestamptz not null default now()
);

create table if not exists public.user_debts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  event_id text references public.patogh_events(id) on delete set null,
  debt_type text not null check (debt_type in ('no_show','late_cancel','damage','other')),
  principal_amount bigint not null default 0,
  penalty_amount bigint not null default 0,
  total_amount bigint generated always as (principal_amount + penalty_amount) stored,
  status text not null default 'open'
    check (status in ('open','paid','waived','appealed')),
  created_at timestamptz not null default now(),
  settled_at timestamptz
);

create table if not exists public.attendance_appeals (
  id uuid primary key default gen_random_uuid(),
  attendance_id uuid not null references public.attendance_records(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  reason text not null,
  evidence jsonb not null default '{}'::jsonb,
  status text not null default 'open'
    check (status in ('open','reviewing','approved','rejected')),
  reviewed_by uuid references auth.users(id),
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------------
-- RLS
-- ------------------------------------------------------------------
alter table public.venue_types enable row level security;
alter table public.dependents enable row level security;
alter table public.dependent_pickup_people enable row level security;
alter table public.reputation_entities enable row level security;
alter table public.entity_claims enable row level security;
alter table public.feedback_reviews enable row level security;
alter table public.reputation_snapshots enable row level security;
alter table public.event_requests enable row level security;
alter table public.event_request_supporters enable row level security;
alter table public.booking_groups enable row level security;
alter table public.booking_group_members enable row level security;
alter table public.venue_menu_categories enable row level security;
alter table public.venue_menu_items enable row level security;
alter table public.event_orders enable row level security;
alter table public.event_order_items enable row level security;
alter table public.campaigns enable row level security;
alter table public.discount_codes enable row level security;
alter table public.discount_usages enable row level security;
alter table public.banners enable row level security;
alter table public.banner_placements enable row level security;
alter table public.banner_events enable row level security;
alter table public.organizations enable row level security;
alter table public.organization_members enable row level security;
alter table public.organization_budgets enable row level security;
alter table public.employee_credits enable row level security;
alter table public.corporate_packages enable row level security;
alter table public.corporate_requests enable row level security;
alter table public.corporate_proposals enable row level security;
alter table public.organization_invoices enable row level security;
alter table public.sponsors enable row level security;
alter table public.event_sponsorships enable row level security;
alter table public.sponsored_invitations enable row level security;
alter table public.attendance_records enable row level security;
alter table public.user_debts enable row level security;
alter table public.attendance_appeals enable row level security;

-- Public/catalog read rules.
drop policy if exists "venue_types_read" on public.venue_types;
create policy "venue_types_read" on public.venue_types for select using (is_active = true or public.is_admin());

drop policy if exists "reputation_read" on public.reputation_entities;
create policy "reputation_read" on public.reputation_entities for select using (true);

drop policy if exists "claims_read" on public.entity_claims;
create policy "claims_read" on public.entity_claims for select using (active = true or public.is_admin());

drop policy if exists "verified_feedback_read" on public.feedback_reviews;
create policy "verified_feedback_read" on public.feedback_reviews for select using (verified_attendance = true or reviewer_user_id = auth.uid() or public.is_admin());

drop policy if exists "menu_read" on public.venue_menu_items;
create policy "menu_read" on public.venue_menu_items for select using (active = true or public.is_admin());

drop policy if exists "banners_read" on public.banners;
create policy "banners_read" on public.banners for select using (active = true or public.is_admin());

drop policy if exists "campaign_read" on public.campaigns;
create policy "campaign_read" on public.campaigns for select using (active = true or public.is_admin());

drop policy if exists "sponsorship_read" on public.event_sponsorships;
create policy "sponsorship_read" on public.event_sponsorships for select using (active = true or public.is_admin());

-- Self-service rules.
drop policy if exists "dependents_guardian_all" on public.dependents;
create policy "dependents_guardian_all" on public.dependents for all using (guardian_user_id = auth.uid()) with check (guardian_user_id = auth.uid());

drop policy if exists "pickup_guardian_all" on public.dependent_pickup_people;
create policy "pickup_guardian_all" on public.dependent_pickup_people for all using (guardian_user_id = auth.uid()) with check (guardian_user_id = auth.uid());

drop policy if exists "event_requests_self" on public.event_requests;
create policy "event_requests_self" on public.event_requests for all using (requester_user_id = auth.uid() or public.is_admin()) with check (requester_user_id = auth.uid() or public.is_admin());

drop policy if exists "event_request_support_self" on public.event_request_supporters;
create policy "event_request_support_self" on public.event_request_supporters for all using (user_id = auth.uid() or public.is_admin()) with check (user_id = auth.uid());

drop policy if exists "feedback_insert_self" on public.feedback_reviews;
create policy "feedback_insert_self" on public.feedback_reviews for insert with check (reviewer_user_id = auth.uid());

drop policy if exists "feedback_update_self" on public.feedback_reviews;
create policy "feedback_update_self" on public.feedback_reviews for update using (reviewer_user_id = auth.uid());

drop policy if exists "group_leader_read" on public.booking_groups;
create policy "group_leader_read" on public.booking_groups for select using (leader_user_id = auth.uid() or public.is_admin());

drop policy if exists "group_leader_write" on public.booking_groups;
create policy "group_leader_write" on public.booking_groups for all using (leader_user_id = auth.uid() or public.is_admin()) with check (leader_user_id = auth.uid());

drop policy if exists "group_member_read" on public.booking_group_members;
create policy "group_member_read" on public.booking_group_members for select using (user_id = auth.uid() or invited_by = auth.uid() or public.is_admin());

drop policy if exists "orders_buyer" on public.event_orders;
create policy "orders_buyer" on public.event_orders for all using (buyer_user_id = auth.uid() or public.is_admin()) with check (buyer_user_id = auth.uid());

drop policy if exists "discount_usage_self" on public.discount_usages;
create policy "discount_usage_self" on public.discount_usages for select using (user_id = auth.uid() or public.is_admin());

drop policy if exists "sponsored_invites_self" on public.sponsored_invitations;
create policy "sponsored_invites_self" on public.sponsored_invitations for select using (user_id = auth.uid() or public.is_admin());

drop policy if exists "attendance_self" on public.attendance_records;
create policy "attendance_self" on public.attendance_records for select using (user_id = auth.uid() or public.is_admin());

drop policy if exists "debts_self" on public.user_debts;
create policy "debts_self" on public.user_debts for select using (user_id = auth.uid() or public.is_admin());

drop policy if exists "appeals_self" on public.attendance_appeals;
create policy "appeals_self" on public.attendance_appeals for all using (user_id = auth.uid() or public.is_admin()) with check (user_id = auth.uid());

-- ------------------------------------------------------------------
-- Admin management rules (write)
-- ------------------------------------------------------------------
drop policy if exists "venue_types_admin_write" on public.venue_types;
create policy "venue_types_admin_write" on public.venue_types for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "campaign_admin_write" on public.campaigns;
create policy "campaign_admin_write" on public.campaigns for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "discount_admin_write" on public.discount_codes;
create policy "discount_admin_write" on public.discount_codes for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "banner_admin_write" on public.banners;
create policy "banner_admin_write" on public.banners for all using (public.is_admin()) with check (public.is_admin());

-- ------------------------------------------------------------------
-- Seed venue types
-- ------------------------------------------------------------------
insert into public.venue_types (id, title, group_title, family_friendly, child_friendly, sort_order)
values
  ('cafe','کافه','خوراک و پذیرایی',true,false,1),
  ('restaurant','رستوران','خوراک و پذیرایی',true,false,2),
  ('hotel','هتل / هتل‌آپارتمان','اقامت و پذیرایی',true,false,3),
  ('ecolodge','بوم‌گردی','گردشگری',true,true,4),
  ('mosque','مسجد / فضای مذهبی','مذهبی و اجتماعی',true,false,5),
  ('amusement','شهربازی','تفریح و سرگرمی',true,true,6),
  ('playhouse','خانه بازی کودک','کودک',true,true,7),
  ('kindergarten','مهدکودک','کودک و آموزش',true,true,8),
  ('gameclub','کلوپ بازی / گیم‌کلاب','تفریح و سرگرمی',false,false,9),
  ('escape','اتاق فرار','تفریح و سرگرمی',false,false,10),
  ('sports','باشگاه / مجموعه ورزشی','ورزش',false,false,11),
  ('cowork','فضای کار اشتراکی','کسب‌وکار',false,false,12),
  ('education','مرکز آموزشی','آموزش',false,true,13),
  ('artworkshop','کارگاه هنری','هنر و خلاقیت',true,true,14),
  ('historic','خانه تاریخی / موزه','میراث و گردشگری',true,true,15),
  ('conference','مرکز همایش / سالن','رویداد و سازمانی',false,false,16)
on conflict (id) do update
set title = excluded.title,
    group_title = excluded.group_title,
    family_friendly = excluded.family_friendly,
    child_friendly = excluded.child_friendly,
    sort_order = excluded.sort_order;

-- ------------------------------------------------------------------
-- Capacity-safe sponsor invitation helper.
-- Call this from a scheduled backend worker; it refuses to invite once full.
-- ------------------------------------------------------------------
create or replace function public.can_invite_for_sponsorship(p_sponsorship_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_event text;
  v_capacity int;
  v_registered int;
begin
  select es.event_id, pe.capacity
    into v_event, v_capacity
  from public.event_sponsorships es
  join public.patogh_events pe on pe.id = es.event_id
  where es.id = p_sponsorship_id
    and es.active = true;

  if v_event is null then
    return false;
  end if;

  select count(*)
    into v_registered
  from public.reservations r
  where r.event_id = v_event
    and r.status in ('reserved','confirmed');

  return v_registered < v_capacity;
end;
$$;

grant execute on function public.can_invite_for_sponsorship(uuid) to authenticated;

-- ------------------------------------------------------------------
-- Booking block when user has open debt.
-- Production reserve RPC should call this before reserving.
-- ------------------------------------------------------------------
create or replace function public.user_has_open_debt(p_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.user_debts d
    where d.user_id = p_user_id
      and d.status in ('open','appealed')
      and d.total_amount > 0
  );
$$;

grant execute on function public.user_has_open_debt(uuid) to authenticated;

-- Replace reserve_event with debt-aware version.
create or replace function public.reserve_event(
  p_event_id text,
  p_waitlist_only boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_capacity int;
  v_reserved int;
  v_status text;
begin
  if v_user is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  if public.user_has_open_debt(v_user) then
    raise exception 'OPEN_DEBT_BLOCKS_BOOKING';
  end if;

  select capacity
  into v_capacity
  from public.patogh_events
  where id = p_event_id
  for update;

  if v_capacity is null then
    raise exception 'EVENT_NOT_FOUND';
  end if;

  select count(*)
  into v_reserved
  from public.reservations
  where event_id = p_event_id
    and status in ('reserved','confirmed');

  if p_waitlist_only or v_reserved >= v_capacity then
    v_status := 'waitlist';
  else
    v_status := 'reserved';
  end if;

  insert into public.reservations (user_id, event_id, status)
  values (v_user, p_event_id, v_status)
  on conflict (user_id, event_id)
  do update set status = excluded.status;

  update public.patogh_events
  set reserved_count = (
    select count(*)
    from public.reservations
    where event_id = p_event_id
      and status in ('reserved','confirmed')
  )
  where id = p_event_id;

  return jsonb_build_object('status', v_status);
end;
$$;

grant execute on function public.reserve_event(text, boolean) to authenticated;

-- Admin/coordinator backend action for confirmed no-show.
create or replace function public.apply_no_show_penalty(
  p_attendance_id uuid,
  p_principal_amount bigint,
  p_penalty_amount bigint
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid;
  v_event text;
  v_debt uuid;
begin
  if not public.is_admin() then
    raise exception 'ADMIN_REQUIRED';
  end if;

  select user_id, event_id
    into v_user, v_event
  from public.attendance_records
  where id = p_attendance_id
  for update;

  if v_user is null then
    raise exception 'ATTENDANCE_USER_REQUIRED';
  end if;

  update public.attendance_records
  set status = 'no_show',
      verified_by = auth.uid(),
      verification_method = 'admin_review'
  where id = p_attendance_id;

  insert into public.user_debts (
    user_id, event_id, debt_type, principal_amount, penalty_amount
  )
  values (
    v_user, v_event, 'no_show', greatest(p_principal_amount, 0), greatest(p_penalty_amount, 0)
  )
  returning id into v_debt;

  insert into public.audit_logs (
    actor_id, action, entity_type, entity_id, payload
  ) values (
    auth.uid(),
    'apply_no_show_penalty',
    'attendance',
    p_attendance_id::text,
    jsonb_build_object('debt_id', v_debt, 'user_id', v_user)
  );

  return v_debt;
end;
$$;

grant execute on function public.apply_no_show_penalty(uuid, bigint, bigint) to authenticated;
