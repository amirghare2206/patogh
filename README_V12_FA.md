# Patogh v12 — Multi-user Market Release Candidate

نسخه v12 روی v11 Engagement ساخته شده و هدفش تبدیل Demo تک‌دستگاهی به یک Closed Beta چندکاربره واقعی است.

## اضافه‌های کلیدی

- Staging shared-backend با Supabase Anonymous Auth و OTP تست 1234
- Production mode با Phone OTP واقعی و بدون Demo OTP
- Timeline/Story/Community/Chat مشترک
- Chat realtime
- Media upload خصوصی و server-validated
- Post/Story: حداکثر 20 رسانه و ویدئو حداکثر 2 دقیقه
- Group/Channel: عکس/صوت بدون محدودیت تعدادی؛ Video حداکثر 10MiB
- Report/Block پایه
- حذف حساب
- Private signed media URL
- Admin multi-role از Backend
- Android package `ir.patogh.app`, target API 36
- Workflow جدا برای Staging APK و Signed Bazaar APK/AAB

شروع: `bash install_v12.sh`

برای تست چندکاربره: `docs/MULTIUSER_TEST_FA.md`
برای انتشار: `docs/BAZAAR_RELEASE_FA.md`
محدودیت‌های واقعی قبل از انتشار مالی: `RELEASE_BLOCKERS_FA.md`
