# معماری Production — Time, Occasion & Memorial

## جریان تقویم

Provider -> Normalizer -> calendar_sources/calendar_occasions -> Opportunity Engine -> Event Draft -> Host/Organizer/Admin

هیچ منبع حیاتی نباید مستقیماً در UI هاردکد شود.

## Opportunity Engine

ورودی‌ها:
- مناسبت
- Sports/Seasonal feed
- تقاضای کاربران
- ظرفیت خالی میزبان
- شهر/استان
- علایق و سگمنت کاربران
- داده تاریخی کیفیت و حضور

خروجی:
- Opportunity Score
- قالب رویداد
- میزبان‌های مناسب
- جمعیت پیشنهادی
- Draft رویداد

## Reminder Worker

personal_occasions + occasion_reminders -> Scheduler -> Push/SMS/In-app

هر Reminder باید idempotent باشد و تغییر زمان یک Event خارجی باید Scheduleهای آینده را اصلاح کند.

## Memorial

Memorial ایجاد می‌شود -> Verification -> Member ACL -> Entries/Media -> Anniversary Scheduler -> Event/Invitation/Golrizon.

دسترسی مموریال باید از عضویت و Visibility تبعیت کند و نه صرفاً Logged-in بودن.
