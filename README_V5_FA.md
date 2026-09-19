# Patogh v5 Full Stack

این نسخه یک بسته کامل یک‌باره است.

## شامل

1. ورود/OTP
2. پروفایل
3. دیتابیس آنلاین + Demo fallback
4. رزرو/ظرفیت/لیست انتظار
5. پرداخت
6. چت Realtime
7. Push-ready notifications
8. Matching
9. داشبورد میزبان + ساخت پاتوق
10. Web/Android-ready

به‌علاوه صفحات قبلی:
تقویم، آرشیو، مدال‌ها، حریم خصوصی، کیفیت گروه، بازی‌ها و علاقه‌مندی‌ها.

## نصب روی پروژه فعلی

محتویات این ZIP را روی ریشه پروژه `patogh` Merge کن.
پوشه `lib` و `test` را Replace کن، ولی `.github` فعلی را فعلاً نگه دار.

سپس:

```bash
bash install_v5.sh
```

اگر Demo سالم بود:

```bash
git add .
git commit -m "Upgrade Patogh to full-stack v5"
git push origin main
```

برای Production واقعی فایل `PRODUCTION_SETUP_FA.md` را دنبال کن.
