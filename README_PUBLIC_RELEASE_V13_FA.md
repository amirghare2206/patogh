# پاتوق v13 — Public Release Android + iOS

این بسته Overlay نسخه عمومی پاتوق است و روی سورس فعلی پروژه اعمال می‌شود.

## تغییرات محصول

- هویت بصری جدید پاتوق با لوگوی رنگی تأییدشده.
- تم شادتر و برندمحور با نارنجی، فیروزه‌ای، بنفش و صورتی.
- استوری‌ها در صفحه اصلی بدون عبارت «مختص میزبان/برگزارکننده».
- بنرهای صفحه اصلی به کاروسل اسلایدی قابل Swipe تبدیل شده‌اند.
- پنج بنر آماده برند پاتوق داخل بسته قرار گرفته است.
- سرویس‌های پاتوق از صفحه اصلی حذف شده و به صفحه مستقل «سرویس‌های پاتوق» منتقل شده‌اند.
- تمام رویدادها محور اصلی Home هستند و فیلترهای همه/جدیدترین/رایگان/تخفیف/ظرفیت/دسته دارند.
- نوار پایین شرکت‌کننده به ۵ گزینه ثابت کاهش یافته تا پروفایل همیشه دیده شود.
- تعریف سربرگ رویداد امکان انتخاب لوگوی آماده، رنگ و Logo URL اختصاصی دارد.
- بنر جدید ادمین می‌تواند تصویر URL داشته باشد و در Backend ذخیره شود.
- Auth Fix نسخه Staging حفظ شده؛ در Production دیگر OTP آزمایشی 1234 به‌عنوان fallback فعال نمی‌شود.
- Android و iOS از یک Bundle ID/Package ID استفاده می‌کنند: `ir.patogh.app`.
- App Icon و Store Assets از لوگوی جدید تولید شده‌اند.
- CI عمومی Android برای APK/AAB امضاشده و CI عمومی iOS برای IPA امضاشده اضافه شده است.

## فایل‌های مهم

- `.github/workflows/build-public-android.yml`
- `.github/workflows/build-public-ios.yml`
- `backend/supabase/v13_public_release.sql`
- `tool/prepare_public_release.py`
- `tool/configure_public_platforms.py`
- `tool/public_release_preflight.py`
- `assets/branding/`
- `assets/banners/`
- `store_assets/`

## اعمال روی پروژه فعلی

پس از Extract کردن بسته روی ریشه Repo:

```bash
bash install_public_release_v13.sh
```

روی Linux/Codespaces، Android آماده می‌شود. iOS در GitHub Actions روی runner مک ساخته می‌شود.

## نکته مهم انتشار واقعی

این بسته «سورس و خط تولید انتشار» را آماده می‌کند. فایل نهایی قابل انتشار در فروشگاه فقط وقتی تولید می‌شود که Credentials واقعی Production و کلیدهای امضا در GitHub Secrets ثبت شده باشند. هیچ Secret داخل این بسته قرار نگرفته است.
