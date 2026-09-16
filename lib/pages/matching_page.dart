import 'package:flutter/material.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class MatchingPage extends StatelessWidget {
  const MatchingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final interests = appState.profile?.interests ?? const <String>[];

    final people = [
      ('کاربر ۱', 96, ['کتاب', 'سفر', 'کافه']),
      ('کاربر ۲', 93, ['بازی', 'فیلم', 'گفت‌وگو']),
      ('کاربر ۳', 91, ['ورزش', 'سفر', 'فناوری']),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matching اعضا'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: people.map((person) {
          final shared = person.$3.where(interests.contains).toList();
          final adjusted = (person.$2 + shared.length).clamp(0, 99);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF181818),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFF2A2A2A),
                  child: Icon(Icons.person_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.$1,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'سازگاری $adjusted٪',
                        style: const TextStyle(
                          color: PatoghTheme.orange,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'علایق مشترک: ${shared.isEmpty ? 'در حال محاسبه' : shared.join('، ')}',
                        style: const TextStyle(
                          color: Color(0xFFBBBBBB),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
