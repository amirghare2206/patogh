import 'package:flutter/material.dart';
import 'package:patogh/theme/patogh_theme.dart';

class BadgesPage extends StatelessWidget {
  const BadgesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = const [
      ('اولین پاتوق', Icons.emoji_events_rounded, 'اولین حضور موفق'),
      ('خوش‌قول', Icons.alarm_on_rounded, 'حضور به‌موقع'),
      ('گفت‌وگوگر برتر', Icons.forum_rounded, 'بازخورد مثبت'),
      ('میزبان محبوب', Icons.star_rounded, 'امتیاز بالای میزبانی'),
      ('همیار نمونه', Icons.volunteer_activism_rounded, 'کمک به جمع'),
      ('۱۰ پاتوق متوالی', Icons.local_fire_department_rounded, 'فعالیت مستمر'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('مدال‌ها و افتخارات'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: GridView.builder(
            padding: const EdgeInsets.all(22),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.02,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(badge.$2, size: 42, color: PatoghTheme.orange),
                    const SizedBox(height: 10),
                    Text(
                      badge.$1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      badge.$3,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
