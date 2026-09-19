import 'package:flutter/material.dart';
import 'package:patogh/models/user_role.dart';
import 'package:patogh/pages/admin/admin_approvals_page.dart';
import 'package:patogh/pages/admin/admin_dashboard_page.dart';
import 'package:patogh/pages/admin/admin_reports_page.dart';
import 'package:patogh/pages/admin/category_management_page.dart';
import 'package:patogh/pages/communities_page.dart';
import 'package:patogh/pages/coordinator_dashboard_page.dart';
import 'package:patogh/pages/organizer_dashboard_page.dart';
import 'package:patogh/pages/profile_page.dart';
import 'package:patogh/pages/reservation_page.dart';
import 'package:patogh/pages/stories_page.dart';
import 'package:patogh/pages/timeline_page.dart';
import 'package:patogh/pages/venue_dashboard_page.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final config = _configFor(appState.role);
        final safeIndex = selectedIndex >= config.pages.length
            ? 0
            : selectedIndex;

        return Scaffold(
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: IndexedStack(index: safeIndex, children: config.pages),
            ),
          ),
          bottomNavigationBar: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                height: 84,
                decoration: const BoxDecoration(
                  color: Color(0xFF101010),
                  border: Border(top: BorderSide(color: Color(0xFF242424))),
                ),
                child: Row(
                  children: List.generate(config.items.length, (index) {
                    final item = config.items[index];
                    final active = safeIndex == index;
                    return Expanded(
                      child: InkWell(
                        onTap: () => setState(() => selectedIndex = index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              color: active ? PatoghTheme.orange : Colors.white,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: active
                                    ? PatoghTheme.orange
                                    : Colors.white,
                                fontSize: 11,
                                fontWeight: active
                                    ? FontWeight.w900
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  _ShellConfig _configFor(UserRole role) {
    switch (role) {
      case UserRole.venue:
        return const _ShellConfig(
          pages: [
            VenueDashboardPage(),
            StoriesPage(),
            TimelinePage(),
            CommunitiesPage(),
            ProfilePage(),
          ],
          items: [
            _NavItem(Icons.storefront_rounded, 'میزبانی'),
            _NavItem(Icons.auto_stories_rounded, 'استوری'),
            _NavItem(Icons.dynamic_feed_rounded, 'تایم‌لاین'),
            _NavItem(Icons.groups_rounded, 'گروه‌ها'),
            _NavItem(Icons.person_rounded, 'پروفایل'),
          ],
        );
      case UserRole.coordinator:
        return const _ShellConfig(
          pages: [
            CoordinatorDashboardPage(),
            TimelinePage(),
            CommunitiesPage(),
            StoriesPage(),
            ProfilePage(),
          ],
          items: [
            _NavItem(Icons.event_note_rounded, 'رویدادها'),
            _NavItem(Icons.dynamic_feed_rounded, 'تایم‌لاین'),
            _NavItem(Icons.groups_rounded, 'گروه‌ها'),
            _NavItem(Icons.auto_stories_rounded, 'استوری'),
            _NavItem(Icons.person_rounded, 'پروفایل'),
          ],
        );
      case UserRole.organizer:
        return const _ShellConfig(
          pages: [
            OrganizerDashboardPage(),
            StoriesPage(),
            TimelinePage(),
            CommunitiesPage(),
            ProfilePage(),
          ],
          items: [
            _NavItem(Icons.campaign_rounded, 'برگزاری'),
            _NavItem(Icons.auto_stories_rounded, 'استوری'),
            _NavItem(Icons.dynamic_feed_rounded, 'تایم‌لاین'),
            _NavItem(Icons.groups_rounded, 'گروه‌ها'),
            _NavItem(Icons.person_rounded, 'پروفایل'),
          ],
        );
      case UserRole.admin:
        return const _ShellConfig(
          pages: [
            AdminDashboardPage(),
            AdminApprovalsPage(),
            CategoryManagementPage(),
            AdminReportsPage(),
            ProfilePage(),
          ],
          items: [
            _NavItem(Icons.dashboard_rounded, 'مدیریت'),
            _NavItem(Icons.fact_check_rounded, 'تأییدها'),
            _NavItem(Icons.category_rounded, 'دسته‌ها'),
            _NavItem(Icons.insights_rounded, 'گزارشات'),
            _NavItem(Icons.person_rounded, 'پروفایل'),
          ],
        );
      case UserRole.participant:
        return const _ShellConfig(
          pages: [
            ReservationPage(),
            TimelinePage(),
            StoriesPage(),
            CommunitiesPage(),
            ProfilePage(),
          ],
          items: [
            _NavItem(Icons.home_rounded, 'رزرو'),
            _NavItem(Icons.dynamic_feed_rounded, 'تایم‌لاین'),
            _NavItem(Icons.auto_stories_rounded, 'استوری'),
            _NavItem(Icons.groups_rounded, 'گروه‌ها'),
            _NavItem(Icons.person_rounded, 'پروفایل'),
          ],
        );
    }
  }
}

class _ShellConfig {
  final List<Widget> pages;
  final List<_NavItem> items;

  const _ShellConfig({required this.pages, required this.items});
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem(this.icon, this.label);
}
