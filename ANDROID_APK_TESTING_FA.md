# ساخت APK تستی پاتوق

این محیط خروجی APK را کامپایل نکرده است. Workflow آماده داخل پروژه بعد از Push در GitHub Actions APK می‌سازد.

## روش

1. فایل‌های این بسته را روی پروژه Merge کن.
2. `flutter analyze` و `flutter test` را در Codespaces اجرا کن.
3. Push به `main`.
4. GitHub > Actions > Build Android APK.
5. پس از سبز شدن Job، پایین صفحه بخش Artifacts را باز کن.
6. `patogh-v11-engagement-apk` را دانلود کن و ZIP Artifact را باز کن.
7. فایل `app-release.apk` را برای گوشی‌های تست ارسال کن.

این APK برای تست Sideload مناسب است؛ برای Play Store باید Keystore اختصاصی و App Bundle امضاشده بسازی.
