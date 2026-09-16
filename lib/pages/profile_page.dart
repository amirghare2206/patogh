import 'package:flutter/material.dart';
import 'package:patogh/pages/host_dashboard_page.dart';
import 'package:patogh/pages/privacy_page.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final profile = appState.profile;

          return ListView(
            padding: const EdgeInsets.all(22),
            children: [
              const Text(
                'پروفایل',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 10),
              Text(
                profile?.name ?? 'کاربر پاتوق',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                profile?.city ?? 'مشهد',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFAAAAAA)),
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 7,
                runSpacing: 7,
                children: (profile?.interests ?? const <String>[])
                    .map((i) => Chip(label: Text(i)))
                    .toList(),
              ),
              const SizedBox(height: 20),
              _tile(
                context,
                Icons.verified_user_outlined,
                'حریم خصوصی',
                const PrivacyPage(),
              ),
              _tile(
                context,
                Icons.dashboard_customize_rounded,
                'داشبورد میزبان',
                const HostDashboardPage(),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => appState.logout(),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('خروج از حساب'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF9B9B),
                ),
              ),
            ],
          );
        },
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
          leading: Icon(icon, color: PatoghTheme.orange),
          title: Text(title),
          trailing: const Icon(Icons.chevron_left_rounded),
        ),
      ),
    );
  }
}
