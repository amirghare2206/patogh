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
    ('☕', 'کافه و دورهمی', 'قرارهای دوستانه'),
    ('💬', 'گفت‌وگو', 'گپ صمیمی و موضوعی'),
    ('📚', 'کتاب و ادبیات', 'کتاب‌خوانی و قصه'),
    ('🎮', 'بازی', 'بازی‌های گروهی'),
    ('🏀', 'ورزش', 'تحرک و مسابقه'),
    ('🏕️', 'سفر و طبیعت', 'گشت و تجربه تازه'),
    ('💻', 'فناوری', 'تکنولوژی و نوآوری'),
    ('🎬', 'فیلم و سینما', 'تماشا و نقد'),
    ('🎨', 'هنر', 'هنر و خلاقیت'),
    ('👨‍👩‍👧', 'خانواده', 'فعالیت خانوادگی'),
    ('🤝', 'داوطلبانه', 'کمک و کار اجتماعی'),
    ('🍲', 'غذا و آشپزی', 'مزه‌ها و تجربه‌ها'),
    ('📸', 'عکاسی', 'ثبت لحظه‌ها'),
    ('🎵', 'موسیقی', 'موسیقی و اجرا'),
    ('💗', 'همدلی', 'حمایت و شنیدن'),
    ('🧠', 'فکری', 'ایده و بحث عمیق'),
    ('🧑‍💼', 'کاری', 'شبکه‌سازی حرفه‌ای'),
    ('🎓', 'آموزشی', 'یادگیری و کارگاه'),
    ('🌱', 'محیط زیست', 'طبیعت و پایداری'),
    ('🐾', 'حیوانات', 'حمایت از حیوانات'),
    ('🧘', 'سلامت و آرامش', 'ذهن‌آگاهی و تعادل'),
    ('🛠️', 'ساخت و مهارت', 'کارهای عملی'),
    ('🗣️', 'زبان‌آموزی', 'تمرین زبان'),
    ('🌆', 'کشف شهر', 'محله‌گردی و مکان‌ها'),
    ('🎭', 'تئاتر و اجرا', 'هنرهای نمایشی'),
    ('💡', 'کارآفرینی', 'ایده و کسب‌وکار'),
    ('🍃', 'سبک زندگی', 'عادت‌های بهتر'),
    ('🎲', 'بازی فکری', 'معما و تخته‌ای'),
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: interests.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.38,
            ),
            itemBuilder: (context, index) {
              final item = interests[index];
              final active = selected.contains(item.$2);
              return Material(
                color: active ? PatoghTheme.orange.withAlpha(35) : PatoghTheme.surface2,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => setState(() {
                    if (active) {
                      selected.remove(item.$2);
                    } else {
                      selected.add(item.$2);
                    }
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: active ? PatoghTheme.orange : const Color(0xFF3C426D)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(children: [
                          Text(item.$1, style: const TextStyle(fontSize: 25)),
                          const Spacer(),
                          Icon(active ? Icons.check_circle_rounded : Icons.circle_outlined,
                            size: 18, color: active ? PatoghTheme.orange : PatoghTheme.muted),
                        ]),
                        const SizedBox(height: 5),
                        Text(item.$2, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                        const SizedBox(height: 3),
                        Text(item.$3, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: PatoghTheme.muted, fontSize: 9)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text('انتخاب‌شده: ${selected.length}', style: const TextStyle(color: PatoghTheme.muted)),
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
