import 'package:flutter/material.dart';

class MatchingPage extends StatelessWidget {
  const MatchingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final people = const [
      ('کاربر ۱', '۹۶٪', 'کتاب، سفر، کافه', '۹۲٪'),
      ('کاربر ۲', '۹۳٪', 'بازی، فیلم، گفتگو', '۸۸٪'),
      ('کاربر ۳', '۹۱٪', 'ورزش، سفر، فناوری', '۹۰٪'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('پیشنهاد هوشمند اعضا'),
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
            children: people
                .map(
                  (person) => Container(
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
                              Row(
                                children: [
                                  Text(
                                    person.$1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'سازگاری ${person.$2}',
                                    style: const TextStyle(
                                      color: Color(0xFFFF8A2A),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'علایق مشترک: ${person.$3}',
                                style: const TextStyle(
                                  color: Color(0xFFBBBBBB),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'اعتماد: ${person.$4}',
                                style: const TextStyle(
                                  color: Color(0xFFBBBBBB),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () {},
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8A2A),
                          ),
                          icon: const Icon(Icons.person_add_alt_1_rounded),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
