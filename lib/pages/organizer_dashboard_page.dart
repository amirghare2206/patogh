import 'package:flutter/material.dart';
import 'package:patogh/pages/create_event_page.dart';
import 'package:patogh/theme/patogh_theme.dart';

class OrganizerDashboardPage extends StatelessWidget {
  const OrganizerDashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    final metrics = const [
      ('رویدادهای فعال', '۶'),
      ('رزرو این ماه', '۱۳۲'),
      ('فروش', '۲۸.۴ م'),
      ('میانگین رضایت', '۴.۷'),
    ];
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'پنل برگزارکننده / آژانس',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
                ),
              ),
              IconButton.filled(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateEventPage()),
                ),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'ساخت و ارائه رویدادها در دسته‌بندی‌های پاتوق',
            style: TextStyle(color: Color(0xFFAAAAAA)),
          ),
          const SizedBox(height: 18),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: metrics
                .map(
                  (metric) => Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181818),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          metric.$2,
                          style: const TextStyle(
                            color: PatoghTheme.orange,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          metric.$1,
                          style: const TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          const Text(
            'وضعیت رویدادها',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          const _Status(
            title: 'پاتوق سفر آخر هفته',
            status: 'در انتظار تأیید ادمین',
            color: Color(0xFFFFC36B),
          ),
          const _Status(
            title: 'کارگاه خلاقیت تصویری',
            status: 'منتشر شده',
            color: Color(0xFF7BE0A8),
          ),
        ],
      ),
    );
  }
}

class _Status extends StatelessWidget {
  final String title;
  final String status;
  final Color color;
  const _Status({
    required this.title,
    required this.status,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF181818),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        const Icon(Icons.event_rounded, color: PatoghTheme.orange),
        const SizedBox(width: 10),
        Expanded(child: Text(title)),
        Text(
          status,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
