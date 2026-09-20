import 'package:flutter/material.dart';
import 'package:patogh/pages/chat_room_page.dart';
import 'package:patogh/services/platform_services.dart';
import 'package:patogh/state/app_state.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rooms = <(String, String)>[];
    final uid = PlatformServices.currentUserId;
    rooms.add((uid == null ? 'support' : 'support:$uid', 'پشتیبانی پاتوق'));
    for (final event in appState.events) {
      if (appState.reservedIds.contains(event.id)) {
        rooms.add((event.id, 'گروه ${event.title}'));
      }
    }
    for (final community in appState.communities) {
      if (community.joined) rooms.add((community.id, community.title));
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Text(
            'چت',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'اتاق‌های رویداد فقط برای رزروهای تأییدشده و گروه‌ها/کانال‌ها فقط برای اعضا قابل دسترسی‌اند.',
            style: TextStyle(color: Color(0xFF999999), fontSize: 11),
          ),
          const SizedBox(height: 18),
          ...rooms.map(
            (room) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: const Color(0xFF171717),
                borderRadius: BorderRadius.circular(20),
                child: ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ChatRoomPage(roomId: room.$1, title: room.$2),
                    ),
                  ),
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
