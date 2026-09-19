import 'package:flutter/material.dart';
import 'package:patogh/theme/patogh_theme.dart';

class CoordinatorDashboardPage extends StatefulWidget {
  const CoordinatorDashboardPage({super.key});
  @override
  State<CoordinatorDashboardPage> createState() =>
      _CoordinatorDashboardPageState();
}

class _CoordinatorDashboardPageState extends State<CoordinatorDashboardPage> {
  final attendees = <String, bool>{
    'سارا': true,
    'امیر': true,
    'آتنا': false,
    'کیان': false,
  };
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'پنل مدیر و هماهنگ‌کننده',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'هماهنگی بین شرکت‌کننده‌ها، میزبان و برگزارکننده',
            style: TextStyle(color: Color(0xFFAAAAAA)),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF181818),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'قرار شام پاتوق',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 5),
                Text(
                  'امروز • ساعت ۱۹ • کافه روشن',
                  style: TextStyle(color: Color(0xFFAAAAAA)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'چک‌این شرکت‌کننده‌ها',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          ...attendees.entries.map(
            (entry) => CheckboxListTile(
              value: entry.value,
              onChanged: (value) =>
                  setState(() => attendees[entry.key] = value ?? false),
              title: Text(entry.key),
              secondary: const Icon(
                Icons.person_rounded,
                color: PatoghTheme.orange,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.notifications_active_rounded),
            label: const Text('ارسال پیام هماهنگی به همه'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.storefront_rounded),
            label: const Text('تماس با میزبان'),
          ),
        ],
      ),
    );
  }
}
