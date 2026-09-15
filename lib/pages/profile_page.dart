import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = const [
      ('پاتوق‌های من', '۴'),
      ('امتیاز اعتماد', '۸۹٪'),
      ('نظرها', '۱۲'),
    ];

    return SafeArea(
      child: ListView(
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
              child: Icon(Icons.person_rounded, size: 50, color: Colors.white),
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
            children: stats
                .map(
                  (stat) => Expanded(
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
                            stat.$2,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFF8A2A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stat.$1,
                            style: const TextStyle(
                              color: Color(0xFFBFBFBF),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 22),
          const _ProfileTile(
            icon: Icons.badge_outlined,
            title: 'ویرایش اطلاعات',
          ),
          const _ProfileTile(icon: Icons.history_rounded, title: 'سوابق رزرو'),
          const _ProfileTile(
            icon: Icons.verified_user_outlined,
            title: 'حریم خصوصی و اعتماد',
          ),
          const _ProfileTile(
            icon: Icons.help_outline_rounded,
            title: 'راهنما و پشتیبانی',
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ProfileTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF8A2A)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const Icon(Icons.chevron_left_rounded, color: Color(0xFF888888)),
        ],
      ),
    );
  }
}
