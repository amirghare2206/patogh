import 'package:flutter/material.dart';
import 'package:patogh/pages/chat_page.dart';
import 'package:patogh/pages/game_page.dart';
import 'package:patogh/pages/notifications_page.dart';
import 'package:patogh/pages/profile_page.dart';
import 'package:patogh/pages/reservation_page.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int selectedIndex = 0;

  final pages = const [
    ReservationPage(),
    GamePage(),
    NotificationsPage(),
    ChatPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: IndexedStack(index: selectedIndex, children: pages),
        ),
      ),
      bottomNavigationBar: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _PatoghBottomNav(
            selectedIndex: selectedIndex,
            onTap: (index) {
              setState(() => selectedIndex = index);
            },
          ),
        ),
      ),
    );
  }
}

class _PatoghBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _PatoghBottomNav({required this.selectedIndex, required this.onTap});

  static const items = [
    (Icons.home_outlined, Icons.home_rounded, 'رزرو'),
    (Icons.sports_esports_outlined, Icons.sports_esports_rounded, 'بازی'),
    (Icons.notifications_none_rounded, Icons.notifications_rounded, 'اعلان‌ها'),
    (Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'چت'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'پروفایل'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: const BoxDecoration(
        color: Color(0xFF101010),
        border: Border(top: BorderSide(color: Color(0xFF1E1E1E))),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final selected = selectedIndex == index;
          final item = items[index];
          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected ? item.$2 : item.$1,
                    color: selected ? const Color(0xFFFF8A2A) : Colors.white,
                    size: 27,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$3,
                    style: TextStyle(
                      color: selected ? const Color(0xFFFF8A2A) : Colors.white,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
