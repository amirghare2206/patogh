# چک‌لیست انتشار Android پاتوق v12

## خروجی Android

- Application ID: `ir.patogh.app`
- Version پایه: `1.0.0+1`
- Release APK و AAB از Workflow: **Build Bazaar Market Release**
- Keystore باید توسط مالک محصول ساخته و برای تمام Updateهای آینده نگهداری شود.

## GitHub Secrets لازم

### Android signing
- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_STORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`

### Backend
- `PROD_SUPABASE_URL`
- `PROD_SUPABASE_ANON_KEY` (publishable key client-side)
- `PAYMENT_API_BASE_URL`

### Push در صورت فعال بودن
- `FIREBASE_API_KEY`
- `FIREBASE_APP_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_AUTH_DOMAIN`
- `FIREBASE_STORAGE_BUCKET`

## Backend Production از صفر

1. یک Supabase Production Project مستقل بساز.
2. `backend/supabase/release_bootstrap_v12.sql` را در SQL Editor اجرا کن.
3. Demo/Staging seed را روی Production اجرا نکن.
4. Phone Auth واقعی را فعال کن.
5. Edge Functionهای authenticated را Deploy کن:
   - `validate-media`
   - `get-media-url`
   - `delete-account`
6. اگر Send SMS Hook استفاده می‌کنی، `send-sms-hook` باید بدون platform JWT verification Deploy شود و داخل خودش Standard Webhooks signature را verify کند. Script `tool/deploy_supabase_v12.sh` همین کار را انجام می‌دهد.
7. بعد از اولین ورود واقعی خودت، `backend/supabase/ADMIN_BOOTSTRAP_FA.sql` را با شماره واقعی خودت اجرا کن.

## Fail-closed مالی

در Production اگر Payment API تنظیم نشده باشد، رزرو پولی به حالت Demo سقوط نمی‌کند و غیرفعال می‌شود. پرداخت آزمایشی گل‌ریزون و انتشار دعوت‌نامه خصوصی نیز در Production عمداً غیرفعال است تا زمانی که مسیر تسویه/Verify واقعی آن ماژول متصل شود.

## قبل از ارسال به مارکت

- OTP واقعی روی حداقل دو اپراتور تست شود.
- Privacy/Terms Placeholder با متن و اطلاعات واقعی کسب‌وکار جایگزین شود.
- حذف حساب از داخل اپ تست شود.
- Report/Block و فرایند انسانی Moderation آماده باشد.
- Payment create/verify/cancel/refund تست واقعی شود.
- Push production تست شود.
- Backup/restore دیتابیس و Storage تست شود.
- Crash monitoring/alerting فعال شود.
- یک Closed Beta چندروزه با چند گوشی انجام شود و Crash/UX blockerها رفع شوند.

برای موارد باقی‌مانده `RELEASE_BLOCKERS_FA.md` را ببین.
