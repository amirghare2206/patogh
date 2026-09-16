import 'package:flutter/material.dart';
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
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('داشبورد میزبان'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Row(
            children: [
              _metric('ظرفیت', '۱۸ / ۲۰'),
              _metric('اعتماد گروه', '۹۱٪'),
            ],
          ),
          const SizedBox(height: 12),
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
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MatchingPage()));
            },
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Matching پیشنهادی اعضا'),
          ),
        ],
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
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
