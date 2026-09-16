import 'package:flutter/material.dart';
import 'package:patogh/pages/chat_room_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = const [
      ('گروه قرار شام پاتوق', 'میزبان: خوش اومدین 👋', '۲'),
      ('پشتیبانی پاتوق', 'رزرو شما ثبت شد.', ''),
      ('پاتوق فکری مشهد', 'جلسه بعدی شنبه ساعت ۱۸', '۱'),
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
              child: Material(
                color: const Color(0xFF171717),
                borderRadius: BorderRadius.circular(20),
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatRoomPage(title: chat.$1),
                      ),
                    );
                  },
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF2A2A2A),
                    child: Icon(Icons.groups_rounded, color: Color(0xFFFF8A2A)),
                  ),
                  title: Text(
                    chat.$1,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    chat.$2,
                    style: const TextStyle(
                      color: Color(0xFFBDBDBD),
                      fontSize: 12,
                    ),
                  ),
                  trailing: chat.$3.isEmpty
                      ? null
                      : CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xFFFF8A2A),
                          child: Text(
                            chat.$3,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
