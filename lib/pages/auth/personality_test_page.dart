import 'package:flutter/material.dart';
import 'package:patogh/pages/auth/profile_setup_page.dart';
import 'package:patogh/theme/patogh_theme.dart';

class PersonalityTestPage extends StatefulWidget {
  final List<String> interests;

  const PersonalityTestPage({
    super.key,
    required this.interests,
  });

  @override
  State<PersonalityTestPage> createState() => _PersonalityTestPageState();
}

class _PersonalityTestPageState extends State<PersonalityTestPage> {
  int socialScore = 0;
  int adventureScore = 0;

  String? leisure;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شناخت شخصیت'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Text(
            'چند سوال کوتاه برای پیشنهاد بهتر پاتوق‌ها و آدم‌های مناسب.',
            style: TextStyle(
              color: PatoghTheme.muted,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'در جمع‌ها معمولاً چطور هستی؟',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),

          const SizedBox(height: 10),

          _choice(
            'آرام و بیشتر شنونده',
            () => setState(() => socialScore = 0),
          ),

          _choice(
            'اجتماعی و اهل گفتگو',
            () => setState(() => socialScore = 1),
          ),

          const SizedBox(height: 24),

          const Text(
            'کدام تفریح بیشتر دوست داری؟',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),

          const SizedBox(height: 10),

          _choice(
            'کافه، شهر و دورهمی',
            () {
              setState(() {
                leisure = 'شهری';
                adventureScore = 0;
              });
            },
          ),

          _choice(
            'طبیعت، سفر و تجربه جدید',
            () {
              setState(() {
                leisure = 'ماجراجویی';
                adventureScore = 1;
              });
            },
          ),

          const SizedBox(height: 30),

          FilledButton(
            onPressed: leisure == null
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfileSetupPage(
                          initialInterests: widget.interests,
                          personalityType: socialScore == 1
                              ? 'برون‌گرا'
                              : 'درون‌گرا',
                          leisureStyle: leisure!,
                          personalityTags: [
                            socialScore == 1
                                ? 'اجتماعی'
                                : 'آرام',
                            adventureScore == 1
                                ? 'ماجراجو'
                                : 'شهری',
                          ],
                        ),
                      ),
                    );
                  },
            child: const Text('ادامه'),
          ),
        ],
      ),
    );
  }

  Widget _choice(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }
}
