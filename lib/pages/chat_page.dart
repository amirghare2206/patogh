import 'package:flutter/material.dart';
import 'package:patogh/pages/chat_room_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rooms = const [
      ('support', 'پشتیبانی پاتوق'),
      ('dinner-01', 'گروه قرار شام پاتوق'),
      ('think-01', 'پاتوق فکری مشهد'),
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
          ...rooms.map(
            (room) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: const Color(0xFF171717),
                borderRadius: BorderRadius.circular(20),
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ChatRoomPage(roomId: room.$1, title: room.$2),
                      ),
                    );
                  },
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF2A2A2A),
                    child: Icon(Icons.groups_rounded),
                  ),
                  title: Text(room.$2),
                  trailing: const Icon(Icons.chevron_left_rounded),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
