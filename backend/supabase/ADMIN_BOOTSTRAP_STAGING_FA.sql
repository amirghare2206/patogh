-- Patogh v12 - تعیین اولین ادمین در Staging چندکاربره
-- 1) ابتدا روی گوشی خودت با شماره‌ات و کد 1234 وارد Staging شو.
-- 2) شماره نمونه زیر را با همان شماره‌ای که داخل برنامه وارد کردی، با فرمت +98 جایگزین کن.
-- 3) این بلوک را یک بار در Supabase SQL Editor اجرا کن.
-- 4) برنامه را کامل ببند/باز کن یا logout/login کن تا نقش‌های Remote دوباره خوانده شوند.

do $$
declare
  v_phone text := '+989121234567'; -- حتماً تغییر بده
  v_user uuid;
begin
  select p.id into v_user
  from public.profiles p
  where p.phone = v_phone
  order by p.updated_at desc nulls last, p.created_at desc nulls last
  limit 1;

  if v_user is null then
    raise exception 'STAGING_USER_NOT_FOUND_FOR_PHONE: %', v_phone;
  end if;

  insert into public.user_roles(user_id, role, status, approved_at)
  values(v_user, 'admin', 'active', now())
  on conflict(user_id, role)
  do update set status='active', approved_at=now();

  update public.profiles
  set role='admin', updated_at=now()
  where id=v_user;
end $$;
