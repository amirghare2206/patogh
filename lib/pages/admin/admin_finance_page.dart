import 'package:flutter/material.dart';
import 'package:patogh/theme/patogh_theme.dart';

class AdminFinancePage extends StatelessWidget {
  const AdminFinancePage({super.key});
  @override
  Widget build(BuildContext context) {
    final rows = const [
      ('قرار صبحانه پاتوق', '۷۵۰,۰۰۰', 'تسویه‌شده'),
      ('شب بازی پاتوق', '۱,۳۲۰,۰۰۰', 'در انتظار'),
      ('پاتوق گفت‌وگوی بانوان', '۹۶۰,۰۰۰', 'تسویه‌شده'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('مالی و پرداخت‌ها'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF181818),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Text(
                  'گردش مالی این ماه',
                  style: TextStyle(color: Color(0xFFAAAAAA)),
                ),
                SizedBox(height: 6),
                Text(
                  '۱۲۸,۴۰۰,۰۰۰ تومان',
                  style: TextStyle(
                    fontSize: 24,
                    color: PatoghTheme.orange,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...rows.map(
            (r) => ListTile(
              title: Text(r.$1),
              subtitle: Text(r.$2),
              trailing: Text(r.$3),
            ),
          ),
        ],
      ),
    );
  }
}
