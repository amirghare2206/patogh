import 'package:flutter/material.dart';

class GroupQualityPage extends StatelessWidget {
  const GroupQualityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = const [
      ('میزان آشنایی اعضا', 0.84),
      ('تنوع علایق', 0.92),
      ('میانگین اعتماد', 0.91),
      ('تجربه حضور', 0.88),
      ('تعادل گروه', 0.90),
      ('احتمال تعامل موفق', 0.96),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('تحلیل کیفیت گروه'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 64,
                  backgroundColor: Color(0xFF183127),
                  child: Text(
                    '۹۴\nاز ۱۰۰',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF79E1A9),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ...metrics.map(
                (metric) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(metric.$1),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: metric.$2,
                        minHeight: 8,
                        color: const Color(0xFFFF8A2A),
                        backgroundColor: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'پیشنهاد هوشمند: اضافه شدن دو شرکت‌کننده تازه‌وارد می‌تواند کیفیت تعامل گروه را افزایش دهد.',
                  style: TextStyle(height: 1.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
