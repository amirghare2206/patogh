import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = const [
      ('گروه قرار شام', 'میزبان: خوش اومدین 👋', '۲ پیام جدید'),
      ('پشتیبانی پاتوق', 'رزرو شما ثبت شد.', ''),
      ('هم‌فکر مشهد', 'جلسه بعدی شنبه ساعت ۱۸', '۱ پیام جدید'),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Text(
            'چت',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 18),
          ...chats.map(
            (chat) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF171717),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF2A2A2A),
                    child: Icon(Icons.groups_rounded, color: Color(0xFFFF8A2A)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat.$1,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chat.$2,
                          style: const TextStyle(
                            color: Color(0xFFBDBDBD),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (chat.$3.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8A2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        chat.$3,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
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
