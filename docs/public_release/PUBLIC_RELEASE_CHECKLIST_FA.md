# چک‌لیست قبل از انتشار عمومی پاتوق

## P0 — حتماً قبل از انتشار

- [ ] پروژه Supabase Production جدا از Staging ساخته شده است.
- [ ] `release_bootstrap_v12.sql` و سپس `v13_public_release.sql` روی Production اجرا شده‌اند.
- [ ] SMS/OTP واقعی Supabase برای شماره‌های ایران تنظیم و روی حداقل دو اپراتور تست شده است.
- [ ] هیچ OTP آزمایشی یا Anonymous Auth در Production فعال نیست.
- [ ] دامنه و Callback پرداخت واقعی تنظیم شده و Verify سمت سرور تست شده است؛ یا رویدادهای پولی تا زمان آماده شدن درگاه غیرفعال هستند.
- [ ] حذف حساب از داخل اپ تا حذف Auth User و داده‌های وابسته تست شده است.
- [ ] شرایط استفاده، حریم خصوصی، نام مالک محصول، ایمیل/تلفن پشتیبانی و URL سیاست حریم خصوصی با اطلاعات واقعی تکمیل شده‌اند.
- [ ] Android Keystore نهایی تولید و در محل امن بکاپ شده است.
- [ ] Apple Developer Program، Bundle ID `ir.patogh.app`، Distribution Certificate و App Store Provisioning Profile آماده‌اند.
- [ ] App Store Privacy و Google Play Data Safety بر اساس داده‌های واقعی اپ تکمیل شده‌اند.

## P1 — تست انتشار

- [ ] `flutter analyze` بدون خطا.
- [ ] `flutter test` همه Passed.
- [ ] ثبت‌نام، ورود، خروج و ورود مجدد روی Android و iPhone واقعی.
- [ ] نقش‌ها: participant / venue / coordinator / organizer / admin.
- [ ] رزرو همزمان دو کاربر و ظرفیت واقعی.
- [ ] پرداخت موفق/ناموفق/لغو شده و Verify callback.
- [ ] استوری، تایم‌لاین، گروه، عکس، ویدیو و محدودیت رسانه.
- [ ] بنرها روی Home و Timeline و بنر Remote ادمین.
- [ ] ایجاد سربرگ جدید با لوگوی آماده و Logo URL.
- [ ] اعلان Push روی Android و iOS واقعی.
- [ ] مسیر حذف حساب.
- [ ] رفتار بدون اینترنت، Timeout و Retry.

## خروجی مورد انتظار

Android:
- `app-release.aab` برای فروشگاه
- `app-release.apk` برای تست/فروشگاه‌هایی که APK می‌پذیرند
- Symbols obfuscation

iOS:
- `*.ipa` امضاشده App Store
- Symbols obfuscation
