import 'package:flutter/material.dart';
import 'package:patogh/pages/ai_concierge_page.dart';
import 'package:patogh/pages/communities_page.dart';
import 'package:patogh/pages/conference_center_page.dart';
import 'package:patogh/pages/engagement_hub_page.dart';
import 'package:patogh/pages/enterprise_page.dart';
import 'package:patogh/pages/event_request_page.dart';
import 'package:patogh/pages/golrizon_page.dart';
import 'package:patogh/pages/membership_clubs_page.dart';
import 'package:patogh/pages/memorial_center_page.dart';
import 'package:patogh/pages/memories_library_page.dart';
import 'package:patogh/pages/private_events_page.dart';
import 'package:patogh/pages/reservation_page.dart';
import 'package:patogh/pages/sponsorship_page.dart';
import 'package:patogh/pages/stories_page.dart';
import 'package:patogh/pages/surprise_page.dart';
import 'package:patogh/pages/time_occasion_hub_page.dart';
import 'package:patogh/theme/patogh_theme.dart';

class ServicesHubPage extends StatelessWidget {
  const ServicesHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final services = <_ServiceItem>[
      const _ServiceItem(
        'رویدادها و رزرو',
        'پیدا کردن و رزرو تجربه‌ها',
        Icons.event_available_rounded,
        ReservationPage(),
        PatoghTheme.orange,
      ),
      const _ServiceItem(
        'استوری‌ها',
        'لحظه‌ها و خبرهای تازه پاتوق',
        Icons.auto_stories_rounded,
        StoriesPage(),
        PatoghTheme.pink,
      ),
      const _ServiceItem(
        'گروه‌ها و کانال‌ها',
        'جمع‌ها، گفت‌وگو و برنامه‌ریزی',
        Icons.groups_rounded,
        CommunitiesPage(),
        PatoghTheme.teal,
      ),
      const _ServiceItem(
        'تقویم پاتوق',
        'مناسبت‌ها، ورزش، فصل و یادآورها',
        Icons.calendar_month_rounded,
        TimeOccasionHubPage(),
        PatoghTheme.purple,
      ),
      const _ServiceItem(
        'درخواست رویداد',
        'چیزی پیدا نکردی؟ درخواستش کن',
        Icons.add_task_rounded,
        EventRequestPage(),
        PatoghTheme.blue,
      ),
      const _ServiceItem(
        'خاطرات',
        'آلبوم، یادگاری و سالگرد رویدادها',
        Icons.photo_album_rounded,
        MemoriesLibraryPage(),
        PatoghTheme.pink,
      ),
      const _ServiceItem(
        'دعوت‌نامه',
        'مراسم خصوصی و RSVP مهمان‌ها',
        Icons.mark_email_read_rounded,
        PrivateEventsPage(),
        PatoghTheme.orange,
      ),
      const _ServiceItem(
        'سورپرایز',
        'غافلگیری با حلقه و دوستان',
        Icons.card_giftcard_rounded,
        SurprisePage(),
        PatoghTheme.purple,
      ),
      const _ServiceItem(
        'گل‌ریزون',
        'کمک جمعی برای رویداد یا کار خیر',
        Icons.volunteer_activism_rounded,
        GolrizonPage(),
        PatoghTheme.teal,
      ),
      const _ServiceItem(
        'همایش',
        'ثبت‌نام و مدیریت رویدادهای بزرگ',
        Icons.co_present_rounded,
        ConferenceCenterPage(),
        PatoghTheme.blue,
      ),
      const _ServiceItem(
        'باشگاه‌ها',
        'عضویت و رویداد مخصوص اعضا',
        Icons.workspace_premium_rounded,
        MembershipClubsPage(),
        PatoghTheme.yellow,
      ),
      const _ServiceItem(
        'تجربه و کشف',
        'داستان، مسیر و پاسپورت پاتوق',
        Icons.explore_rounded,
        EngagementHubPage(),
        PatoghTheme.teal,
      ),
      const _ServiceItem(
        'مموریال',
        'یادبود، سالگرد و دفتر خاطرات',
        Icons.local_florist_rounded,
        MemorialCenterPage(),
        PatoghTheme.pink,
      ),
      const _ServiceItem(
        'اسپانسری',
        'رویدادهای حمایت‌شده',
        Icons.handshake_rounded,
        SponsorshipPage(),
        PatoghTheme.orange,
      ),
      const _ServiceItem(
        'سازمانی',
        'رویدادها و خدمات B2B / B2E',
        Icons.apartment_rounded,
        EnterprisePage(),
        PatoghTheme.blue,
      ),
      const _ServiceItem(
        'دستیار پاتوق',
        'پیشنهاد تجربه با زبان خودت',
        Icons.auto_awesome_rounded,
        AiConciergePage(),
        PatoghTheme.purple,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('سرویس‌های پاتوق'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: PatoghTheme.brandGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Image.asset('assets/branding/patogh_logo.png'),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'همه امکانات پاتوق',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'خانه را برای رویدادها خلوت نگه داشتیم؛ بقیه امکانات اینجاست.',
                          style: TextStyle(height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.12,
              ),
              itemBuilder: (context, index) {
                final item = services[index];
                return Material(
                  color: PatoghTheme.surface,
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () =>
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => item.page)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: item.color.withAlpha(42),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(item.icon, color: item.color),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: PatoghTheme.muted,
                              fontSize: 9.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;
  final Color color;

  const _ServiceItem(
    this.title,
    this.subtitle,
    this.icon,
    this.page,
    this.color,
  );
}
