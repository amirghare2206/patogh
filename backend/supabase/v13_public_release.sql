-- Patogh v13 public release migration
-- Run after release_bootstrap_v12.sql on the production Supabase project.

alter table public.categories
  add column if not exists logo_url text;

comment on column public.categories.logo_url is
  'Optional HTTPS image URL used as the category/header logo. Falls back to icon_code_point.';

-- Keep production role reads explicit for the current user and administrators.
drop policy if exists roles_self_read on public.user_roles;
create policy roles_self_read on public.user_roles
for select using (auth.uid() = user_id or public.is_admin());

-- A category logo URL is metadata only; existing admin write policy remains authoritative.

-- Banner placement rows are read together with active banners.
drop policy if exists banner_placements_read on public.banner_placements;
create policy banner_placements_read on public.banner_placements
for select using (
  public.is_admin()
  or exists (
    select 1 from public.banners b
    where b.id = banner_placements.banner_id and b.active = true
  )
);

drop policy if exists banner_placements_admin_write on public.banner_placements;
create policy banner_placements_admin_write on public.banner_placements
for all using (public.is_admin()) with check (public.is_admin());
