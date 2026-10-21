import 'package:flutter/material.dart';
import 'package:patogh/models/user_role.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

/// A persistent, low-friction help entry available across app routes.
/// The guide deliberately describes only supported workflows and warns where
/// an operation may require a role or an active connection.
class PageHelpButton extends StatelessWidget {
  const PageHelpButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PatoghTheme.purple,
      shape: const CircleBorder(),
      elevation: 5,
      child: IconButton(
        tooltip: 'راهنمای پاتوق',
        onPressed: () => _showGuide(context),
        icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
      ),
    );
  }

  void _showGuide(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PatoghTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) => SafeArea(
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (context, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PatoghTheme.muted.withAlpha(100),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'راهنمای پاتوق',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'نقش فعلی شما: ${appState.role.label}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: PatoghTheme.muted),
              ),
              const SizedBox(height: 16),
              const _HelpSection(
                icon: Icons.home_rounded,
                title: 'خانه و ۱۲ دسته پاتوق',
                body: 'از شبکه دسته‌ها وارد فضای موردعلاقه‌ات شو. هر دسته می‌تواند رویدادهای مرتبط خودش را نشان بدهد. بنرهای بالای خانه مسیر دسترسی به سرویس‌های معرفی‌شده‌اند.',
              ),
              const _HelpSection(
                icon: Icons.person_rounded,
                title: 'ثبت‌نام و پروفایل',
                body: 'اطلاعات پایه و علایقت را کامل کن. اطلاعات اختیاری را فقط در صورت تمایل وارد کن و حریم خصوصی و امکان گفت‌وگو را از تنظیمات پروفایل بررسی کن.',
              ),
              const _HelpSection(
                icon: Icons.grid_view_rounded,
                title: '۱۲ دسته پاتوق',
                body: 'همراهی: قرارهای دوستانه و همراهی در فعالیت‌ها. داوطلبانه: کارهای اجتماعی و کمک داوطلبانه. همدلی: جمع‌های حمایتگر و شنیدن بدون قضاوت. قصه: کتاب، داستان و تجربه‌گویی. ورزشی: ورزش و فعالیت گروهی. فکری: گفت‌وگوی موضوعی و ایده‌پردازی. کاری: شبکه‌سازی و همکاری حرفه‌ای. آموزشی: کارگاه و یادگیری. سفر: گردش شهری و طبیعت. آشنایی: گسترش دایره آشنایی با رعایت رضایت و حریم خصوصی. گفت‌وگو: گپ‌های صمیمی و موضوعی. بازی: سرگرمی و بازی گروهی. برای دیدن برنامه‌های هر دسته، کارت همان دسته را لمس کن؛ اگر خالی بود یعنی فعلاً رویداد منتشرشده‌ای برای آن وجود ندارد.',
              ),
              const _HelpSection(
                icon: Icons.tune_rounded,
                title: 'علایق و پرسش‌نامه اجتماعی',
                body: 'حداقل سه علاقه انتخاب کن و به همه سؤال‌های ترجیحات پاسخ بده. پاسخ‌ها برای پیشنهاد علایق و جمع‌های مشترک استفاده می‌شوند؛ نتیجه، تشخیص روان‌شناختی یا درصد علمی سازگاری نیست. می‌توانی اطلاعات اختیاری را خالی بگذاری و بعداً از پروفایل اصلاح کنی.',
              ),
              const _HelpSection(
                icon: Icons.people_alt_rounded,
                title: 'پیشنهاد هم‌پاتوقی',
                body: 'پیشنهادها براساس علایق و تگ‌های مشترک و در صورت امکان شهر مرتب می‌شوند. فقط اطلاعاتی نمایش داده می‌شود که برای کشف اجتماعی مجاز است. اگر هنوز کاربر دیگری پروفایلش را کامل نکرده یا سرور در دسترس نیست، فهرست می‌تواند خالی بماند.',
              ),
              const _HelpSection(
                icon: Icons.event_available_rounded,
                title: 'رویداد و رزرو',
                body: 'جزئیات رویداد، زمان، مکان، قیمت و ظرفیت را پیش از رزرو بخوان. ثبت درخواست در محیط آزمایشی لزوماً به معنی پرداخت یا تأیید نهایی نیست؛ وضعیت رزرو را در برنامه بررسی کن.',
              ),
              const _HelpSection(
                icon: Icons.dynamic_feed_rounded,
                title: 'تایم‌لاین و استوری',
                body: 'در تایم‌لاین می‌توانی پست‌ها و رسانه‌ها را ببینی. امکاناتی مانند کامنت، ذخیره و اشتراک‌گذاری فقط وقتی قابل اتکا هستند که برای همان نسخه فعال و اتصال سرور برقرار باشد.',
              ),
              const _HelpSection(
                icon: Icons.forum_rounded,
                title: 'چت، گروه و کانال',
                body: 'وارد گفت‌وگوها و کامیونیتی‌هایی شو که به آن‌ها دسترسی داری. قوانین گروه و مجوزهای نقش را رعایت کن و اطلاعات حساس را در جمع عمومی منتشر نکن.',
              ),
              const _HelpSection(
                icon: Icons.sports_esports_rounded,
                title: 'بازی‌ها',
                body: 'از بخش بازی‌ها نوع بازی را انتخاب کن. پیش از دعوت دوستان، مطمئن شو قابلیت اتاق آنلاین در نسخه‌ای که نصب کرده‌ای فعال است؛ نمایش لابی به‌تنهایی اثبات اتصال چندنفره نیست.',
              ),
              const _HelpSection(
                icon: Icons.admin_panel_settings_rounded,
                title: 'پنل نقش‌ها',
                body: 'امکانات میزبان، هماهنگ‌کننده، برگزارکننده و ادمین با شرکت‌کننده متفاوت است. نقش حرفه‌ای باید از طرف سامانه مجاز شده باشد؛ انتخاب ظاهری نقش به‌تنهایی مجوز سروری ایجاد نمی‌کند.',
              ),
              const _HelpSection(
                icon: Icons.storefront_rounded,
                title: 'میزبان، برگزارکننده و هماهنگ‌کننده',
                body: 'میزبان اطلاعات مکان و ظرفیت را مدیریت می‌کند؛ برگزارکننده برنامه و جزئیات رویداد را آماده می‌کند؛ هماهنگ‌کننده عملیات و وضعیت‌های مجاز رویداد را پیگیری می‌کند. هر تغییری باید با دکمه ذخیره ثبت و نتیجه سرور بررسی شود. در بتای آزمایشی فقط از داده‌های Staging استفاده کن و نقش حرفه‌ای را با تغییر محلی یا دستکاری درخواست دور نزن.',
              ),
              const _HelpSection(
                icon: Icons.groups_rounded,
                title: 'تست گروهی ۱۰ نفره',
                body: 'هر آزمایشگر باید از حساب/شماره آزمایشی یکتا و دستگاه خودش استفاده کند. پس از ثبت هر رویداد، رزرو، پست یا عضویت، از یک حساب دیگر بررسی کن که تغییر در سرور ثبت شده و برای کاربر مجاز دیده می‌شود. تست را با یک کاربر عادی، یک نقش مجاز و یک کاربر بدون دسترسی انجام بده؛ خطاها، زمان و شناسه اجرا را ثبت کن. هرگز از اطلاعات واقعی یا کلیدهای Production برای آزمایش استفاده نکن.',
              ),
              const _HelpSection(
                icon: Icons.wifi_rounded,
                title: 'اگر چیزی کار نکرد',
                body: 'اتصال اینترنت را بررسی کن، پیام خطا را نگه دار و دوباره تلاش کن. اگر خطا تکرار شد، متن خطا و نام بخشی را که در آن بودی برای پشتیبانی بفرست.',
              ),
              if (appState.role != UserRole.participant)
                const _HelpSection(
                  icon: Icons.dashboard_customize_rounded,
                  title: 'نکته نقش حرفه‌ای',
                  body: 'پیش از ثبت یا ویرایش داده، نقش فعال و محدوده دسترسی خود را بررسی کن. در بتای آزمایشی، همه عملیات مدیریتی باید روی داده Staging انجام شوند.',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _HelpSection({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: PatoghTheme.surface2,
      margin: const EdgeInsets.only(bottom: 9),
      child: ExpansionTile(
        leading: Icon(icon, color: PatoghTheme.teal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [Text(body, style: const TextStyle(height: 1.75))],
      ),
    );
  }
}
