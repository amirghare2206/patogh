-- V14 onboarding profile extensions.
-- Apply to the STAGING project first. Do not run against Production during beta setup.

alter table public.profiles
  add column if not exists education text not null default '',
  add column if not exists marital_status text not null default '',
  add column if not exists has_children boolean,
  add column if not exists military_status text not null default '',
  add column if not exists personality_type text not null default '',
  add column if not exists leisure_style text not null default '',
  add column if not exists personality_tags text[] not null default '{}',
  add column if not exists personality_answers jsonb not null default '{}'::jsonb;

create index if not exists profiles_interests_gin_idx
  on public.profiles using gin (interests);
create index if not exists profiles_personality_tags_gin_idx
  on public.profiles using gin (personality_tags);
create index if not exists profiles_city_idx
  on public.profiles (city);

comment on column public.profiles.personality_type is
  'User-reported social preference summary; not a clinical or scientific diagnosis.';
comment on column public.profiles.personality_tags is
  'Tags derived from user-selected interests and onboarding preference answers.';

-- Enable realtime delivery for shared beta data where the table exists.
-- The block is idempotent and skips tables not installed in this environment.
do $$
declare
  table_name text;
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    foreach table_name in array array[
      'profiles', 'patogh_events', 'reservations', 'timeline_posts', 'user_blocks',
      'timeline_likes', 'timeline_post_media', 'timeline_comments',
      'timeline_saved_posts', 'timeline_shares', 'stories', 'story_media',
      'communities', 'community_members', 'chat_messages', 'notifications',
      'user_roles', 'role_requests'
    ] loop
      if to_regclass(format('public.%I', table_name)) is not null
         and not exists (
           select 1 from pg_publication_tables
           where pubname = 'supabase_realtime'
             and schemaname = 'public'
             and tablename = table_name
         ) then
        execute format('alter publication supabase_realtime add table public.%I', table_name);
      end if;
    end loop;
  end if;
end $$;

-- Return only profile fields that are appropriate for in-app discovery.
-- Contact details and optional sensitive onboarding answers are never exposed.
create or replace function public.list_suggested_profiles_v14(p_limit integer default 20)
returns setof jsonb
language sql
stable
security definer
set search_path = pg_catalog, public
as $function$
  with me as (
    select id, city, interests, personality_tags
    from public.profiles
    where id = auth.uid()
      and onboarding_completed = true
  ), candidates as (
    select
      p.id,
      p.name,
      p.city,
      case when p.show_age then p.age else null end as visible_age,
      p.show_age,
      p.allow_chat,
      p.interests,
      p.personality_type,
      p.leisure_style,
      p.personality_tags,
      me.city as viewer_city,
      array(
        select distinct pi
        from unnest(coalesce(p.interests, array[]::text[])) as pi
        where pi = any(coalesce(me.interests, array[]::text[]))
      ) as shared_interests,
      array(
        select distinct pt
        from unnest(coalesce(p.personality_tags, array[]::text[])) as pt
        where pt = any(coalesce(me.personality_tags, array[]::text[]))
      ) as shared_tags,
      p.updated_at
    from public.profiles p
    cross join me
    where p.id <> me.id
      and p.onboarding_completed = true
      and not exists (
        select 1 from public.user_blocks b
        where (b.blocker_id = me.id and b.blocked_id = p.id)
           or (b.blocker_id = p.id and b.blocked_id = me.id)
      )
  )
  select jsonb_build_object(
    'id', id,
    'name', name,
    'city', city,
    'age', visible_age,
    'show_age', show_age,
    'allow_chat', allow_chat,
    'interests', interests,
    'personality_type', personality_type,
    'leisure_style', leisure_style,
    'personality_tags', personality_tags,
    'shared_interests', shared_interests,
    'shared_tags', shared_tags
  )
  from candidates
  order by
    cardinality(shared_interests) + cardinality(shared_tags) desc,
    (city = viewer_city) desc,
    updated_at desc
  limit greatest(1, least(coalesce(p_limit, 20), 50));
$function$;

revoke all on function public.list_suggested_profiles_v14(integer) from public, anon;
grant execute on function public.list_suggested_profiles_v14(integer) to authenticated;
