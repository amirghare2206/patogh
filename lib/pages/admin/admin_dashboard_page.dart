import 'package:flutter/material.dart';
import 'package:patogh/pages/admin/admin_entities_page.dart';
import 'package:patogh/pages/admin/admin_events_page.dart';
import 'package:patogh/pages/admin/admin_finance_page.dart';
import 'package:patogh/pages/admin/admin_moderation_page.dart';
import 'package:patogh/pages/admin/admin_users_page.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('کاربران', '۱۲۴۸', Icons.people_rounded),
      ('کسب‌وکارها', '۶۳', Icons.storefront_rounded),
      ('هماهنگ‌کننده‌ها', '۲۷', Icons.badge_rounded),
      ('برگزارکننده‌ها', '۳۸', Icons.campaign_rounded),
      ('رویدادهای فعال', '${appState.events.length}', Icons.event_rounded),
      (
        'تأییدهای معلق',
        '${appState.roleRequests.where((r) => r.status == 'pending').length}',
        Icons.fact_check_rounded,
      ),
    ];
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'مدیریت کل پاتوق',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'کنترل کاربران، نقش‌ها، دسته‌بندی‌ها، رویدادها و گزارش‌ها',
            style: TextStyle(color: Color(0xFFAAAAAA)),
          ),
          const SizedBox(height: 18),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.55,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: metrics
                .map(
                  (metric) => Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181818),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(metric.$3, color: PatoghTheme.orange),
                        const SizedBox(height: 6),
                        Text(
                          metric.$2,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          metric.$1,
                          style: const TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          const Text(
            'مدیریت تفصیلی',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _Link(
            title: 'کاربران',
            icon: Icons.people_rounded,
            page: const AdminUsersPage(),
          ),
          _Link(
            title: 'کسب‌وکارها، هماهنگ‌کننده‌ها و آژانس‌ها',
            icon: Icons.business_center_rounded,
            page: const AdminEntitiesPage(),
          ),
          _Link(
            title: 'رویدادها',
            icon: Icons.event_rounded,
            page: const AdminEventsPage(),
          ),
          _Link(
            title: 'مالی و پرداخت‌ها',
            icon: Icons.payments_rounded,
            page: const AdminFinancePage(),
          ),
          _Link(
            title: 'گزارش تخلف و نظارت',
            icon: Icons.gavel_rounded,
            page: const AdminModerationPage(),
          ),
          const SizedBox(height: 18),
          const _Alert(
            icon: Icons.report_problem_rounded,
            title: '۲ گزارش تخلف جدید',
            subtitle: 'نیازمند بررسی امروز',
          ),
          const _Alert(
            icon: Icons.payments_rounded,
            title: '۳ پرداخت نیازمند تطبیق',
            subtitle: 'بخش مالی',
          ),
          const _Alert(
            icon: Icons.event_busy_rounded,
            title: '۱ رویداد نزدیک به لغو',
            subtitle: 'به علت تکمیل نشدن ظرفیت',
          ),
        ],
      ),
    );
  }
}

class _Alert extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Alert({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF181818),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Icon(icon, color: PatoghTheme.orange),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Link extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget page;
  const _Link({required this.title, required this.icon, required this.page});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: const Color(0xFF181818),
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
        leading: Icon(icon, color: PatoghTheme.orange),
        title: Text(title),
        trailing: const Icon(Icons.chevron_left_rounded),
      ),
    ),
  );
}
