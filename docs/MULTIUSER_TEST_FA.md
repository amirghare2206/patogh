# تست چندکاربره واقعی پاتوق v12

v12 برای Closed Beta روی چند گوشی با **یک Backend مشترک Supabase** آماده شده است.

## حالت‌ها

- `PATOGH_MODE=demo`: داده محلی؛ مناسب نمایش UI.
- `PATOGH_MODE=staging`: Backend مشترک؛ هر گوشی با کد تست `1234` یک User واقعی و مستقل Supabase می‌گیرد.
- `PATOGH_MODE=production`: کد `1234` وجود ندارد؛ Phone OTP واقعی لازم است.

> Staging Anonymous User بعد از Logout یا پاک کردن داده برنامه قابل بازیابی نیست. برای Beta محدود مناسب است، نه حساب Production.

## راه‌اندازی Staging از صفر

1. یک Supabase Project **مجزا برای Staging** بساز.
2. SQL Editor را باز کن و `backend/supabase/release_bootstrap_v12.sql` را اجرا کن.
3. سپس `backend/supabase/STAGING_SEED_V12.sql` را اجرا کن تا Eventهای تست با ظرفیت واقعی صفرشده ساخته شوند.
4. Auth Settings -> Anonymous Sign-ins را فقط در Staging فعال کن.
5. Supabase CLI را Link کن و Functionها را Deploy کن:
   - `validate-media`
   - `get-media-url`
   - `delete-account`
6. در GitHub -> Settings -> Secrets and variables -> Actions:
   - `STAGING_SUPABASE_URL`
   - `STAGING_SUPABASE_ANON_KEY` (publishable key)
7. GitHub -> Actions -> **Build Multi-user Staging APK** -> Run workflow.
8. Artifact `patogh-v12-multiuser-staging-apk` را دانلود کن و همان APK را روی چند گوشی نصب کن.
9. هر نفر شماره خودش را وارد کند؛ کد Staging برابر `1234` است.
10. هر نفر در اولین ورود Profile Setup و پذیرش Terms را کامل کند.

## تعیین ادمین Staging

بعد از اینکه خودت یک بار در APK Staging وارد شدی، فایل:

`backend/supabase/ADMIN_BOOTSTRAP_STAGING_FA.sql`

را باز کن، شماره نمونه را با شماره خودت به شکل `+989...` عوض کن و در SQL Editor اجرا کن. سپس برنامه را logout/login کن. از آن به بعد Role `admin` از Backend می‌آید؛ Admin Demo در Staging غیرفعال است.

## چه چیزهایی واقعاً بین گوشی‌ها مشترک است؟

- Auth/Profile و نقش‌های تأییدشده
- Event/Reservation/Capacity/Waitlist
- Categories/Favorites
- Timeline + Like
- Story
- Group/Channel + Membership
- Event/Community Chat Realtime
- Media خصوصی با Signed URL
- Role Request/Admin approval
- Report/Block پایه

ماژول‌های بسیار جدیدتر مثل برخی Opportunityهای تقویمی، بخش‌هایی از Gamification، Surprise/Golrizon و بعضی Analytics هنوز در تمام مسیرها Remote نشده‌اند. این موارد در `RELEASE_BLOCKERS_FA.md` مشخص شده‌اند.

## تست 4 نفره پیشنهادی

- A و B: یک Event مشترک رزرو و Chat را تست کنند.
- A: Post با عکس/ویدئو بگذارد؛ B آن را ببیند/Like کند.
- C: نقش Organizer درخواست کند.
- D: ادمین Backend باشد و C را تأیید کند.
- همه: یک Group بسازند/Join کنند و Chat/Media را تست کنند.

برای موارد کامل، `V12_TEST_CHECKLIST_FA.md` را اجرا کن.
