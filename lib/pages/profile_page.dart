import 'package:flutter/material.dart';
import 'package:patogh/pages/archive_page.dart';
import 'package:patogh/pages/badges_page.dart';
import 'package:patogh/pages/calendar_page.dart';
import 'package:patogh/pages/edit_profile_page.dart';
import 'package:patogh/pages/feedback_center_page.dart';
import 'package:patogh/pages/ecosystem_hub_page.dart';
import 'package:patogh/pages/dependents_page.dart';
import 'package:patogh/pages/host_dashboard_page.dart';
import 'package:patogh/pages/chat_page.dart';
import 'package:patogh/pages/notifications_page.dart';
import 'package:patogh/pages/game_page.dart';
import 'package:patogh/pages/privacy_page.dart';
import 'package:patogh/pages/role_center_page.dart';
import 'package:patogh/pages/social_links_page.dart';
import 'package:patogh/pages/my_circle_page.dart';
import 'package:patogh/pages/iran_location_picker_page.dart';
import 'package:patogh/pages/social_discovery_page.dart';
import 'package:patogh/pages/memories_library_page.dart';
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
                    .map((interest) => Chip(label: Text(interest)))
                    .toList(),
              ),
              const SizedBox(height: 20),
              _tile(
                context,
                Icons.edit_rounded,
                'ویرایش پروفایل',
                const EditProfilePage(),
              ),
              _tile(
                context,
                Icons.switch_account_rounded,
                'نقش‌های من و تغییر پنل',
                const RoleCenterPage(),
              ),
              _tile(
                context,
                Icons.link_rounded,
                'شبکه‌های اجتماعی و دسترسی',
                const SocialLinksPage(),
              ),
              _tile(
                context,
                Icons.location_city_rounded,
                'استان و شهر فعالیت',
                IranLocationPickerPage(
                  initialProvince: appState.selectedProvince,
                  initialCity: appState.selectedCity,
                  title: 'استان و شهر فعالیت',
                ),
              ),
              _tile(
                context,
                Icons.diversity_1_rounded,
                'حلقه من؛ دوستان و خانواده',
                const MyCirclePage(),
              ),
              _tile(
                context,
                Icons.people_alt_rounded,
                'تعامل هوشمند و هم‌پاتوقی‌ها',
                const SocialDiscoveryPage(),
              ),
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
                Icons.photo_album_rounded,
                'خاطرات و سالگردها',
                const MemoriesLibraryPage(),
              ),
              _tile(
                context,
                Icons.emoji_events_outlined,
                'مدال‌ها و افتخارات',
                const BadgesPage(),
              ),
              _tile(
                context,
                Icons.hub_rounded,
                'اکوسیستم کامل پاتوق',
                const EcosystemHubPage(),
              ),
              _tile(
                context,
                Icons.sports_esports_rounded,
                'بازی‌های پاتوق',
                const GamePage(),
              ),
              _tile(
                context,
                Icons.notifications_active_rounded,
                'اعلان‌ها',
                const NotificationsPage(),
              ),
              _tile(
                context,
                Icons.chat_bubble_rounded,
                'پیام‌ها و پشتیبانی',
                const ChatPage(),
              ),
              _tile(
                context,
                Icons.verified_rounded,
                'اعتبار، حضور و بازخورد',
                const FeedbackCenterPage(),
              ),
              _tile(
                context,
                Icons.family_restroom_rounded,
                'فرزندان و افراد تحت سرپرستی',
                const DependentsPage(),
              ),
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
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          trailing: const Icon(Icons.chevron_left_rounded),
        ),
      ),
    );
  }
}
