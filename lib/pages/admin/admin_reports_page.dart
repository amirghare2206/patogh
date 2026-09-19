import 'package:flutter/material.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = const [
      ('نرخ پرشدن ظرفیت', 0.82, '۸۲٪'),
      ('تبدیل بازدید به رزرو', 0.46, '۴۶٪'),
      ('نرخ حضور واقعی', 0.91, '۹۱٪'),
      ('رضایت تأییدشده', 0.88, '۴.۶ از ۵'),
      ('بازگشت کاربران', 0.67, '۶۷٪'),
      ('همخوانی ادعا با تجربه', 0.90, '۹۰٪'),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'گزارشات و تحلیل',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'عملکرد مالی، تقاضا، کیفیت، حضور و کمپین‌های پاتوق',
            style: TextStyle(color: Color(0xFFAAAAAA)),
          ),
          const SizedBox(height: 18),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.55,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _metricCard('درآمد ماه', '۱۲۸.۴ م', Icons.payments_rounded),
              _metricCard(
                'تقاضای رویداد',
                '${appState.eventRequests.length}',
                Icons.add_task_rounded,
              ),
              _metricCard(
                'کمپین فعال',
                '${appState.discountCampaigns.where((item) => item.status == 'فعال').length}',
                Icons.discount_rounded,
              ),
              _metricCard(
                'اسپانسر فعال',
                '${appState.sponsorships.length}',
                Icons.volunteer_activism_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...metrics.map(
            (metric) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(metric.$1)),
                      Text(
                        metric.$3,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: metric.$2,
                    minHeight: 9,
                    borderRadius: BorderRadius.circular(20),
                    backgroundColor: const Color(0xFF2A2A2A),
                    color: PatoghTheme.orange,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _insight(
            'تقاضای پاسخ‌داده‌نشده',
            'پاتوق موسیقی، کودک و تیم‌سازی در نمونه داده‌ها بیشترین پتانسیل تبدیل به رویداد را دارند.',
          ),
          _insight(
            'کیفیت موجودیت‌ها',
            'موتور اعتبار می‌تواند افت امتیاز میزبان/آژانس، شکاف ادعا و تجربه، No-show و روند ماهانه را برای ادمین برجسته کند.',
          ),
          _insight(
            'اسپانسرینگ',
            'دعوت کاربران برتر باید مرحله‌ای باشد و وقتی ظرفیت واقعی تکمیل شد، ارسال دعوت جدید متوقف شود.',
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: PatoghTheme.orange),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF999999), fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _insight(String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 10,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
