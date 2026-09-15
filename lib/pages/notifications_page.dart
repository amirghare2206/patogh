import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      ('رزرو', 'ظرفیت «قرار صبحانه» رو به تکمیله.', Icons.event_seat_rounded),
      ('یادآوری', 'پاتوق فردای شما ساعت ۱۹ شروع می‌شه.', Icons.alarm_rounded),
      (
        'پیشنهاد',
        'یک پاتوق هم‌فکر جدید در مشهد اضافه شد.',
        Icons.auto_awesome_rounded,
      ),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Text(
            'اعلان‌ها',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 18),
          ...items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF171717),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF2B2B2B),
                    child: Icon(item.$3, color: const Color(0xFFFF8A2A)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$1,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.$2,
                          style: const TextStyle(
                            color: Color(0xFFC5C5C5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
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
