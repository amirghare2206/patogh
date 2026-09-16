import 'package:flutter/material.dart';
import 'package:patogh/pages/archive_page.dart';
import 'package:patogh/pages/badges_page.dart';
import 'package:patogh/pages/calendar_page.dart';
import 'package:patogh/pages/create_event_page.dart';
import 'package:patogh/pages/host_dashboard_page.dart';
import 'package:patogh/pages/privacy_page.dart';
import 'package:patogh/state/app_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(22),
            children: [
              const Text(
                'پروفایل',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 22),
              const Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: Color(0xFF2A2A2A),
                  child: Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'کاربر پاتوق',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'مشهد',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFB0B0B0)),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  _stat('رزروها', '${appState.reservedIds.length}'),
                  _stat('اعتماد', '۸۹٪'),
                  _stat('افتخارها', '۳'),
                ],
              ),
              const SizedBox(height: 22),
              _tile(
                context,
                Icons.calendar_month_rounded,
                'تقویم شخصی',
                const CalendarPage(),
              ),
              _tile(
                context,
                Icons.history_rounded,
                'آرشیو پاتوق‌ها',
                const ArchivePage(),
              ),
              _tile(
                context,
                Icons.emoji_events_outlined,
                'مدال‌ها و افتخارات',
                const BadgesPage(),
              ),
              _tile(
                context,
                Icons.verified_user_outlined,
                'حریم خصوصی و اعتماد',
                const PrivacyPage(),
              ),
              _tile(
                context,
                Icons.dashboard_customize_rounded,
                'داشبورد میزبان',
                const HostDashboardPage(),
              ),
              _tile(
                context,
                Icons.add_circle_outline_rounded,
                'ساخت پاتوق جدید',
                const CreateEventPage(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF171717),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFF8A2A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Color(0xFFBFBFBF), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, Widget page) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(18),
        child: ListTile(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
          },
          leading: Icon(icon, color: const Color(0xFFFF8A2A)),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          trailing: const Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFF888888),
          ),
        ),
      ),
    );
  }
}
