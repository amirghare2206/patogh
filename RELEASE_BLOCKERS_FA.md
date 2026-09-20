# مواردی که بدون اطلاعات بیرونی نمی‌توان داخل سورس «خودکار» نهایی کرد

این بسته Release Candidate است، اما برای انتشار تجاری واقعی این موارد نیازمند اطلاعات/حساب تو هستند:

1. **SMS Provider واقعی**: API Key/خط خدماتی و تنظیم Send SMS Hook.
2. **درگاه پرداخت واقعی**: Merchant ID/Secret و Verify callback.
3. **Keystore نهایی Android**: باید توسط مالک محصول تولید و امن نگهداری شود.
4. **اطلاعات حقوقی**: نام شرکت/شخص، آدرس، پشتیبانی و متن حقوقی نهایی.
5. **Push Provider**: Firebase/جایگزین و Credentials واقعی.
6. **تسویه گل‌ریزون/اسپانسر/B2B**: قوانین مالی، KYC و قراردادهای واقعی.
7. بعضی ماژول‌های پیشرفته v8-v11 هنوز UI/Schema گسترده دارند ولی همه عملیاتشان به Remote API Production متصل نشده‌اند؛ Core multi-user (Auth/Profile/Event/Reservation/Social/Community/Media) در v12 Remote شده است.

تا زمانی که 1 تا 6 تکمیل نشده، نسخه را Closed Beta بدان؛ نه نسخه مالی عمومی.
