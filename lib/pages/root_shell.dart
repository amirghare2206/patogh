import 'package:flutter/material.dart';
import 'package:patogh/models/user_role.dart';
import 'package:patogh/pages/admin/admin_approvals_page.dart';
import 'package:patogh/pages/admin/admin_dashboard_page.dart';
import 'package:patogh/pages/admin/admin_reports_page.dart';
import 'package:patogh/pages/admin/engagement_admin_page.dart';
import 'package:patogh/pages/admin/category_management_page.dart';
import 'package:patogh/pages/communities_page.dart';
import 'package:patogh/pages/home_page.dart';
import 'package:patogh/pages/golrizon_page.dart';
import 'package:patogh/pages/surprise_page.dart';
import 'package:patogh/pages/notifications_page.dart';
import 'package:patogh/pages/coordinator_dashboard_page.dart';
import 'package:patogh/pages/organizer_dashboard_page.dart';
import 'package:patogh/pages/profile_page.dart';
import 'package:patogh/pages/stories_page.dart';
import 'package:patogh/pages/timeline_page.dart';
import 'package:patogh/pages/time_occasion_hub_page.dart';
import 'package:patogh/pages/admin/time_engine_admin_page.dart';
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(config.items.length, (index) {
                      final item = config.items[index];
                      final active = safeIndex == index;
                      return SizedBox(
                        width: config.items.length > 5 ? 76 : 104,
                        child: InkWell(
                          onTap: () => setState(() => selectedIndex = index),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                item.icon,
                                color: active
                                    ? PatoghTheme.orange
                                    : Colors.white,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: active
                                      ? PatoghTheme.orange
                                      : Colors.white,
                                  fontSize: config.items.length > 5 ? 9 : 11,
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
            TimeEngineAdminPage(),
            EngagementAdminPage(),
            AdminReportsPage(),
            ProfilePage(),
          ],
          items: [
            _NavItem(Icons.dashboard_rounded, 'مدیریت'),
            _NavItem(Icons.fact_check_rounded, 'تأییدها'),
            _NavItem(Icons.category_rounded, 'دسته‌ها'),
            _NavItem(Icons.calendar_month_rounded, 'تقویم'),
            _NavItem(Icons.explore_rounded, 'تعامل'),
            _NavItem(Icons.insights_rounded, 'گزارشات'),
            _NavItem(Icons.person_rounded, 'پروفایل'),
          ],
        );
      case UserRole.participant:
        return const _ShellConfig(
          pages: [
            HomePage(),
            TimeOccasionHubPage(),
            SurprisePage(),
            GolrizonPage(),
            TimelinePage(),
            CommunitiesPage(),
            NotificationsPage(),
            ProfilePage(),
          ],
          items: [
            _NavItem(Icons.home_rounded, 'خانه'),
            _NavItem(Icons.calendar_month_rounded, 'تقویم'),
            _NavItem(Icons.card_giftcard_rounded, 'سورپرایز'),
            _NavItem(Icons.volunteer_activism_rounded, 'گل‌ریزون'),
            _NavItem(Icons.dynamic_feed_rounded, 'تایم‌لاین'),
            _NavItem(Icons.groups_rounded, 'گروه‌ها'),
            _NavItem(Icons.notifications_rounded, 'اعلان‌ها'),
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
