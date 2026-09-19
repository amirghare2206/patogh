import 'package:flutter/material.dart';
import 'package:patogh/pages/campaigns_page.dart';
import 'package:patogh/pages/dependents_page.dart';
import 'package:patogh/pages/enterprise_page.dart';
import 'package:patogh/pages/event_request_page.dart';
import 'package:patogh/pages/feedback_center_page.dart';
import 'package:patogh/pages/sponsorship_page.dart';
import 'package:patogh/pages/venue_types_page.dart';
import 'package:patogh/pages/social_links_page.dart';
import 'package:patogh/pages/my_circle_page.dart';
import 'package:patogh/pages/membership_clubs_page.dart';
import 'package:patogh/pages/social_discovery_page.dart';
import 'package:patogh/pages/ai_concierge_page.dart';
import 'package:patogh/pages/iran_location_picker_page.dart';
import 'package:patogh/pages/memories_library_page.dart';
import 'package:patogh/pages/private_events_page.dart';
import 'package:patogh/pages/conference_center_page.dart';
import 'package:patogh/pages/time_occasion_hub_page.dart';
import 'package:patogh/pages/memorial_center_page.dart';
import 'package:patogh/theme/patogh_theme.dart';

class EcosystemHubPage extends StatelessWidget {
  const EcosystemHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <(String, String, IconData, Widget)>[
      (
        'اعتبار و بازخورد',
        'امتیاز موجودیت‌ها، حضور و تطابق ادعا با واقعیت',
        Icons.verified_rounded,
        const FeedbackCenterPage(),
      ),
      (
        'درخواست رویداد',
        'رویدادی نیست؟ تقاضا را به ادمین و برگزارکننده‌ها برسان',
        Icons.add_task_rounded,
        const EventRequestPage(),
      ),
      (
        'فرزندان و سرپرستی',
        'ثبت‌نام کودک توسط والد و پروفایل وابسته',
        Icons.family_restroom_rounded,
        const DependentsPage(),
      ),
      (
        'انواع میزبان',
        'از کافه و هتل تا بوم‌گردی، مسجد، شهربازی و خانه بازی',
        Icons.storefront_rounded,
        const VenueTypesPage(),
      ),
      (
        'جشنواره و تخفیف',
        'کمپین، کد تخفیف و مشوق‌های رشد',
        Icons.discount_rounded,
        const CampaignsPage(),
      ),
      (
        'پاتوق سازمانی',
        'B2B، B2E، بودجه کارمند و پذیرایی شرکتی',
        Icons.apartment_rounded,
        const EnterprisePage(),
      ),
      (
        'اسپانسرینگ',
        'حمایت کامل یا جزئی و دعوت ظرفیت‌محور کاربران',
        Icons.volunteer_activism_rounded,
        const SponsorshipPage(),
      ),
      (
        'نقشه ایران',
        'انتخاب یکپارچه استان و شهر برای پروفایل، میزبانی و رویداد',
        Icons.map_rounded,
        const IranLocationPickerPage(),
      ),
      (
        'حلقه من',
        'دوستان، خانواده و اعلان اختیاری شرکت در رویداد',
        Icons.diversity_1_rounded,
        const MyCirclePage(),
      ),
      (
        'شبکه‌های اجتماعی',
        'لینک شبکه‌های ایرانی و خارجی با سطح دسترسی',
        Icons.link_rounded,
        const SocialLinksPage(),
      ),
      (
        'تعامل هوشمند',
        'Familiar Faces، Repeat، رأی زمان، فرم پویا و آلبوم',
        Icons.people_alt_rounded,
        const SocialDiscoveryPage(),
      ),
      (
        'باشگاه‌های پاتوق',
        'عضویت رایگان/اشتراکی و رویدادهای مخصوص اعضا',
        Icons.workspace_premium_rounded,
        const MembershipClubsPage(),
      ),
      (
        'دستیار پاتوق',
        'پیشنهاد تجربه با توضیح طبیعی کاربر',
        Icons.auto_awesome_rounded,
        const AiConciergePage(),
      ),
      (
        'خاطرات و سالگردها',
        'کپسول خاطره، آلبوم شخصی/مشترک و سالگرد رویداد',
        Icons.photo_album_rounded,
        const MemoriesLibraryPage(),
      ),
      (
        'زمان و مناسبت‌ها',
        'تقویم ایران و جهان، شخصی، ورزشی و موتور فرصت رویداد',
        Icons.calendar_month_rounded,
        const TimeOccasionHubPage(),
      ),
      (
        'مموریال',
        'یادبود، دفتر خاطره، سالگرد و گل‌ریزون به نام فرد درگذشته',
        Icons.local_florist_rounded,
        const MemorialCenterPage(),
      ),
      (
        'مراسم خصوصی',
        'عروسی، تولد، یادبود و کارت دعوت دیجیتال با RSVP',
        Icons.mark_email_read_rounded,
        const PrivateEventsPage(),
      ),
      (
        'همایش و کنفرانس',
        'ثبت‌نام، بلیت، QR، سخنران، اسپانسر و گواهی حضور',
        Icons.co_present_rounded,
        const ConferenceCenterPage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('اکوسیستم پاتوق'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: items.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: const Color(0xFF181818),
              borderRadius: BorderRadius.circular(19),
              child: ListTile(
                onTap: () =>
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => item.$4)),
                leading: Icon(item.$3, color: PatoghTheme.orange),
                title: Text(
                  item.$1,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  item.$2,
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 10,
                  ),
                ),
                trailing: const Icon(Icons.chevron_left_rounded),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
