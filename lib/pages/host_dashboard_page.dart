import 'package:flutter/material.dart';
import 'package:patogh/pages/create_event_page.dart';
import 'package:patogh/pages/group_quality_page.dart';
import 'package:patogh/pages/matching_page.dart';
import 'package:patogh/theme/patogh_theme.dart';

class HostDashboardPage extends StatelessWidget {
  const HostDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = const [
      ('درخواست‌های جدید', '۵', Icons.person_add_alt_1_rounded),
      ('لیست انتظار', '۸', Icons.hourglass_bottom_rounded),
      ('وضعیت پرداخت‌ها', '۱۷/۲۰', Icons.payments_rounded),
      ('پیام‌های جدید', '۱۲', Icons.chat_rounded),
      ('هشدارهای سیستم', '۲', Icons.warning_amber_rounded),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('داشبورد میزبان'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              Row(
                children: [
                  _metric('ظرفیت', '۱۸ / ۲۰'),
                  _metric('زمان باقی‌مانده', '۲ روز'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _metric('اعتماد گروه', '۹۱٪'),
                  _metric('وضعیت', 'آماده اجرا'),
                ],
              ),
              const SizedBox(height: 18),
              ...cards.map(
                (card) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(18),
                    child: ListTile(
                      leading: Icon(card.$3, color: PatoghTheme.orange),
                      title: Text(card.$1),
                      trailing: Text(
                        card.$2,
                        style: const TextStyle(
                          color: PatoghTheme.orange,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GroupQualityPage()),
                  );
                },
                icon: const Icon(Icons.insights_rounded),
                label: const Text('تحلیل کیفیت گروه'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MatchingPage()),
                  );
                },
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('پیشنهاد هوشمند اعضا'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateEventPage()),
                  );
                },
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text('ساخت پاتوق جدید'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
