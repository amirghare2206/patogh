-- Patogh v10: paid private-event publishing + Surprise + Golrizon
-- Run after v9_final.sql.

-- -----------------------------------------------------------------------------
-- 1) Admin-controlled pricing for private invitations / publishing
-- -----------------------------------------------------------------------------
create table if not exists public.private_event_pricing_settings (
  id text primary key default 'default',
  base_publish_fee bigint not null default 300000,
  included_invites int not null default 20,
  extra_invite_fee bigint not null default 10000,
  sms_unit_fee bigint not null default 1500,
  boost_fee bigint not null default 250000,
  premium_template_fee bigint not null default 180000,
  currency text not null default 'IRT',
  updated_by uuid references auth.users(id) on delete set null,
  updated_at timestamptz not null default now()
);

insert into public.private_event_pricing_settings (id)
values ('default')
on conflict (id) do nothing;

create table if not exists public.private_event_publications (
  event_id text primary key references public.patogh_events(id) on delete cascade,
  host_user_id uuid not null references auth.users(id) on delete cascade,
  invite_count int not null default 0,
  sms_count int not null default 0,
  base_fee bigint not null default 0,
  extra_invite_cost bigint not null default 0,
  sms_cost bigint not null default 0,
  boost_cost bigint not null default 0,
  premium_template_cost bigint not null default 0,
  total_amount bigint not null default 0,
  payment_status text not null default 'unpaid'
    check (payment_status in ('unpaid','pending','paid','failed','refunded')),
  publication_status text not null default 'draft'
    check (publication_status in ('draft','ready','published','suspended')),
  boost_enabled boolean not null default false,
  premium_template_enabled boolean not null default false,
  payment_reference text,
  paid_at timestamptz,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.private_event_pricing_settings enable row level security;
alter table public.private_event_publications enable row level security;

create policy "private_event_pricing_read"
on public.private_event_pricing_settings for select
using (auth.role() = 'authenticated');

create policy "private_event_pricing_admin_write"
on public.private_event_pricing_settings for all
using (public.is_admin())
with check (public.is_admin());

create policy "private_event_publication_owner_read"
on public.private_event_publications for select
using (auth.uid() = host_user_id or public.is_admin());

-- Client can create/update the draft quote, but cannot mark it paid.
create policy "private_event_publication_owner_insert"
on public.private_event_publications for insert
with check (
  auth.uid() = host_user_id
  and payment_status in ('unpaid','pending')
  and publication_status in ('draft','ready')
);

create policy "private_event_publication_owner_update_unpaid"
on public.private_event_publications for update
using (auth.uid() = host_user_id or public.is_admin())
with check (
  public.is_admin()
  or (
    auth.uid() = host_user_id
    and payment_status in ('unpaid','pending')
    and publication_status in ('draft','ready')
  )
);

-- Payment verification + final publication must be performed by backend / Edge Function
-- with trusted server credentials. Do not accept client claims that a payment succeeded.

-- -----------------------------------------------------------------------------
-- 2) Surprise planning
-- -----------------------------------------------------------------------------
create table if not exists public.surprise_plans (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null references auth.users(id) on delete cascade,
  target_user_id uuid references auth.users(id) on delete set null,
  target_phone text,
  target_username text,
  title text not null,
  occasion text not null,
  reveal_at timestamptz,
  status text not null default 'planning'
    check (status in ('planning','inviting','ready','revealed','cancelled')),
  hidden_from_target boolean not null default true,
  linked_event_id text references public.patogh_events(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (
    target_user_id is not null
    or target_phone is not null
    or target_username is not null
  )
);

create table if not exists public.surprise_members (
  surprise_id uuid not null references public.surprise_plans(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  invitee_phone text,
  invitee_username text,
  member_role text not null default 'collaborator'
    check (member_role in ('cohost','collaborator','guest')),
  status text not null default 'invited'
    check (status in ('invited','accepted','declined')),
  created_at timestamptz not null default now(),
  primary key (surprise_id, user_id),
  check (
    user_id is not null
    or invitee_phone is not null
    or invitee_username is not null
  )
);

create table if not exists public.surprise_items (
  id uuid primary key default gen_random_uuid(),
  surprise_id uuid not null references public.surprise_plans(id) on delete cascade,
  author_id uuid not null references auth.users(id) on delete cascade,
  item_type text not null
    check (item_type in ('message','photo','video','audio','gift_idea','task')),
  body text,
  object_key text,
  completed boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.surprise_plans enable row level security;
alter table public.surprise_members enable row level security;
alter table public.surprise_items enable row level security;

create policy "surprise_creator_read_write"
on public.surprise_plans for all
using (auth.uid() = creator_id or public.is_admin())
with check (auth.uid() = creator_id or public.is_admin());

create policy "surprise_member_read"
on public.surprise_plans for select
using (
  exists (
    select 1 from public.surprise_members m
    where m.surprise_id = surprise_plans.id
      and m.user_id = auth.uid()
      and m.status = 'accepted'
  )
  or (
    target_user_id = auth.uid()
    and (status = 'revealed' or hidden_from_target = false)
  )
);

create policy "surprise_members_related"
on public.surprise_members for select
using (
  user_id = auth.uid()
  or exists (
    select 1 from public.surprise_plans s
    where s.id = surprise_members.surprise_id
      and s.creator_id = auth.uid()
  )
  or public.is_admin()
);

create policy "surprise_members_creator_insert"
on public.surprise_members for insert
with check (
  exists (
    select 1 from public.surprise_plans s
    where s.id = surprise_members.surprise_id
      and s.creator_id = auth.uid()
  )
  or public.is_admin()
);

create policy "surprise_items_member_read"
on public.surprise_items for select
using (
  author_id = auth.uid()
  or exists (
    select 1 from public.surprise_plans s
    where s.id = surprise_items.surprise_id
      and s.creator_id = auth.uid()
  )
  or exists (
    select 1 from public.surprise_members m
    where m.surprise_id = surprise_items.surprise_id
      and m.user_id = auth.uid()
      and m.status = 'accepted'
  )
  or exists (
    select 1 from public.surprise_plans s
    where s.id = surprise_items.surprise_id
      and s.target_user_id = auth.uid()
      and (s.status = 'revealed' or s.hidden_from_target = false)
  )
  or public.is_admin()
);

create policy "surprise_items_member_insert"
on public.surprise_items for insert
with check (
  auth.uid() = author_id
  and (
    exists (
      select 1 from public.surprise_plans s
      where s.id = surprise_items.surprise_id
        and s.creator_id = auth.uid()
    )
    or exists (
      select 1 from public.surprise_members m
      where m.surprise_id = surprise_items.surprise_id
        and m.user_id = auth.uid()
        and m.status = 'accepted'
    )
  )
);

-- -----------------------------------------------------------------------------
-- 3) Golrizon / transparent community fundraising
-- -----------------------------------------------------------------------------
create table if not exists public.golrizon_campaigns (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null references auth.users(id) on delete cascade,
  purpose text not null
    check (purpose in ('event_seat','charity','personal_help','community_cause')),
  title text not null,
  public_description text,
  beneficiary_user_id uuid references auth.users(id) on delete set null,
  beneficiary_display_name text,
  linked_event_id text references public.patogh_events(id) on delete set null,
  goal_amount bigint not null check (goal_amount > 0),
  raised_amount bigint not null default 0 check (raised_amount >= 0),
  currency text not null default 'IRT',
  deadline_at timestamptz,
  public_listing boolean not null default true,
  beneficiary_verified boolean not null default false,
  status text not null default 'pending_approval'
    check (status in ('pending_approval','active','funded','closed','rejected')),
  reviewed_by uuid references auth.users(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.golrizon_contributions (
  id uuid primary key default gen_random_uuid(),
  campaign_id uuid not null references public.golrizon_campaigns(id) on delete cascade,
  contributor_id uuid references auth.users(id) on delete set null,
  amount bigint not null check (amount > 0),
  anonymous boolean not null default false,
  payment_status text not null default 'pending'
    check (payment_status in ('pending','paid','failed','refunded')),
  payment_reference text,
  paid_at timestamptz,
  created_at timestamptz not null default now()
);

-- For event-seat campaigns, money is earmarked to the destination reservation.
-- For charity/personal/community campaigns, payout goes only to a verified destination.
create table if not exists public.golrizon_allocations (
  id uuid primary key default gen_random_uuid(),
  campaign_id uuid not null references public.golrizon_campaigns(id) on delete cascade,
  destination_type text not null
    check (destination_type in ('event_reservation','verified_beneficiary','verified_charity_partner')),
  destination_reference text not null,
  amount bigint not null check (amount > 0),
  status text not null default 'reserved'
    check (status in ('reserved','released','refunded')),
  released_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.golrizon_campaigns enable row level security;
alter table public.golrizon_contributions enable row level security;
alter table public.golrizon_allocations enable row level security;

create policy "golrizon_approved_public_read"
on public.golrizon_campaigns for select
using (
  creator_id = auth.uid()
  or public.is_admin()
  or (public_listing = true and status in ('active','funded','closed'))
);

create policy "golrizon_creator_insert"
on public.golrizon_campaigns for insert
with check (
  creator_id = auth.uid()
  and status = 'pending_approval'
  and beneficiary_verified = false
);

create policy "golrizon_creator_update_pending"
on public.golrizon_campaigns for update
using (creator_id = auth.uid() or public.is_admin())
with check (
  public.is_admin()
  or (
    creator_id = auth.uid()
    and status = 'pending_approval'
    and beneficiary_verified = false
  )
);

create policy "golrizon_contribution_self_read"
on public.golrizon_contributions for select
using (contributor_id = auth.uid() or public.is_admin());

-- No direct client INSERT policy is intentionally provided for paid contributions.
-- Create payment intent on the backend, verify the payment gateway callback, then insert
-- the paid contribution with trusted server credentials and atomically update raised_amount.

create policy "golrizon_allocations_admin_read"
on public.golrizon_allocations for select
using (public.is_admin());

-- Admin approval helper.
create or replace function public.review_golrizon_campaign(
  p_campaign_id uuid,
  p_approve boolean
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'ADMIN_REQUIRED';
  end if;

  update public.golrizon_campaigns
  set status = case when p_approve then 'active' else 'rejected' end,
      beneficiary_verified = p_approve,
      reviewed_by = auth.uid(),
      reviewed_at = now(),
      updated_at = now()
  where id = p_campaign_id
    and status = 'pending_approval';
end;
$$;

grant execute on function public.review_golrizon_campaign(uuid, boolean)
to authenticated;

-- -----------------------------------------------------------------------------
-- 4) Audit hints
-- -----------------------------------------------------------------------------
-- Production should log:
-- - publication pricing changes
-- - private-event payment verification and publication
-- - surprise membership/reveal changes
-- - Golrizon approval, payment verification, allocation, refund and payout
-- in public.audit_logs (introduced earlier).
