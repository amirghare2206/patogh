import 'package:flutter/material.dart';
import 'package:patogh/pages/auth/profile_setup_page.dart';
import 'package:patogh/theme/patogh_theme.dart';

class PersonalityTestPage extends StatefulWidget {
  final List<String> interests;

  const PersonalityTestPage({super.key, required this.interests});

  @override
  State<PersonalityTestPage> createState() => _PersonalityTestPageState();
}

class _PersonalityTestPageState extends State<PersonalityTestPage> {
  final Map<int, int> _answers = <int, int>{};

  static const List<_Question> _questions = <_Question>[
    _Question(
      title: 'در یک جمع تازه معمولاً کدام حالت به تو نزدیک‌تر است؟',
      helper: 'سبک حضور تو در جمع',
      choices: <_Choice>[
        _Choice('اول فضا را می‌سنجم و کم‌کم وارد گفت‌وگو می‌شوم.', ['آرام', 'گروه_کوچک']),
        _Choice('معمولاً خودم سر صحبت را باز می‌کنم.', ['اجتماعی', 'آغازگر_گفتگو']),
        _Choice('بستگی به آدم‌ها و حال‌وهوای جمع دارد.', ['منعطف', 'اجتماعی_متوسط']),
      ],
    ),
    _Question(
      title: 'برای دورهمی کدام فضا را بیشتر می‌پسندی؟',
      helper: 'اندازه و انرژی جمع',
      choices: <_Choice>[
        _Choice('جمع کوچک که فرصت گفت‌وگوی عمیق داشته باشیم.', ['گروه_کوچک', 'گفتگوی_عمیق']),
        _Choice('جمع بزرگ و پرانرژی با آدم‌های تازه.', ['گروه_بزرگ', 'اجتماعی']),
        _Choice('هر دو را دوست دارم؛ به برنامه بستگی دارد.', ['منعطف', 'تنوع_اجتماعی']),
      ],
    ),
    _Question(
      title: 'کدام برنامه بیشتر خوشحالت می‌کند؟',
      helper: 'ترجیح تفریحی',
      choices: <_Choice>[
        _Choice('کافه، نمایشگاه، سینما یا کشف شهر.', ['شهری', 'فرهنگی']),
        _Choice('طبیعت‌گردی، سفر کوتاه و مسیر تازه.', ['طبیعت', 'ماجراجو']),
        _Choice('ورزش یا فعالیت پرتحرک گروهی.', ['فعال', 'ورزشی']),
        _Choice('کتاب، بازی فکری یا گفت‌وگوی موضوعی.', ['فکری', 'آرام']),
      ],
    ),
    _Question(
      title: 'برای برنامه‌ریزی یک قرار گروهی چه سبکی را ترجیح می‌دهی؟',
      helper: 'نحوه تصمیم‌گیری',
      choices: <_Choice>[
        _Choice('زمان، مکان و جزئیات از قبل مشخص باشد.', ['برنامه_ریز', 'منظم']),
        _Choice('برنامه منعطف باشد و همان لحظه تصمیم بگیریم.', ['خودجوش', 'منعطف']),
        _Choice('چارچوب مشخص باشد ولی جا برای تغییر هم بماند.', ['متعادل', 'برنامه_ریز', 'منعطف']),
      ],
    ),
    _Question(
      title: 'در گفت‌وگو با دیگران بیشتر از چه چیزی لذت می‌بری؟',
      helper: 'موضوعات مورد علاقه',
      choices: <_Choice>[
        _Choice('تجربه‌های شخصی و حرف‌های عمیق.', ['گفتگوی_عمیق', 'همدلی']),
        _Choice('شوخی، سرگرمی و اتفاقات روزمره.', ['سرگرمی', 'گفتگوی_سبک']),
        _Choice('یادگرفتن موضوع تازه و تبادل ایده.', ['یادگیری', 'فکری']),
        _Choice('ساختن ارتباط کاری و همکاری روی ایده‌ها.', ['کاری', 'همکاری']),
      ],
    ),
    _Question(
      title: 'اگر یک فعالیت گروهی انتخاب کنی، کدام را برمی‌داری؟',
      helper: 'نوع مشارکت',
      choices: <_Choice>[
        _Choice('کمک داوطلبانه یا یک کار اجتماعی مفید.', ['داوطلبانه', 'همدلی']),
        _Choice('ورزش، بازی یا چالش گروهی.', ['ورزشی', 'بازی', 'فعال']),
        _Choice('کارگاه هنری، کتاب‌خوانی یا یادگیری.', ['فرهنگی', 'یادگیری', 'فکری']),
        _Choice('آشنایی با آدم‌ها و ساختن دوستی‌های جدید.', ['آشنایی', 'اجتماعی']),
      ],
    ),
    _Question(
      title: 'وقتی خسته‌ای، چه چیزی بیشتر به تو انرژی می‌دهد؟',
      helper: 'سبک بازیابی انرژی',
      choices: <_Choice>[
        _Choice('کمی زمان برای خودم یا جمعی آرام.', ['آرام', 'گروه_کوچک']),
        _Choice('دیدن دوستان و بودن در جمع.', ['اجتماعی', 'گروه_بزرگ']),
        _Choice('حرکت، ورزش یا بیرون رفتن.', ['فعال', 'طبیعت']),
        _Choice('بسته به شرایط، ترکیبی از این‌ها.', ['منعطف', 'متعادل']),
      ],
    ),
    _Question(
      title: 'از یک پاتوق خوب چه انتظاری داری؟',
      helper: 'اولویت در تجربه اجتماعی',
      choices: <_Choice>[
        _Choice('فضای امن و محترمانه برای آشنایی.', ['امنیت_اجتماعی', 'آشنایی']),
        _Choice('فعالیت مشترک و تجربه تازه.', ['تجربه_تازه', 'ماجراجو']),
        _Choice('یادگیری، تبادل نظر و رشد.', ['یادگیری', 'فکری']),
        _Choice('همکاری، شبکه‌سازی یا کمک به دیگران.', ['همکاری', 'داوطلبانه']),
      ],
    ),
  ];

