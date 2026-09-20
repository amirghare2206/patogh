import 'package:flutter/material.dart';
import 'package:patogh/models/v8_models.dart';
import 'package:patogh/pages/ai_concierge_page.dart';
import 'package:patogh/pages/campaigns_page.dart';
import 'package:patogh/pages/enterprise_page.dart';
import 'package:patogh/pages/engagement_hub_page.dart';
import 'package:patogh/pages/event_detail_page.dart';
import 'package:patogh/pages/event_request_page.dart';
import 'package:patogh/pages/golrizon_page.dart';
import 'package:patogh/pages/iran_location_picker_page.dart';
import 'package:patogh/pages/membership_clubs_page.dart';
import 'package:patogh/pages/memories_library_page.dart';
import 'package:patogh/pages/private_events_page.dart';
import 'package:patogh/pages/conference_center_page.dart';
import 'package:patogh/pages/time_occasion_hub_page.dart';
import 'package:patogh/pages/memorial_center_page.dart';
import 'package:patogh/pages/reservation_page.dart';
import 'package:patogh/pages/sponsorship_page.dart';
import 'package:patogh/pages/stories_page.dart';
import 'package:patogh/pages/surprise_page.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final banner = appState.banners.firstWhere(
            (item) => item.placement == 'home',
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'پاتوق',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'آدم‌ها، تجربه‌ها و جمع‌های واقعی',
                          style: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => _pickLocation(context),
                    icon: const Icon(Icons.location_on_rounded),
                    tooltip: 'تغییر شهر',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const IranLocationPickerPage(),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171717),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.near_me_rounded,
                        color: PatoghTheme.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${appState.selectedProvince} / ${appState.selectedCity}',
                        ),
                      ),
                      const Icon(Icons.expand_more_rounded),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReservationPage()),
                ),
                child: const IgnorePointer(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'پاتوق، دسته یا تجربه موردنظرت رو پیدا کن',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'استوری برگزارکننده‌ها و میزبان‌ها',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const StoriesPage()),
                    ),
                    child: const Text('همه'),
                  ),
                ],
              ),
              SizedBox(
                height: 84,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: appState.stories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, index) {
                    final story = appState.stories[index];
                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StoriesPage()),
                      ),
                      child: SizedBox(
                        width: 68,
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: PatoghTheme.orange,
                                  width: 2,
                                ),
                                color: const Color(0xFF262626),
                              ),
                              child: const Icon(Icons.storefront_rounded),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              story.owner,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A2C19), Color(0xFF171717)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        if (banner.sponsored)
                          const Chip(label: Text('اسپانسرشده')),
                        const Spacer(),
                        const Icon(
                          Icons.campaign_rounded,
                          color: PatoghTheme.orange,
                        ),
                      ],
                    ),
                    Text(
                      banner.title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      banner.subtitle,
                      style: const TextStyle(color: Color(0xFFCCCCCC)),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CampaignsPage(),
                          ),
                        ),
                        child: Text(banner.actionLabel),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'سرویس‌های پاتوق',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.25,
                children: [
                  _service(
                    context,
                    'رزرو پاتوق',
                    'رویدادها، دسته‌ها و رزرو',
                    Icons.event_available_rounded,
                    const ReservationPage(),
                  ),
                  _service(
                    context,
                    'تقویم پاتوق',
                    'مناسبت‌ها، ورزش، فصل و یادآورها',
                    Icons.calendar_month_rounded,
                    const TimeOccasionHubPage(),
                  ),
                  _service(
                    context,
                    'دستیار پاتوق',
                    'با زبان خودت تجربه پیدا کن',
                    Icons.auto_awesome_rounded,
                    const AiConciergePage(),
                  ),
                  _service(
                    context,
                    'تجربه و کشف',
                    'گیمیفیکیشن، داستان و مسیر',
                    Icons.explore_rounded,
                    const EngagementHubPage(),
                  ),
                  _service(
                    context,
                    'درخواست رویداد',
                    'تقاضای جدیدت رو ثبت کن',
                    Icons.add_task_rounded,
                    const EventRequestPage(),
                  ),
                  _service(
                    context,
                    'باشگاه‌ها',
                    'عضویت و رویداد مخصوص اعضا',
                    Icons.workspace_premium_rounded,
                    const MembershipClubsPage(),
                  ),
                  _service(
                    context,
                    'سازمانی',
                    'B2B و B2E',
                    Icons.apartment_rounded,
                    const EnterprisePage(),
                  ),
                  _service(
                    context,
                    'اسپانسری',
                    'رویدادهای حمایت‌شده',
                    Icons.volunteer_activism_rounded,
                    const SponsorshipPage(),
                  ),
                  _service(
                    context,
                    'خاطرات',
                    'آلبوم، یادگاری و سالگرد رویدادها',
                    Icons.photo_album_rounded,
                    const MemoriesLibraryPage(),
                  ),
                  _service(
                    context,
                    'مموریال',
                    'یادبود، سالگرد و دفتر خاطرات',
                    Icons.local_florist_rounded,
                    const MemorialCenterPage(),
                  ),
                  _service(
                    context,
                    'دعوت‌نامه',
                    'مراسم خصوصی و RSVP مهمان‌ها',
                    Icons.mark_email_read_rounded,
                    const PrivateEventsPage(),
                  ),
                  _service(
                    context,
                    'سورپرایز',
                    'غافلگیری با حلقه و دوستان',
                    Icons.card_giftcard_rounded,
                    const SurprisePage(),
                  ),
                  _service(
                    context,
                    'گل‌ریزون',
                    'کمک جمعی برای رویداد یا کار خیر',
                    Icons.volunteer_activism_rounded,
                    const GolrizonPage(),
                  ),
                  _service(
                    context,
                    'همایش',
                    'ثبت‌نام و مدیریت رویدادهای بزرگ',
                    Icons.co_present_rounded,
                    const ConferenceCenterPage(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'پیشنهاد برای تو',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ReservationPage(),
                      ),
                    ),
                    child: const Text('مشاهده همه'),
                  ),
                ],
              ),
              ...appState.events
                  .take(3)
                  .map(
                    (event) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: const Color(0xFF181818),
                        borderRadius: BorderRadius.circular(20),
                        child: ListTile(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EventDetailPage(event: event),
                            ),
                          ),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: event.gradient),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(event.icon, color: Colors.white),
                          ),
                          title: Text(
                            event.title,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          subtitle: Text(
                            '${event.date} • ${event.area} • ${appState.matchScore(event.tags)}٪ سازگاری',
                          ),
                          trailing: const Icon(Icons.chevron_left_rounded),
                        ),
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  Widget _service(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Widget page,
  ) {
    return Material(
      color: const Color(0xFF181818),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: PatoghTheme.orange, size: 30),
              const SizedBox(height: 9),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF999999), fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickLocation(BuildContext context) async {
    final choice = await Navigator.of(context).push<LocationChoice>(
      MaterialPageRoute(
        builder: (_) => IranLocationPickerPage(
          initialProvince: appState.selectedProvince,
          initialCity: appState.selectedCity,
        ),
      ),
    );
    if (choice != null) {
      await appState.setSelectedLocation(choice.province, choice.city);
    }
  }
}
