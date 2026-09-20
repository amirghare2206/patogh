# چک‌لیست تست Patogh v12 — Multi-user Market RC

## A) تست ساخت
- `bash install_v12.sh`
- `flutter analyze` -> بدون Issue
- `flutter test` -> همه تست‌ها Pass
- Web build -> موفق

## B) Backend تازه
- `release_bootstrap_v12.sql` روی Supabase تازه اجرا شده
- در Staging فایل `STAGING_SEED_V12.sql` اجرا شده
- Anonymous Sign-ins فقط برای Staging فعال است
- Edge Functionهای `validate-media`, `get-media-url`, `delete-account` Deploy شده‌اند
- Storage bucketهای `pending-media` و `social-media` Private هستند

## C) تست چندکاربره 4 گوشی
1. هر چهار گوشی با شماره متفاوت + کد Staging `1234` وارد شوند.
2. هر چهار نفر پروفایل واقعی خود را تکمیل کنند.
3. گوشی A رویداد `breakfast-01` را رزرو کند.
4. گوشی B همان رویداد را رزرو کند؛ ظرفیت روی Refresh تغییر کند.
5. A و B وارد Chat همان Event شوند و پیام دوطرفه Realtime ببینند.
6. A یک Timeline post بگذارد؛ B Pull-to-refresh و Like کند.
7. B یک Group بسازد؛ A Join کند و هر دو پیام بفرستند.
8. C درخواست نقش Organizer بدهد.
9. D پس از اجرای `ADMIN_BOOTSTRAP_STAGING_FA.sql` درخواست C را تأیید کند.
10. C logout/login کند و پنل Organizer برایش فعال شود.

## D) تست Media Policy
- Post با 20 عکس -> مجاز
- افزودن رسانه 21ام -> رد
- Story با 20 عکس/ویدئو -> مجاز
- Post/Story video با مدت <=120s -> مجاز
- Post/Story video >120s -> Backend Reject
- Group/Channel: چند عکس و چند فایل صوتی -> بدون سقف تعدادی محصولی
- Group/Channel video <=10MiB -> مجاز
- Group/Channel video >10MiB -> Backend Reject
- کاربر غیرعضو نتواند signed URL رسانه Chat خصوصی را دریافت کند

## E) امنیت/حریم خصوصی
- Report post/message کار کند
- Block user ثبت شود
- Delete Account از Privacy کار کند
- Admin Demo در Staging/Production نمایش داده نشود
- نقش حرفه‌ای بدون Admin approval Remote فعال نشود
- کاربر جدید قبل از تکمیل پروفایل و پذیرش Terms وارد RootShell نشود

## F) Production Smoke Test قبل از بازار
- Production OTP واقعی (بدون 1234)
- Keystore Release واقعی
- Privacy/Terms با اطلاعات واقعی کسب‌وکار
- Payment واقعی + verify callback
- Push Production
- Test account deletion
- Test low-value payment + cancel/refund policy
- Report/moderation process انسانی

تا وقتی بخش F کامل نشده، APK را Closed Beta نگه دار.
