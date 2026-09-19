import 'package:flutter/material.dart';
import 'package:patogh/theme/patogh_theme.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final metrics = const [
      ('نرخ پرشدن ظرفیت', 0.82, '۸۲٪'),
      ('تبدیل بازدید به رزرو', 0.46, '۴۶٪'),
      ('نرخ حضور', 0.91, '۹۱٪'),
      ('رضایت کاربران', 0.88, '۴.۶ از ۵'),
      ('بازگشت کاربران', 0.67, '۶۷٪'),
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
            'عملکرد پاتوق، رزروها، درآمد و کیفیت تجربه',
            style: TextStyle(color: Color(0xFFAAAAAA)),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF181818),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Text(
                  'درآمد این ماه',
                  style: TextStyle(color: Color(0xFFAAAAAA)),
                ),
                SizedBox(height: 5),
                Text(
                  '۱۲۸,۴۰۰,۰۰۰ تومان',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: PatoghTheme.orange,
                  ),
                ),
              ],
            ),
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
        ],
      ),
    );
  }
}
