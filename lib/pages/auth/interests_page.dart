import 'package:flutter/material.dart';
import 'package:patogh/pages/auth/personality_test_page.dart';
import 'package:patogh/theme/patogh_theme.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  final Set<String> selected = {};

  final interests = const [
    ('☕', 'کافه'),
    ('💬', 'گفت‌وگو'),
    ('📚', 'کتاب'),
    ('🎮', 'بازی'),
    ('🏃', 'ورزش'),
    ('🏕', 'سفر و طبیعت'),
    ('💻', 'فناوری'),
    ('🎬', 'فیلم'),
    ('🎨', 'هنر'),
    ('👨‍👩‍👧', 'کودک و خانواده'),
    ('🤝', 'داوطلبانه'),
    ('🍔', 'غذا'),
    ('📸', 'عکاسی'),
    ('🎵', 'موسیقی'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('علایقت را انتخاب کن'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Text(
            'برای اینکه پاتوق تجربه بهتری برایت بسازد، حداقل ۳ علاقه انتخاب کن.',
            style: TextStyle(
              color: PatoghTheme.muted,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: interests.map((item) {
              final active = selected.contains(item.$2);

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    if (active) {
                      selected.remove(item.$2);
                    } else {
                      selected.add(item.$2);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? PatoghTheme.orange.withAlpha(55)
                        : PatoghTheme.surface2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active
                          ? PatoghTheme.orange
                          : const Color(0xFF3C426D),
                    ),
                  ),
                  child: Text(
                    '${item.$1} ${item.$2}',
                    style: TextStyle(
                      fontWeight: active
                          ? FontWeight.w900
                          : FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          FilledButton(
            onPressed: selected.length >= 3
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PersonalityTestPage(
                          interests: selected.toList(),
                        ),
                      ),
                    );
                  }
                : null,
            child: Text(
              selected.length >= 3
                  ? 'ادامه'
                  : 'حداقل ۳ علاقه انتخاب کن',
            ),
          ),
        ],
      ),
    );
  }
}
