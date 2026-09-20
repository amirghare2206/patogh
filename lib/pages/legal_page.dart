import 'package:flutter/material.dart';

class LegalPage extends StatelessWidget {
  final String title;
  final String body;
  const LegalPage({super.key, required this.title, required this.body});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_forward_rounded),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [Text(body, style: const TextStyle(height: 1.9))],
    ),
  );
  static const privacy =
      '''حریم خصوصی پاتوق\n\nپاتوق فقط داده‌هایی را که برای ارائه سرویس لازم است پردازش می‌کند. موقعیت مکانی مسیر فقط با اقدام صریح کاربر فعال می‌شود. محتوای خصوصی، حلقه، گروه و رویداد مطابق سطح دسترسی کاربر نمایش داده می‌شود. کاربران می‌توانند گزارش تخلف ثبت کنند و درخواست حذف حساب بدهند.\n\nبرای نسخه Production، نشانی حقوقی، اطلاعات تماس مسئول حریم خصوصی، مدت نگهداری دقیق داده‌ها و ارائه‌دهندگان پردازش باید با اطلاعات واقعی کسب‌وکار تکمیل شود.''';
  static const terms =
      '''شرایط استفاده پاتوق\n\nکاربر مسئول صحت اطلاعاتی است که ثبت می‌کند و نباید محتوای غیرقانونی، آزاردهنده یا ناقض حقوق دیگران منتشر کند. رزرو، لغو، No-show، پرداخت، گل‌ریزون و دعوت‌نامه‌ها تابع شرایطی هستند که پیش از تأیید نهایی نمایش داده می‌شوند. دسترسی حرفه‌ای میزبان، برگزارکننده و هماهنگ‌کننده می‌تواند نیازمند تأیید باشد.''';
  static const community =
      '''قواعد جامعه پاتوق\n\nاحترام، رضایت، حریم خصوصی و امنیت اعضا اصل است. آزار، تهدید، جعل هویت، انتشار اطلاعات خصوصی دیگران، محتوای سوءاستفاده‌گرانه و اسپم مجاز نیست. گزارش‌ها بررسی می‌شوند و حساب یا محتوای متخلف می‌تواند محدود یا حذف شود.''';
}
