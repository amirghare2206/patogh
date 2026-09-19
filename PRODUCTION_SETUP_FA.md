# راه‌اندازی Production پاتوق v5

## چیزی که داخل این بسته آماده است

- ورود شماره موبایل و OTP
- پروفایل و علایق
- دیتابیس پاتوق‌ها
- رزرو، ظرفیت و لیست انتظار
- پرداخت با API قابل اتصال به درگاه انتخابی
- چت Realtime با Supabase
- ثبت توکن Push
- اعلان درون‌برنامه‌ای
- Matching بر اساس علایق
- داشبورد میزبان و ایجاد پاتوق
- ساخت Web / Android از یک کدبیس

## حالت Demo

بدون هیچ کلید یا سرویس خارجی کار می‌کند.

OTP آزمایشی: `1234`

```bash
bash install_v5.sh
```

## حالت Production

### 1. Supabase

یک Project بساز و فایل‌های زیر را در SQL Editor اجرا کن:

- `backend/supabase/schema.sql`
- `backend/supabase/seed.sql`

Phone Auth را در Supabase فعال کن و ارائه‌دهنده SMS موردنظرت را تنظیم کن.

### 2. پرداخت

Edge Functionهای نمونه داخل:

- `backend/supabase/functions/payment-create`
- `backend/supabase/functions/payment-verify`

هستند.

روی سرور این Secretها را تنظیم کن:

- `PAYMENT_PROVIDER_CREATE_URL`
- `PAYMENT_PROVIDER_VERIFY_URL`
- `PAYMENT_MERCHANT_ID`

Mapping پاسخ درگاه ممکن است با درگاه انتخابی تفاوت داشته باشد و همان دو فایل محل تنظیم آن هستند.

### 3. Push

Firebase Project بساز.

فایل:

`production_templates/firebase-messaging-sw.js`

را با مقادیر Firebase پر کن و به:

`web/firebase-messaging-sw.js`

کپی کن.

در GitHub Secrets مقادیر Firebase و FCM VAPID Key را ثبت کن.

### 4. GitHub Actions

فایل نمونه:

`production_templates/github_actions_production_example.yml`

را پس از ثبت Secretها به:

`.github/workflows/deploy-pages.yml`

تبدیل کن.

### 5. اجرای Production محلی/Build

```bash
flutter build web \
  --release \
  --base-href "/patogh/" \
  --no-web-resources-cdn \
  --dart-define=PATOGH_MODE=production \
  --dart-define=SUPABASE_URL="..." \
  --dart-define=SUPABASE_ANON_KEY="..." \
  --dart-define=PAYMENT_API_BASE_URL="..." \
  --dart-define=FIREBASE_API_KEY="..." \
  --dart-define=FIREBASE_APP_ID="..." \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="..." \
  --dart-define=FIREBASE_PROJECT_ID="..." \
  --dart-define=FCM_VAPID_KEY="..."
```

## Android

همین Flutter Project برای Android قابل استفاده است.

پس از اضافه کردن Firebase Android app و `google-services.json`:

```bash
flutter build appbundle --release
```

برای انتشار واقعی Android، keystore امضا و تنظیم Play Console هم لازم است.

## نکته امنیتی

- `SUPABASE_ANON_KEY` برای کلاینت طراحی شده و همراه RLS استفاده می‌شود.
- Service Role Key، Merchant Secret و Secretهای Push را هرگز داخل Flutter/Web قرار نده.
- Secretهای پرداخت و Push فقط در backend/Edge Function نگهداری شوند.
