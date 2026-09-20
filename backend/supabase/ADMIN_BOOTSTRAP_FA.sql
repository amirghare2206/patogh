-- Patogh v12 - تعیین اولین ادمین Production
-- بعد از اولین ورود واقعی با OTP، شماره نمونه را با شماره خودت (+98...) جایگزین کن.
-- این دستور را فقط یک بار در SQL Editor اجرا کن.

do $$
declare
  v_phone text := '+989121234567'; -- حتماً تغییر بده
  v_user uuid;
begin
  select u.id into v_user
  from auth.users u
  where u.phone = v_phone
  order by u.created_at desc
  limit 1;

  if v_user is null then
    select p.id into v_user
    from public.profiles p
    where p.phone = v_phone
    order by p.updated_at desc nulls last, p.created_at desc nulls last
    limit 1;
  end if;

  if v_user is null then
    raise exception 'USER_NOT_FOUND_FOR_PHONE: %', v_phone;
  end if;

  insert into public.user_roles(user_id, role, status, approved_at)
  values(v_user, 'admin', 'active', now())
  on conflict(user_id,role)
  do update set status='active', approved_at=now();

  update public.profiles
  set role='admin', updated_at=now()
  where id=v_user;
end $$;
