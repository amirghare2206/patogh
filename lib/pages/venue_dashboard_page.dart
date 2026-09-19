import 'package:flutter/material.dart';
import 'package:patogh/theme/patogh_theme.dart';

class VenueDashboardPage extends StatelessWidget {
  const VenueDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      ('رویدادهای میزبانی‌شده', '۴', Icons.event_available_rounded),
      ('درخواست‌های میزبانی', '۳', Icons.inbox_rounded),
      ('ظرفیت این هفته', '۶۸٪', Icons.pie_chart_rounded),
      ('امتیاز میزبان', '۴.۸', Icons.star_rounded),
    ];
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'پنل کسب‌وکار میزبان',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'مدیریت فضای میزبانی، درخواست‌ها و عملکرد رویدادها',
            style: TextStyle(color: Color(0xFFAAAAAA)),
          ),
          const SizedBox(height: 18),
          ...items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(item.$3, color: PatoghTheme.orange),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item.$1)),
                  Text(
                    item.$2,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: PatoghTheme.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'درخواست‌های جدید',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          const _RequestCard(
            title: 'قرار شام پاتوق',
            subtitle: 'پنجشنبه • ۸ نفر • ۱۹ تا ۲۱',
          ),
          const _RequestCard(
            title: 'پاتوق گفت‌وگو',
            subtitle: 'شنبه • ۶ نفر • ۱۸ تا ۲۰',
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const _RequestCard({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.store_mall_directory_rounded,
            color: PatoghTheme.orange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(onPressed: () {}, child: const Text('بررسی')),
        ],
      ),
    );
  }
}
