do $$
declare
  v_phone text := '+989121234567';
  v_user uuid;
begin
  select u.id into v_user
  from auth.users u
  where u.raw_user_meta_data->>'tester_phone' = v_phone
     or u.phone = v_phone
  order by u.created_at desc
  limit 1;

  if v_user is null then
    raise exception 'STAGING_USER_NOT_FOUND_FOR_PHONE: %', v_phone;
  end if;

  insert into public.user_roles(user_id, role, status, approved_at)
  values(v_user, 'admin', 'active', now())
  on conflict(user_id, role)
  do update
    set status = 'active',
        approved_at = now();

  update public.profiles
  set phone = v_phone,
      updated_at = now()
  where id = v_user;
end $$;