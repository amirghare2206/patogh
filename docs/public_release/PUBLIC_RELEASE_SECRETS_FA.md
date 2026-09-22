# Secrets لازم برای نسخه عمومی

## مشترک

- `PROD_SUPABASE_URL`
- `PROD_SUPABASE_ANON_KEY` — فقط کلید Publishable/Anon؛ Service Role هرگز داخل اپ قرار نگیرد.
- `PAYMENT_API_BASE_URL` — اگر رویداد پولی فعال است.
- `FIREBASE_API_KEY`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_AUTH_DOMAIN`
- `FIREBASE_STORAGE_BUCKET`

## Android

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_STORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `FIREBASE_APP_ID`

## iOS

- `IOS_CERTIFICATE_P12_BASE64`
- `IOS_CERTIFICATE_PASSWORD`
- `IOS_PROVISION_PROFILE_BASE64`
- `IOS_KEYCHAIN_PASSWORD`
- `APPLE_TEAM_ID`
- `FIREBASE_IOS_APP_ID`

برای Upload خودکار به App Store Connect در مرحله بعد می‌توان API Key اپل را هم اضافه کرد؛ Workflow فعلی IPA امضاشده تولید می‌کند و آن را به‌عنوان Artifact تحویل می‌دهد.
