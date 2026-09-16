import 'package:flutter/material.dart';
import 'package:patogh/pages/chat_page.dart';
import 'package:patogh/pages/game_page.dart';
import 'package:patogh/pages/notifications_page.dart';
import 'package:patogh/pages/profile_page.dart';
import 'package:patogh/pages/reservation_page.dart';
import 'package:patogh/theme/patogh_theme.dart';

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
          child: Container(
            height: 84,
            decoration: const BoxDecoration(
              color: Color(0xFF101010),
              border: Border(top: BorderSide(color: Color(0xFF242424))),
            ),
            child: Row(
              children: [
                _item(0, Icons.home_outlined, Icons.home_rounded, 'رزرو'),
                _item(
                  1,
                  Icons.sports_esports_outlined,
                  Icons.sports_esports_rounded,
                  'بازی',
                ),
                _item(
                  2,
                  Icons.notifications_none_rounded,
                  Icons.notifications_rounded,
                  'اعلان‌ها',
                ),
                _item(
                  3,
                  Icons.chat_bubble_outline_rounded,
                  Icons.chat_bubble_rounded,
                  'چت',
                ),
                _item(
                  4,
                  Icons.person_outline_rounded,
                  Icons.person_rounded,
                  'پروفایل',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(int index, IconData icon, IconData activeIcon, String label) {
    final selected = selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? activeIcon : icon,
              color: selected ? PatoghTheme.orange : Colors.white,
              size: 27,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? PatoghTheme.orange : Colors.white,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
