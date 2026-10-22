-- Profile photos for V14.
-- Apply to the STAGING Supabase project first. Do not run on Production during QA.
-- Images are public profile media; authenticated users can only write under their own user-id folder.

alter table public.profiles
  add column if not exists avatar_url text;

insert into storage.buckets (
  id, name, public, file_size_limit, allowed_mime_types
)
values (
  'profile-avatars',
  'profile-avatars',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']::text[]
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'profile_avatars_public_read'
  ) then
    execute 'create policy profile_avatars_public_read on storage.objects for select to public using (bucket_id = ''profile-avatars'')';
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'profile_avatars_owner_insert'
  ) then
    execute 'create policy profile_avatars_owner_insert on storage.objects for insert to authenticated with check (bucket_id = ''profile-avatars'' and (storage.foldername(name))[1] = auth.uid()::text)';
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'profile_avatars_owner_update'
  ) then
    execute 'create policy profile_avatars_owner_update on storage.objects for update to authenticated using (bucket_id = ''profile-avatars'' and (storage.foldername(name))[1] = auth.uid()::text) with check (bucket_id = ''profile-avatars'' and (storage.foldername(name))[1] = auth.uid()::text)';
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'profile_avatars_owner_delete'
  ) then
    execute 'create policy profile_avatars_owner_delete on storage.objects for delete to authenticated using (bucket_id = ''profile-avatars'' and (storage.foldername(name))[1] = auth.uid()::text)';
  end if;
end $$;


-- Include the uploaded avatar in safe profile suggestions for other users.
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
      p.avatar_url,
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
    'avatar_url', avatar_url,
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
