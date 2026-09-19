import 'package:flutter/material.dart';
import 'package:patogh/theme/patogh_theme.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});
  @override
  Widget build(BuildContext context) {
    final users = const [
      ('سارا احمدی', 'شرکت‌کننده', '۸۹٪', 'فعال'),
      ('امیر محمدی', 'هماهنگ‌کننده', '۹۳٪', 'فعال'),
      ('مریم رضایی', 'شرکت‌کننده', '۷۴٪', 'بررسی'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت کاربران'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const TextField(
            decoration: InputDecoration(
              hintText: 'جست‌وجوی نام یا شماره موبایل',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 14),
          ...users.map(
            (u) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(18),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_rounded),
                  ),
                  title: Text(u.$1),
                  subtitle: Text('${u.$2} • اعتماد ${u.$3}'),
                  trailing: Text(
                    u.$4,
                    style: const TextStyle(
                      color: PatoghTheme.orange,
                      fontWeight: FontWeight.w800,
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