  List<String> get _resultTags {
    final tags = <String>{};
    for (final entry in _answers.entries) {
      tags.addAll(_questions[entry.key].choices[entry.value].tags);
    }
    return tags.toList()..sort();
  }

  String get _personalityType {
    final tags = _resultTags.toSet();
    final social = tags.contains('اجتماعی') || tags.contains('آغازگر_گفتگو') || tags.contains('گروه_بزرگ');
    final calm = tags.contains('آرام') || tags.contains('گروه_کوچک') || tags.contains('گفتگوی_عمیق');
    if (social && calm) return 'اجتماعیِ منعطف';
    if (social) return 'اجتماعی';
    if (calm) return 'آرام و تأمل‌گرا';
    return 'منعطف';
  }

  String get _leisureStyle {
    final tags = _resultTags.toSet();
    if (tags.contains('طبیعت') || tags.contains('ماجراجو')) return 'طبیعت و تجربه‌های تازه';
    if (tags.contains('شهری') || tags.contains('فرهنگی')) return 'شهری و فرهنگی';
    if (tags.contains('فعال') || tags.contains('ورزشی')) return 'فعال و پرتحرک';
    if (tags.contains('فکری') || tags.contains('یادگیری')) return 'فکری و یادگیری';
    return 'ترکیبی و منعطف';
  }

  @override
  Widget build(BuildContext context) {
    final answered = _answers.length;
    return Scaffold(
      appBar: AppBar(title: const Text('شناخت علایق و سبک اجتماعی')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
        children: [
          const Text(
            'به ۸ سؤال زیر جواب بده تا پیشنهادهای پاتوق با ترجیحاتت هماهنگ‌تر شوند. این پرسش‌نامه تشخیص پزشکی یا روان‌شناختی نیست و هر زمان می‌توانی ترجیحاتت را تغییر بدهی.',
            style: TextStyle(color: PatoghTheme.muted, height: 1.7),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: answered / _questions.length,
              minHeight: 7,
              backgroundColor: PatoghTheme.surface2,
              color: PatoghTheme.orange,
            ),
          ),
          const SizedBox(height: 8),
          Text('$answered از ${_questions.length} سؤال پاسخ داده شده'),
          const SizedBox(height: 18),
          for (var i = 0; i < _questions.length; i++) ...[
            _questionCard(i, _questions[i]),
            const SizedBox(height: 14),
          ],
          if (answered == _questions.length) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PatoghTheme.surface2,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF3C426D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('خلاصه ترجیحات فعلی', style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text('سبک اجتماعی: $_personalityType'),
                  Text('سبک تفریح: $_leisureStyle'),
                  const SizedBox(height: 6),
                  const Text('این خلاصه از پاسخ‌های خودت ساخته شده و تشخیص علمی شخصیت نیست.', style: TextStyle(color: PatoghTheme.muted, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          FilledButton.icon(
            onPressed: answered == _questions.length
                ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfileSetupPage(
                          initialInterests: widget.interests,
                          personalityType: _personalityType,
                          leisureStyle: _leisureStyle,
                          personalityTags: _resultTags,
                          personalityAnswers: {
                            for (final entry in _answers.entries)
                              'q${entry.key + 1}': _questions[entry.key].choices[entry.value].label,
                          },
                        ),
                      ),
                    )
                : null,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(answered == _questions.length ? 'ادامه تکمیل پروفایل' : 'به همه سؤال‌ها پاسخ بده'),
          ),
        ],
      ),
    );
  }

  Widget _questionCard(int index, _Question question) {
    final selected = _answers[index];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PatoghTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected == null ? const Color(0xFF343958) : PatoghTheme.orange.withAlpha(170)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('سؤال ${index + 1}', style: const TextStyle(color: PatoghTheme.orange, fontWeight: FontWeight.w900, fontSize: 11)),
          const SizedBox(height: 5),
          Text(question.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, height: 1.5)),
          const SizedBox(height: 3),
          Text(question.helper, style: const TextStyle(color: PatoghTheme.muted, fontSize: 11)),
          const SizedBox(height: 10),
          for (var i = 0; i < question.choices.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: () => setState(() => _answers[index] = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
                  decoration: BoxDecoration(
                    color: selected == i ? PatoghTheme.orange.withAlpha(32) : PatoghTheme.surface2,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: selected == i ? PatoghTheme.orange : const Color(0xFF343958)),
                  ),
                  child: Row(
                    children: [
                      Icon(selected == i ? Icons.radio_button_checked : Icons.radio_button_off, color: selected == i ? PatoghTheme.orange : PatoghTheme.muted, size: 19),
                      const SizedBox(width: 9),
                      Expanded(child: Text(question.choices[i].label, style: const TextStyle(fontSize: 12, height: 1.5))),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Question {
  final String title;
  final String helper;
  final List<_Choice> choices;
  const _Question({required this.title, required this.helper, required this.choices});
}

class _Choice {
  final String label;
  final List<String> tags;
  const _Choice(this.label, this.tags);
}
