import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:patogh/config/app_config.dart';
import 'package:patogh/data/mock_data.dart' as mock;
import 'package:patogh/models/chat_message.dart';
import 'package:patogh/models/community.dart';
import 'package:patogh/models/ecosystem_models.dart';
import 'package:patogh/models/patogh_category.dart';
import 'package:patogh/models/patogh_event.dart';
import 'package:patogh/models/role_request.dart';
import 'package:patogh/models/story_item.dart';
import 'package:patogh/models/timeline_post.dart';
import 'package:patogh/models/user_profile.dart';
import 'package:patogh/models/user_role.dart';
import 'package:patogh/models/v8_models.dart';
import 'package:patogh/services/platform_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  SharedPreferences? _prefs;
  StreamSubscription<List<ChatMessage>>? _chatSubscription;

  bool loggedIn = false;
  String phone = '';
  UserProfile? profile;

  final List<PatoghEvent> events = <PatoghEvent>[];
  final List<PatoghCategory> categories = <PatoghCategory>[];

  final Set<String> reservedIds = <String>{};
  final Set<String> waitlistIds = <String>{};
  final Set<String> favoriteIds = <String>{};
  final Set<String> paidIds = <String>{};

  final Map<String, List<ChatMessage>> chats = <String, List<ChatMessage>>{};

  final List<TimelinePost> timelinePosts = <TimelinePost>[
    const TimelinePost(
      id: 'post-1',
      author: 'سارا',
      roleLabel: 'شرکت‌کننده',
      eventTitle: 'قرار صبحانه پاتوق',
      text: 'جمع خیلی صمیمی بود و تعداد کم نفرات باعث شد واقعاً فرصت گفت‌وگو داشته باشیم.',
      createdAt: 'امروز، ۱۰:۴۵',
      likes: 18,
    ),
    const TimelinePost(
      id: 'post-2',
      author: 'آرمان',
      roleLabel: 'شرکت‌کننده',
      eventTitle: 'شب بازی پاتوق',
      text: 'بازی‌ها کمک کرد یخ جمع خیلی سریع باز بشه. برای بار اول تجربه خوبی بود.',
      createdAt: 'دیروز، ۲۱:۱۰',
      likes: 31,
    ),
  ];

  final List<StoryItem> stories = <StoryItem>[
    const StoryItem(
      id: 'story-1',
      owner: 'کافه روشن',
      ownerRole: UserRole.venue,
      title: 'پاتوق امشب',
      subtitle: 'آماده پذیرایی از یک جمع ۸ نفره',
      createdAt: '۱ ساعت پیش',
    ),
    const StoryItem(
      id: 'story-2',
      owner: 'آژانس دورهمی نو',
      ownerRole: UserRole.organizer,
      title: 'رویداد جدید',
      subtitle: 'پاتوق سفر آخر هفته منتشر شد',
      createdAt: '۳ ساعت پیش',
    ),
  ];

  final List<Community> communities = <Community>[
    const Community(
      id: 'community-1',
      title: 'کتاب‌خوان‌های مشهد',
      description: 'گروه آزاد برای معرفی کتاب و هماهنگی پاتوق‌های فکری',
      type: CommunityType.group,
      owner: 'کاربران پاتوق',
      members: 128,
    ),
    const Community(
      id: 'community-2',
      title: 'اعلان رویدادهای مشهد',
      description: 'کانال معرفی رویدادهای جدید و ظرفیت‌های آزادشده',
      type: CommunityType.channel,
      owner: 'پاتوق',
      members: 842,
    ),
  ];

  final List<VenueType> venueTypes = <VenueType>[
    const VenueType(
      id: 'cafe',
      title: 'کافه',
      group: 'خوراک و پذیرایی',
      familyFriendly: true,
    ),
    const VenueType(
      id: 'restaurant',
      title: 'رستوران',
      group: 'خوراک و پذیرایی',
      familyFriendly: true,
    ),
    const VenueType(
      id: 'foodcourt',
      title: 'فودکورت',
      group: 'خوراک و پذیرایی',
      familyFriendly: true,
    ),
    const VenueType(
      id: 'hotel',
      title: 'هتل / هتل‌آپارتمان',
      group: 'اقامت و پذیرایی',
      familyFriendly: true,
    ),
    const VenueType(id: 'hostel', title: 'هاستل / مهمان‌پذیر', group: 'اقامت'),
    const VenueType(
      id: 'ecolodge',
      title: 'بوم‌گردی',
      group: 'گردشگری',
      familyFriendly: true,
    ),
    const VenueType(
      id: 'garden',
      title: 'باغ / باغ‌رستوران',
      group: 'تفریح و پذیرایی',
      familyFriendly: true,
      childFriendly: true,
    ),
    const VenueType(
      id: 'amusement',
      title: 'شهربازی',
      group: 'تفریح و سرگرمی',
      familyFriendly: true,
      childFriendly: true,
    ),
    const VenueType(
      id: 'waterpark',
      title: 'پارک آبی',
      group: 'تفریح و سرگرمی',
      familyFriendly: true,
      childFriendly: true,
    ),
    const VenueType(
      id: 'playhouse',
      title: 'خانه بازی کودک',
      group: 'کودک',
      familyFriendly: true,
      childFriendly: true,
    ),
    const VenueType(
      id: 'kindergarten',
      title: 'مهدکودک',
      group: 'کودک و آموزش',
      familyFriendly: true,
      childFriendly: true,
    ),
    const VenueType(
      id: 'gameclub',
      title: 'کلوپ بازی / گیم‌کلاب',
      group: 'تفریح و سرگرمی',
    ),
    const VenueType(id: 'escape', title: 'اتاق فرار', group: 'تفریح و سرگرمی'),
    const VenueType(
      id: 'bowling',
      title: 'بولینگ',
      group: 'ورزش و تفریح',
      familyFriendly: true,
    ),
    const VenueType(
      id: 'cinema',
      title: 'سینما / سالن نمایش',
      group: 'فرهنگی',
      familyFriendly: true,
    ),
    const VenueType(
      id: 'gallery',
      title: 'نگارخانه / گالری',
      group: 'فرهنگی و هنری',
    ),
    const VenueType(
      id: 'bookstore',
      title: 'کتاب‌فروشی / کتابخانه',
      group: 'فرهنگی',
      familyFriendly: true,
    ),
    const VenueType(
      id: 'historic',
      title: 'خانه تاریخی / موزه',
      group: 'میراث و گردشگری',
      familyFriendly: true,
    ),
    const VenueType(
      id: 'mosque',
      title: 'مسجد / فضای مذهبی',
      group: 'مذهبی و اجتماعی',
      familyFriendly: true,
    ),
    const VenueType(
      id: 'charity',
      title: 'موسسه خیریه / اجتماعی',
      group: 'اجتماعی',
    ),
    const VenueType(
      id: 'sports',
      title: 'باشگاه / مجموعه ورزشی',
      group: 'ورزش',
    ),
    const VenueType(id: 'cowork', title: 'فضای کار اشتراکی', group: 'کسب‌وکار'),
    const VenueType(id: 'education', title: 'مرکز آموزشی', group: 'آموزش'),
    const VenueType(
      id: 'artworkshop',
      title: 'کارگاه هنری',
      group: 'هنر و خلاقیت',
      familyFriendly: true,
      childFriendly: true,
    ),
    const VenueType(
      id: 'farm',
      title: 'مزرعه / مجموعه طبیعت‌گردی',
      group: 'طبیعت و گردشگری',
      familyFriendly: true,
      childFriendly: true,
    ),
    const VenueType(
      id: 'conference',
      title: 'مرکز همایش / سالن',
      group: 'رویداد و سازمانی',
    ),
    const VenueType(
      id: 'mall',
      title: 'مرکز تجاری / مجتمع',
      group: 'تجاری و تفریحی',
      familyFriendly: true,
    ),
  ];

  final List<DependentProfile> dependents = <DependentProfile>[
    const DependentProfile(
      id: 'child-1',
      name: 'نازنین',
      age: 7,
      relation: 'فرزند',
    ),
  ];

  final Map<String, EventAudiencePolicy> eventPolicies =
      <String, EventAudiencePolicy>{
        'dinner-01': const EventAudiencePolicy(
          eventId: 'dinner-01',
          geographicLevel: 'شهری',
          geographicLabel: 'مشهد',
          minAge: 23,
          maxAge: 38,
          genderPolicy: 'عمومی',
          attendanceMode: 'بزرگسال',
          noShowPenalty: 180000,
        ),
        'breakfast-01': const EventAudiencePolicy(
          eventId: 'breakfast-01',
          geographicLevel: 'محلی',
          geographicLabel: 'مشهد - سجاد',
          minAge: 18,
          maxAge: 35,
          genderPolicy: 'عمومی',
          attendanceMode: 'بزرگسال',
          sponsored: true,
          sponsorName: 'شرکت آینده روشن',
          noShowPenalty: 350000,
        ),
        'think-01': const EventAudiencePolicy(
          eventId: 'think-01',
          geographicLevel: 'شهری',
          geographicLabel: 'مشهد',
          minAge: 18,
          maxAge: 55,
          genderPolicy: 'عمومی',
          attendanceMode: 'بزرگسال',
          noShowPenalty: 150000,
        ),
        'women-talk-01': const EventAudiencePolicy(
          eventId: 'women-talk-01',
          geographicLevel: 'شهری',
          geographicLabel: 'مشهد',
          minAge: 20,
          maxAge: 45,
          genderPolicy: 'ویژه بانوان',
          attendanceMode: 'بزرگسال',
          noShowPenalty: 120000,
        ),
        'game-01': const EventAudiencePolicy(
          eventId: 'game-01',
          geographicLevel: 'منطقه‌ای',
          geographicLabel: 'خراسان رضوی',
          minAge: 16,
          maxAge: 40,
          genderPolicy: 'عمومی',
          attendanceMode: 'نوجوان و بزرگسال',
          noShowPenalty: 200000,
        ),
        'kids-01': const EventAudiencePolicy(
          eventId: 'kids-01',
          geographicLevel: 'محلی',
          geographicLabel: 'مشهد - خانواده و کودک',
          minAge: 5,
          maxAge: 9,
          genderPolicy: 'خانوادگی',
          attendanceMode: 'کودک با والد / تحویل امن',
          noShowPenalty: 120000,
        ),
        'work-01': const EventAudiencePolicy(
          eventId: 'work-01',
          geographicLevel: 'کشوری',
          geographicLabel: 'سراسر کشور',
          minAge: 20,
          maxAge: 50,
          genderPolicy: 'عمومی',
          attendanceMode: 'حرفه‌ای',
          sponsored: true,
          sponsorName: 'گروه صنعتی نمونه',
          noShowPenalty: 500000,
        ),
      };

  final List<ReputationProfile> reputations = <ReputationProfile>[
    const ReputationProfile(
      id: 'venue-roshan',
      title: 'کافه روشن',
      entityType: 'میزبان',
      overall: 4.8,
      verifiedReviews: 482,
      confidence: 96,
      claimMatch: 92,
      metrics: {
        'کیفیت محیط': 8.8,
        'برخورد میزبان': 9.3,
        'تطابق معرفی با واقعیت': 9.1,
        'کیفیت پذیرایی': 8.9,
      },
      claims: ['فضای آرام', 'مناسب جمع‌های کوچک', 'پذیرایی باکیفیت'],
      strengths: ['برخورد کارکنان', 'پاکیزگی', 'فضای مناسب گفت‌وگو'],
      improvements: ['سرعت سرویس در ساعات شلوغ'],
    ),
    const ReputationProfile(
      id: 'org-novin',
      title: 'آژانس تجربه نو',
      entityType: 'برگزارکننده',
      overall: 4.6,
      verifiedReviews: 217,
      confidence: 92,
      claimMatch: 88,
      metrics: {
        'نظم زمانی': 8.6,
        'پاسخگویی': 9.0,
        'تطابق برنامه با توضیحات': 8.8,
        'ارزش خرید': 8.4,
      },
      claims: ['برگزاری منظم', 'پشتیبانی قبل از رویداد'],
      strengths: ['پاسخگویی', 'کیفیت برنامه‌ریزی'],
      improvements: ['اطلاع‌رسانی زودتر درباره تغییرات'],
    ),
    const ReputationProfile(
      id: 'coord-demo',
      title: 'مریم رضایی',
      entityType: 'هماهنگ‌کننده',
      overall: 4.7,
      verifiedReviews: 96,
      confidence: 90,
      claimMatch: 93,
      metrics: {
        'مدیریت جمع': 9.2,
        'وقت‌شناسی': 9.0,
        'حل مشکل': 8.9,
        'ارتباط قبل از رویداد': 8.5,
      },
      claims: ['هماهنگی دقیق', 'مدیریت صمیمی و حرفه‌ای'],
      strengths: ['مدیریت جمع', 'حل مسئله'],
      improvements: ['اطلاع‌رسانی محل دقیق زودتر انجام شود'],
    ),
    const ReputationProfile(
      id: 'event-demo',
      title: 'شب بازی پاتوق',
      entityType: 'رویداد',
      overall: 4.9,
      verifiedReviews: 81,
      confidence: 91,
      claimMatch: 95,
      metrics: {
        'جذابیت برنامه': 9.4,
        'ارزش نسبت به هزینه': 9.0,
        'نظم اجرا': 8.8,
        'تمایل به شرکت مجدد': 9.5,
      },
      claims: ['رقابت دوستانه', 'جمع صمیمی'],
      strengths: ['بازی‌های جذاب', 'تعامل بالا'],
      improvements: ['شروع دقیق‌تر در ساعت اعلام‌شده'],
    ),
    const ReputationProfile(
      id: 'user-demo',
      title: 'کاربر پاتوق',
      entityType: 'شرکت‌کننده',
      overall: 4.7,
      verifiedReviews: 34,
      confidence: 84,
      claimMatch: 90,
      metrics: {
        'حضور موفق': 9.4,
        'وقت‌شناسی': 8.9,
        'تعامل محترمانه': 9.2,
        'همکاری با جمع': 8.8,
      },
      claims: ['خوش‌قول', 'علاقه‌مند به گفت‌وگو'],
      strengths: ['حضور منظم', 'تعامل مثبت'],
      improvements: ['لغو دیرهنگام: ۱ مورد'],
    ),
  ];

  final Map<String, int> eventPopularity = <String, int>{
    'dinner-01': 86,
    'breakfast-01': 91,
    'think-01': 84,
    'women-talk-01': 88,
    'game-01': 96,
    'kids-01': 93,
    'work-01': 89,
  };

  final List<EventCommentItem> eventComments = <EventCommentItem>[
    const EventCommentItem(
      id: 'comment-1',
      eventId: 'game-01',
      author: 'سارا',
      text: 'برای کسی که اولین بار میاد هم مناسبه؟',
      createdAt: '۲ ساعت پیش',
    ),
    const EventCommentItem(
      id: 'comment-2',
      eventId: 'kids-01',
      author: 'مریم',
      text: 'والد می‌تونه داخل مجموعه حضور داشته باشه؟',
      createdAt: 'امروز',
    ),
  ];

  final List<FeedbackEntry> feedbackEntries = <FeedbackEntry>[
    const FeedbackEntry(
      id: 'fb-1',
      eventId: 'breakfast-01',
      eventTitle: 'قرار صبحانه پاتوق',
      targetTitle: 'کافه روشن',
      targetType: 'میزبان',
      score: 4.8,
      comment: 'فضا دقیقاً شبیه معرفی بود و سرویس خوبی داشت.',
    ),
    const FeedbackEntry(
      id: 'fb-2',
      eventId: 'game-01',
      eventTitle: 'شب بازی پاتوق',
      targetTitle: 'خود رویداد',
      targetType: 'رویداد',
      score: 4.9,
      comment: 'جمع صمیمی و بازی‌ها جذاب بود.',
    ),
  ];

  final List<EventRequestItem> eventRequests = <EventRequestItem>[
    const EventRequestItem(
      id: 'er-1',
      title: 'پاتوق موسیقی سنتی',
      city: 'مشهد',
      category: 'فرهنگی',
      ageRange: '۱۸ تا ۴۰',
      supporters: 34,
      status: 'در حال بررسی',
    ),
  ];

  final List<MenuItemModel> venueMenu = <MenuItemModel>[
    const MenuItemModel(
      id: 'menu-1',
      title: 'قهوه + کیک',
      category: 'پکیج',
      price: 165000,
      description: 'یک نوشیدنی گرم و یک برش کیک روز',
    ),
    const MenuItemModel(
      id: 'menu-2',
      title: 'صبحانه ایرانی',
      category: 'صبحانه',
      price: 295000,
      description: 'املت، پنیر، گردو، چای و نان تازه',
    ),
    const MenuItemModel(
      id: 'menu-3',
      title: 'نوشیدنی سرد',
      category: 'نوشیدنی',
      price: 110000,
      description: 'انتخاب از منوی نوشیدنی سرد میزبان',
    ),
  ];

  final List<DiscountCampaign> discountCampaigns = <DiscountCampaign>[
    const DiscountCampaign(
      id: 'camp-1',
      title: 'اولین پاتوق',
      code: 'FIRST20',
      audience: 'کاربران جدید',
      percent: 20,
      maxDiscount: 150000,
      status: 'فعال',
    ),
    const DiscountCampaign(
      id: 'camp-2',
      title: 'دوستات رو بیار',
      code: 'GROUP15',
      audience: 'رزرو گروهی ۴ نفر به بالا',
      percent: 15,
      maxDiscount: 400000,
      status: 'فعال',
    ),
  ];

  final List<BannerItem> banners = <BannerItem>[
    const BannerItem(
      id: 'banner-1',
      title: 'جشنواره اولین پاتوق',
      subtitle: '۲۰٪ تخفیف برای اولین تجربه',
      placement: 'home',
      audience: 'کاربران جدید',
      actionLabel: 'مشاهده جشنواره',
    ),
    const BannerItem(
      id: 'banner-2',
      title: 'شب فرهنگی با حمایت آینده روشن',
      subtitle: 'هزینه حضور توسط اسپانسر پرداخت شده است',
      placement: 'home',
      audience: 'کاربران با اعتبار حضور بالا',
      actionLabel: 'مشاهده رویداد',
      sponsored: true,
    ),
    const BannerItem(
      id: 'banner-3',
      title: 'تجربه‌ات را ثبت کن',
      subtitle: 'بازخورد تأییدشده به بهتر شدن میزبان، برگزارکننده و رویداد کمک می‌کند',
      placement: 'timeline',
      audience: 'شرکت‌کنندگان',
      actionLabel: 'ثبت تجربه',
    ),
  ];

  final List<OrganizationAccount> organizations = <OrganizationAccount>[
    const OrganizationAccount(
      id: 'org-1',
      name: 'شرکت نمونه',
      type: 'B2B / B2E',
      employees: 320,
      monthlyBudget: 250000000,
      usedBudget: 138000000,
    ),
  ];

  final List<CorporateRequestItem> corporateRequests = <CorporateRequestItem>[
    const CorporateRequestItem(
      id: 'corp-1',
      title: 'تیم‌سازی واحد محصول',
      city: 'مشهد',
      people: 80,
      budget: 120000000,
      catering: true,
      status: '۳ پیشنهاد دریافت شده',
    ),
  ];

  final List<SponsorshipPlan> sponsorships = <SponsorshipPlan>[
    const SponsorshipPlan(
      id: 'sp-1',
      sponsorName: 'شرکت آینده روشن',
      purpose: 'مسئولیت اجتماعی',
      eventTitle: 'صبحانه گفت‌وگوی نسل جوان',
      capacity: 30,
      invited: 42,
      registered: 26,
      unitCost: 700000,
      status: 'در حال تکمیل ظرفیت',
    ),
    const SponsorshipPlan(
      id: 'sp-2',
      sponsorName: 'خانواده نیک‌اندیش',
      purpose: 'یادبود و عام‌المنفعه',
      eventTitle: 'پاتوق کتاب و کودک',
      capacity: 20,
      invited: 25,
      registered: 20,
      unitCost: 450000,
      status: 'تکمیل ظرفیت - دعوت متوقف',
    ),
  ];

  final List<AttendanceRecord> attendanceHistory = <AttendanceRecord>[
    const AttendanceRecord(
      title: 'قرار صبحانه پاتوق',
      status: 'حضور موفق',
      impact: 3,
    ),
    const AttendanceRecord(title: 'شب بازی', status: 'حضور موفق', impact: 3),
    const AttendanceRecord(
      title: 'پاتوق فکری',
      status: 'لغو به‌موقع',
      impact: 0,
    ),
  ];

  int outstandingDebt = 0;
  int attendanceReputation = 94;

  final Set<UserRole> enabledRoles = <UserRole>{UserRole.participant};
  UserRole activeRole = UserRole.participant;

  String selectedProvince = 'خراسان رضوی';
  String selectedCity = 'مشهد';

  final List<SocialLinkItem> socialLinks = <SocialLinkItem>[
    const SocialLinkItem(
      id: 'social-1',
      platform: 'اینستاگرام',
      handleOrUrl: '@patogh_demo',
      visibility: SocialLinkVisibility.mutual,
    ),
    const SocialLinkItem(
      id: 'social-2',
      platform: 'ایتا',
      handleOrUrl: 'eitaa.com/patogh_demo',
      visibility: SocialLinkVisibility.circle,
    ),
  ];

  final List<CircleMember> circleMembers = <CircleMember>[
    const CircleMember(
      id: 'circle-1',
      name: 'سارا',
      relation: 'دوست نزدیک',
      accepted: true,
      notifyOnEventJoin: true,
    ),
    const CircleMember(
      id: 'circle-2',
      name: 'مهدی',
      relation: 'برادر',
      accepted: true,
      notifyOnEventJoin: false,
    ),
    const CircleMember(
      id: 'circle-3',
      name: 'ندا',
      relation: 'دوست',
      accepted: false,
    ),
  ];

  final List<FamiliarFace> familiarFaces = <FamiliarFace>[
    const FamiliarFace(
      name: 'هم‌پاتوقی آشنا ۱',
      sharedEvents: 3,
      mutualReconnect: true,
    ),
    const FamiliarFace(name: 'هم‌پاتوقی آشنا ۲', sharedEvents: 1),
  ];

  final List<EventTimeOption> eventTimeOptions = <EventTimeOption>[
    const EventTimeOption(
      id: 'time-1',
      label: 'پنجشنبه ۱۸:۰۰',
      yes: 34,
      maybe: 8,
    ),
    const EventTimeOption(
      id: 'time-2',
      label: 'پنجشنبه ۲۰:۰۰',
      yes: 51,
      maybe: 11,
    ),
    const EventTimeOption(id: 'time-3', label: 'جمعه ۱۷:۰۰', yes: 69, maybe: 9),
  ];

  final List<DynamicRegistrationQuestion> registrationQuestions =
      <DynamicRegistrationQuestion>[
        const DynamicRegistrationQuestion(
          id: 'q-1',
          label: 'قوانین حضور این رویداد را می‌پذیرم',
          type: 'رضایت‌نامه',
          required: true,
        ),
        const DynamicRegistrationQuestion(
          id: 'q-2',
          label: 'اگر محدودیت غذایی داری بنویس',
          type: 'متن',
        ),
        const DynamicRegistrationQuestion(
          id: 'q-3',
          label: 'شماره تماس اضطراری',
          type: 'شماره',
          required: true,
        ),
      ];

  final List<MembershipClub> membershipClubs = <MembershipClub>[
    const MembershipClub(
      id: 'club-1',
      title: 'باشگاه کتاب مشهد',
      subtitle: 'اولویت رزرو پاتوق‌های فکری و کانال اختصاصی',
      monthlyPrice: 0,
      members: 384,
      joined: true,
    ),
    const MembershipClub(
      id: 'club-2',
      title: 'پاتوق پلاس',
      subtitle: 'تخفیف کارمزد، اولویت Waitlist و رویدادهای ویژه',
      monthlyPrice: 350000,
      members: 126,
    ),
  ];

  final List<EventAlbumEntry> eventAlbum = <EventAlbumEntry>[
    const EventAlbumEntry(
      id: 'album-1',
      eventTitle: 'قرار صبحانه پاتوق',
      author: 'سارا',
      caption: 'عکس گروهی با رضایت اعضا',
    ),
    const EventAlbumEntry(
      id: 'album-2',
      eventTitle: 'شب بازی پاتوق',
      author: 'آرمان',
      caption: 'لحظه آخر بازی گروهی',
    ),
  ];

  final List<RoleRequest> roleRequests = <RoleRequest>[
    const RoleRequest(
      id: 'req-venue-1',
      applicantName: 'کافه روشن',
      requestedRole: UserRole.venue,
      note: 'درخواست ثبت به‌عنوان کسب‌وکار میزبان در مشهد',
    ),
    const RoleRequest(
      id: 'req-organizer-1',
      applicantName: 'آژانس تجربه شهر',
      requestedRole: UserRole.organizer,
      note: 'ارائه رویدادهای گردشگری و فرهنگی',
    ),
    const RoleRequest(
      id: 'req-coordinator-1',
      applicantName: 'مریم رضایی',
      requestedRole: UserRole.coordinator,
      note: 'سابقه هماهنگی رویداد و مدیریت جمع',
    ),
  ];

  UserRole get role => activeRole;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    loggedIn = _prefs?.getBool('logged_in') ?? false;
    phone = _prefs?.getString('phone') ?? '';

    final storedRoles =
        _prefs?.getStringList('enabled_roles') ?? const <String>[];
    enabledRoles
      ..clear()
      ..add(UserRole.participant)
      ..addAll(storedRoles.map(UserRoleX.fromKey));
    activeRole = UserRoleX.fromKey(_prefs?.getString('active_role'));
    if (!enabledRoles.contains(activeRole)) activeRole = UserRole.participant;

    selectedProvince = _prefs?.getString('selected_province') ?? 'خراسان رضوی';
    selectedCity = _prefs?.getString('selected_city') ?? 'مشهد';

    final profileRaw = _prefs?.getString('profile');
    if (profileRaw != null && profileRaw.isNotEmpty) {
      profile = UserProfile.fromJson(
        Map<String, dynamic>.from(jsonDecode(profileRaw) as Map),
      );

      if (profile != null && profile!.role != UserRole.participant) {
        enabledRoles.add(profile!.role);
        if (_prefs?.getString('active_role') == null) {
          activeRole = profile!.role;
        }
      }
    }

    _loadLocalSets();
    _loadLocalChats();

    events
      ..clear()
      ..addAll(mock.events);

    categories
      ..clear()
      ..addAll(mock.categories);
    _loadCustomCategories();

    if (AppConfig.useSupabase) {
      loggedIn = PlatformServices.hasRemoteSession;

      final remoteEvents = await PlatformServices.fetchEvents();
      if (remoteEvents.isNotEmpty) {
        events
          ..clear()
          ..addAll(remoteEvents);
      }

      final remoteCategories = await PlatformServices.fetchCategoriesV6();
      if (remoteCategories.isNotEmpty) {
        categories
          ..clear()
          ..addAll(
            remoteCategories.map(
              (row) => PatoghCategory.fromJson({
                'id': row['id'],
                'title': row['title'],
                'subtitle': row['subtitle'],
                'iconCodePoint': row['icon_code_point'],
                'colorValue': row['color_value'],
                'sortOrder': row['sort_order'],
                'isActive': row['is_active'],
              }),
            ),
          );
      }

      if (loggedIn) {
        final remoteProfile = await PlatformServices.loadProfile();
        if (remoteProfile != null) {
          profile = remoteProfile;
          await _persistProfile();
        }

        await _syncReservationsFromRemote();
        favoriteIds
          ..clear()
          ..addAll(await PlatformServices.fetchFavorites());

        await _persistSets();
        await PlatformServices.registerPushToken();

        final remoteTimeline = await PlatformServices.fetchTimelineV6();
        if (remoteTimeline.isNotEmpty) {
          timelinePosts
            ..clear()
            ..addAll(
              remoteTimeline.map(
                (row) => TimelinePost(
                  id: '${row['id']}',
                  author: (row['author_name'] as String?) ?? 'کاربر پاتوق',
                  roleLabel: (row['role_label'] as String?) ?? 'شرکت‌کننده',
                  eventTitle: (row['event_title'] as String?) ?? 'پاتوق',
                  text: (row['text'] as String?) ?? '',
                  createdAt: 'آنلاین',
                ),
              ),
            );
        }

        final remoteStories = await PlatformServices.fetchStoriesV6();
        if (remoteStories.isNotEmpty) {
          stories
            ..clear()
            ..addAll(
              remoteStories.map(
                (row) => StoryItem(
                  id: '${row['id']}',
                  owner: (row['owner_name'] as String?) ?? 'پاتوق',
                  ownerRole: UserRoleX.fromKey(row['owner_role'] as String?),
                  title: (row['title'] as String?) ?? 'استوری',
                  subtitle: (row['subtitle'] as String?) ?? '',
                  createdAt: 'آنلاین',
                ),
              ),
            );
        }

        final remoteCommunities = await PlatformServices.fetchCommunitiesV6();
        if (remoteCommunities.isNotEmpty) {
          communities
            ..clear()
            ..addAll(
              remoteCommunities.map(
                (row) => Community(
                  id: '${row['id']}',
                  title: (row['title'] as String?) ?? 'گروه پاتوق',
                  description: (row['description'] as String?) ?? '',
                  type: row['community_type'] == 'channel'
                      ? CommunityType.channel
                      : CommunityType.group,
                  owner: (row['owner_name'] as String?) ?? 'کاربر پاتوق',
                  members: (row['member_count'] as num?)?.toInt() ?? 1,
                ),
              ),
            );
        }

        if (role == UserRole.admin) {
          final remoteRoleRequests =
              await PlatformServices.fetchRoleRequestsV6();
          if (remoteRoleRequests.isNotEmpty) {
            roleRequests
              ..clear()
              ..addAll(
                remoteRoleRequests.map(
                  (row) => RoleRequest(
                    id: '${row['id']}',
                    applicantName: 'کاربر درخواست‌دهنده',
                    requestedRole: UserRoleX.fromKey(
                      row['requested_role'] as String?,
                    ),
                    note: (row['note'] as String?) ?? '',
                    status: (row['status'] as String?) ?? 'pending',
                  ),
                ),
              );
          }
        }
      }
    }

    chats.putIfAbsent(
      'support',
      () => const [
        ChatMessage(
          text: 'سلام! به پشتیبانی پاتوق خوش اومدی.',
          mine: false,
          time: '۱۰:۳۰',
        ),
      ],
    );
  }

  Future<void> requestOtp(String phoneNumber) =>
      PlatformServices.requestOtp(phoneNumber);

  Future<void> verifyOtp(String phoneNumber, String code) async {
    await PlatformServices.verifyOtp(phoneNumber, code);

    phone = phoneNumber;
    loggedIn = true;

    await _prefs?.setBool('logged_in', true);
    await _prefs?.setString('phone', phoneNumber);

    if (AppConfig.useSupabase) {
      final remoteProfile = await PlatformServices.loadProfile();
      if (remoteProfile != null) {
        profile = remoteProfile;
        await _persistProfile();
      }

      await _syncReservationsFromRemote();
      favoriteIds
        ..clear()
        ..addAll(await PlatformServices.fetchFavorites());
      await PlatformServices.registerPushToken();
    }

    notifyListeners();
  }

  Future<void> logout() async {
    await PlatformServices.signOut();
    loggedIn = false;
    await _prefs?.setBool('logged_in', false);
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile newProfile) async {
    profile = newProfile;
    await _persistProfile();
    await PlatformServices.saveProfile(newProfile);
    notifyListeners();
  }

  Future<void> setDemoRole(UserRole newRole) async {
    enabledRoles.add(newRole);
    activeRole = newRole;
    await _persistRoles();
    notifyListeners();
  }

  Future<void> configureInitialRoles(Set<UserRole> roles) async {
    enabledRoles
      ..clear()
      ..add(UserRole.participant)
      ..addAll(roles.where((role) => role != UserRole.admin));
    activeRole = UserRole.participant;
    await _persistRoles();
    notifyListeners();
  }

  Future<void> switchRole(UserRole newRole) async {
    if (!enabledRoles.contains(newRole)) return;
    activeRole = newRole;
    await _persistRoles();
    notifyListeners();
  }

  Future<void> setSelectedLocation(String province, String city) async {
    selectedProvince = province;
    selectedCity = city;
    await _prefs?.setString('selected_province', province);
    await _prefs?.setString('selected_city', city);
    notifyListeners();
  }

  Future<void> addSocialLink({
    required String platform,
    required String url,
    required SocialLinkVisibility visibility,
  }) async {
    socialLinks.add(
      SocialLinkItem(
        id: 'social-${DateTime.now().microsecondsSinceEpoch}',
        platform: platform,
        handleOrUrl: url,
        visibility: visibility,
      ),
    );
    notifyListeners();
  }

  Future<void> setSocialLinkVisibility(
    String id,
    SocialLinkVisibility visibility,
  ) async {
    final index = socialLinks.indexWhere((item) => item.id == id);
    if (index == -1) return;
    socialLinks[index] = socialLinks[index].copyWith(visibility: visibility);
    notifyListeners();
  }

  Future<void> addCircleMember(String name, String relation) async {
    circleMembers.add(
      CircleMember(
        id: 'circle-${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        relation: relation.isEmpty ? 'دوست' : relation,
      ),
    );
    notifyListeners();
  }

  Future<void> toggleCircleNotification(String id) async {
    final index = circleMembers.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final current = circleMembers[index];
    circleMembers[index] = current.copyWith(
      notifyOnEventJoin: !current.notifyOnEventJoin,
    );
    notifyListeners();
  }

  Future<void> toggleMembershipClub(String id) async {
    final index = membershipClubs.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final current = membershipClubs[index];
    membershipClubs[index] = current.copyWith(
      joined: !current.joined,
      members: current.joined ? current.members - 1 : current.members + 1,
    );
    notifyListeners();
  }

  Future<void> requestRole(UserRole requestedRole, String note) async {
    await PlatformServices.requestRoleV6(requestedRole.key, note);
    roleRequests.insert(
      0,
      RoleRequest(
        id: 'request-${DateTime.now().microsecondsSinceEpoch}',
        applicantName: profile?.name ?? 'کاربر پاتوق',
        requestedRole: requestedRole,
        note: note,
      ),
    );
    notifyListeners();
  }

  Future<void> approveRoleRequest(String requestId) async {
    await PlatformServices.reviewRoleRequestV6(requestId, true);
    final index = roleRequests.indexWhere((request) => request.id == requestId);
    if (index == -1) return;
    roleRequests[index] = roleRequests[index].copyWith(status: 'approved');
    notifyListeners();
  }

  Future<void> rejectRoleRequest(String requestId) async {
    await PlatformServices.reviewRoleRequestV6(requestId, false);
    final index = roleRequests.indexWhere((request) => request.id == requestId);
    if (index == -1) return;
    roleRequests[index] = roleRequests[index].copyWith(status: 'rejected');
    notifyListeners();
  }

  Future<void> addCategory(PatoghCategory category) async {
    await PlatformServices.saveCategoryV6({
      'id': category.id,
      'title': category.title,
      'subtitle': category.subtitle,
      'icon_code_point': category.iconCodePoint,
      'color_value': category.colorValue,
      'sort_order': category.sortOrder,
      'is_active': category.isActive,
    });
    categories.add(category);
    categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    await _persistCategories();
    notifyListeners();
  }

  Future<void> toggleCategory(String categoryId) async {
    final index = categories.indexWhere(
      (category) => category.id == categoryId,
    );
    if (index == -1) return;
    categories[index] = categories[index].copyWith(
      isActive: !categories[index].isActive,
    );
    await PlatformServices.toggleCategoryV6(
      categoryId,
      categories[index].isActive,
    );
    await _persistCategories();
    notifyListeners();
  }

  Future<void> addTimelinePost({
    required String eventTitle,
    required String text,
  }) async {
    String? eventId;
    for (final event in events) {
      if (event.title == eventTitle) {
        eventId = event.id;
        break;
      }
    }
    await PlatformServices.addTimelinePostV6(
      text: text,
      authorName: profile?.name ?? 'کاربر پاتوق',
      roleLabel: role.label,
      eventTitle: eventTitle,
      eventId: eventId,
    );
    timelinePosts.insert(
      0,
      TimelinePost(
        id: 'post-${DateTime.now().microsecondsSinceEpoch}',
        author: profile?.name ?? 'کاربر پاتوق',
        roleLabel: role.label,
        eventTitle: eventTitle,
        text: text,
        createdAt: 'همین الان',
      ),
    );
    notifyListeners();
  }

  Future<void> likeTimelinePost(String postId) async {
    final index = timelinePosts.indexWhere((post) => post.id == postId);
    if (index == -1) return;
    timelinePosts[index] = timelinePosts[index].copyWith(
      likes: timelinePosts[index].likes + 1,
    );
    notifyListeners();
  }

  Future<void> addStory({
    required String title,
    required String subtitle,
  }) async {
    await PlatformServices.addStoryV6(
      title: title,
      subtitle: subtitle,
      ownerName: profile?.name ?? role.label,
      ownerRole: role.key,
    );
    stories.insert(
      0,
      StoryItem(
        id: 'story-${DateTime.now().microsecondsSinceEpoch}',
        owner: profile?.name ?? role.label,
        ownerRole: role,
        title: title,
        subtitle: subtitle,
        createdAt: 'همین الان',
      ),
    );
    notifyListeners();
  }

  Future<void> createCommunity({
    required String title,
    required String description,
    required CommunityType type,
  }) async {
    await PlatformServices.createCommunityV6(
      title: title,
      description: description,
      type: type == CommunityType.channel ? 'channel' : 'group',
      ownerName: profile?.name ?? 'کاربر پاتوق',
    );
    communities.insert(
      0,
      Community(
        id: 'community-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        description: description,
        type: type,
        owner: profile?.name ?? 'کاربر پاتوق',
        members: 1,
        joined: true,
      ),
    );
    notifyListeners();
  }

  Future<void> toggleCommunityMembership(String communityId) async {
    final index = communities.indexWhere(
      (community) => community.id == communityId,
    );
    if (index == -1) return;
    final current = communities[index];
    communities[index] = current.copyWith(
      joined: !current.joined,
      members: current.joined
          ? (current.members - 1).clamp(0, 1000000)
          : current.members + 1,
    );
    notifyListeners();
  }

  EventAudiencePolicy policyForEvent(String eventId) {
    return eventPolicies[eventId] ??
        EventAudiencePolicy(
          eventId: eventId,
          geographicLevel: 'شهری',
          geographicLabel: profile?.city ?? 'مشهد',
          minAge: 18,
          maxAge: 65,
          genderPolicy: 'عمومی',
          attendanceMode: 'بزرگسال',
          noShowPenalty: 150000,
        );
  }

  ReputationProfile reputationById(String id) {
    return reputations.firstWhere(
      (item) => item.id == id,
      orElse: () => reputations.first,
    );
  }

  Future<void> addVenueType({
    required String title,
    required String group,
    bool familyFriendly = false,
    bool childFriendly = false,
  }) async {
    venueTypes.add(
      VenueType(
        id: 'venue-type-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        group: group,
        familyFriendly: familyFriendly,
        childFriendly: childFriendly,
      ),
    );
    notifyListeners();
  }

  Future<void> addBanner({
    required String title,
    required String subtitle,
    required String placement,
    required String audience,
    bool sponsored = false,
  }) async {
    banners.insert(
      0,
      BannerItem(
        id: 'banner-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        subtitle: subtitle,
        placement: placement,
        audience: audience,
        actionLabel: 'مشاهده',
        sponsored: sponsored,
      ),
    );
    notifyListeners();
  }

  Future<void> addCorporateRequest({
    required String title,
    required String city,
    required int people,
    required int budget,
    required bool catering,
  }) async {
    corporateRequests.insert(
      0,
      CorporateRequestItem(
        id: 'corporate-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        city: city,
        people: people,
        budget: budget,
        catering: catering,
        status: 'در انتظار پیشنهاد میزبان‌ها و آژانس‌ها',
      ),
    );
    notifyListeners();
  }

  Future<void> addSponsorship({
    required String sponsorName,
    required String purpose,
    required String eventTitle,
    required int capacity,
    required int unitCost,
  }) async {
    sponsorships.insert(
      0,
      SponsorshipPlan(
        id: 'sponsorship-${DateTime.now().microsecondsSinceEpoch}',
        sponsorName: sponsorName,
        purpose: purpose,
        eventTitle: eventTitle,
        capacity: capacity,
        invited: 0,
        registered: 0,
        unitCost: unitCost,
        status: 'آماده شروع دعوت هدفمند',
      ),
    );
    notifyListeners();
  }

  Future<void> addDiscountCampaign({
    required String title,
    required String code,
    required String audience,
    required int percent,
    required int maxDiscount,
  }) async {
    discountCampaigns.insert(
      0,
      DiscountCampaign(
        id: 'campaign-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        code: code.toUpperCase(),
        audience: audience,
        percent: percent,
        maxDiscount: maxDiscount,
        status: 'فعال',
      ),
    );
    notifyListeners();
  }

  Future<void> addDependent(String name, int age, String relation) async {
    dependents.add(
      DependentProfile(
        id: 'dependent-${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        age: age,
        relation: relation,
      ),
    );
    notifyListeners();
  }

  Future<void> addEventRequest({
    required String title,
    required String city,
    required String category,
    required String ageRange,
  }) async {
    eventRequests.insert(
      0,
      EventRequestItem(
        id: 'request-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        city: city,
        category: category,
        ageRange: ageRange,
        supporters: 1,
        status: 'در انتظار بررسی ادمین',
      ),
    );
    notifyListeners();
  }

  Future<void> supportEventRequest(String id) async {
    final index = eventRequests.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final current = eventRequests[index];
    eventRequests[index] = EventRequestItem(
      id: current.id,
      title: current.title,
      city: current.city,
      category: current.category,
      ageRange: current.ageRange,
      supporters: current.supporters + 1,
      status: current.status,
    );
    notifyListeners();
  }

  Future<void> addMenuItem({
    required String title,
    required String category,
    required int price,
    required String description,
  }) async {
    venueMenu.add(
      MenuItemModel(
        id: 'menu-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        category: category,
        price: price,
        description: description,
      ),
    );
    notifyListeners();
  }

  int calculateDiscount(String code, int subtotal) {
    final normalized = code.trim().toUpperCase();
    for (final campaign in discountCampaigns) {
      if (campaign.code == normalized && campaign.status == 'فعال') {
        final raw = subtotal * campaign.percent ~/ 100;
        return raw > campaign.maxDiscount ? campaign.maxDiscount : raw;
      }
    }
    return 0;
  }

  int popularityForEvent(String eventId) => eventPopularity[eventId] ?? 75;

  Future<void> addEventComment(String eventId, String text) async {
    eventComments.insert(
      0,
      EventCommentItem(
        id: 'comment-${DateTime.now().microsecondsSinceEpoch}',
        eventId: eventId,
        author: profile?.name ?? 'کاربر پاتوق',
        text: text,
        createdAt: 'همین الان',
      ),
    );
    notifyListeners();
  }

  Future<void> addFeedback({
    required String eventId,
    required String eventTitle,
    required String targetTitle,
    required String targetType,
    required double score,
    required String comment,
  }) async {
    feedbackEntries.insert(
      0,
      FeedbackEntry(
        id: 'feedback-${DateTime.now().microsecondsSinceEpoch}',
        eventId: eventId,
        eventTitle: eventTitle,
        targetTitle: targetTitle,
        targetType: targetType,
        score: score,
        comment: comment,
      ),
    );
    notifyListeners();
  }

  Future<void> applyNoShowPenalty({
    required int eventCost,
    required int penalty,
  }) async {
    outstandingDebt += eventCost + penalty;
    attendanceReputation = (attendanceReputation - 22).clamp(0, 100).toInt();
    notifyListeners();
  }

  Future<void> settleDebt() async {
    outstandingDebt = 0;
    notifyListeners();
  }

  Future<void> reserve(String eventId) async {
    final status = await PlatformServices.reserveEvent(eventId);
    if (status == 'waitlist') {
      waitlistIds.add(eventId);
      reservedIds.remove(eventId);
    } else {
      reservedIds.add(eventId);
      waitlistIds.remove(eventId);
    }
    await _persistSets();
    notifyListeners();
  }

  Future<void> payAndReserve(String eventId) async {
    paidIds.add(eventId);
    final status = await PlatformServices.reserveEvent(eventId);
    if (status == 'waitlist') {
      waitlistIds.add(eventId);
      reservedIds.remove(eventId);
    } else {
      reservedIds.add(eventId);
      waitlistIds.remove(eventId);
    }
    await _persistSets();
    notifyListeners();
  }

  Future<void> joinWaitlist(String eventId) async {
    final status = await PlatformServices.reserveEvent(
      eventId,
      waitlistOnly: true,
    );
    if (status == 'reserved') {
      reservedIds.add(eventId);
      waitlistIds.remove(eventId);
    } else {
      waitlistIds.add(eventId);
    }
    await _persistSets();
    notifyListeners();
  }

  Future<void> cancelReservation(String eventId) async {
    reservedIds.remove(eventId);
    waitlistIds.remove(eventId);
    paidIds.remove(eventId);
    await PlatformServices.cancelReservation(eventId);
    await _persistSets();
    notifyListeners();
  }

  Future<void> toggleFavorite(String eventId) async {
    final becomingFavorite = !favoriteIds.contains(eventId);
    if (becomingFavorite) {
      favoriteIds.add(eventId);
    } else {
      favoriteIds.remove(eventId);
    }
    await PlatformServices.setFavorite(eventId, becomingFavorite);
    await _persistSets();
    notifyListeners();
  }

  Future<void> sendMessage(String roomId, String text) async {
    if (AppConfig.useSupabase) {
      await PlatformServices.sendMessage(roomId, text);
      return;
    }
    final list = chats.putIfAbsent(roomId, () => <ChatMessage>[]);
    list.add(ChatMessage(text: text, mine: true, time: _timeNow()));
    await _persistChats();
    notifyListeners();
  }

  Future<void> startChatRoom(String roomId) async {
    await _chatSubscription?.cancel();
    if (!AppConfig.useSupabase) return;
    chats[roomId] = await PlatformServices.fetchMessages(roomId);
    notifyListeners();
    _chatSubscription = PlatformServices.watchMessages(roomId)
        .listen((messages) {
          chats[roomId] = messages;
          notifyListeners();
        });
  }

  Future<void> stopChatRoom() async {
    await _chatSubscription?.cancel();
    _chatSubscription = null;
  }

  List<ChatMessage> roomMessages(String roomId) {
    return chats.putIfAbsent(
      roomId,
      () => const [
        ChatMessage(text: 'خوش اومدین 👋', mine: false, time: '۱۸:۰۰'),
      ],
    );
  }

  int matchScore(List<String> eventTags) {
    final interests = profile?.interests ?? const <String>[];
    if (interests.isEmpty || eventTags.isEmpty) return 72;
    var overlap = 0;
    for (final interest in interests) {
      if (eventTags.any(
        (tag) => tag.contains(interest) || interest.contains(tag),
      )) {
        overlap++;
      }
    }
    return (72 + overlap * 8).clamp(72, 98);
  }

  Future<void> setEventPolicy(EventAudiencePolicy policy) async {
    eventPolicies[policy.eventId] = policy;
    notifyListeners();
  }

  Future<void> createEvent(PatoghEvent event) async {
    await PlatformServices.createEvent(event);
    events.insert(0, event);
    notifyListeners();
  }

  Future<void> _syncReservationsFromRemote() async {
    final statuses = await PlatformServices.fetchMyReservations();
    reservedIds.clear();
    waitlistIds.clear();
    for (final entry in statuses.entries) {
      if (entry.value == 'reserved' || entry.value == 'confirmed') {
        reservedIds.add(entry.key);
      } else if (entry.value == 'waitlist') {
        waitlistIds.add(entry.key);
      }
    }
    await _persistSets();
  }

  void _loadLocalSets() {
    reservedIds
      ..clear()
      ..addAll(_prefs?.getStringList('reserved_ids') ?? <String>[]);
    waitlistIds
      ..clear()
      ..addAll(_prefs?.getStringList('waitlist_ids') ?? <String>[]);
    favoriteIds
      ..clear()
      ..addAll(_prefs?.getStringList('favorite_ids') ?? <String>[]);
    paidIds
      ..clear()
      ..addAll(_prefs?.getStringList('paid_ids') ?? <String>[]);
  }

  void _loadLocalChats() {
    final chatRaw = _prefs?.getString('chats');
    if (chatRaw == null || chatRaw.isEmpty) return;
    final decoded = Map<String, dynamic>.from(jsonDecode(chatRaw) as Map);
    for (final entry in decoded.entries) {
      chats[entry.key] = (entry.value as List)
          .map(
            (item) =>
                ChatMessage.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    }
  }

  void _loadCustomCategories() {
    final raw = _prefs?.getString('custom_categories');
    if (raw == null || raw.isEmpty) return;

    final stored = (jsonDecode(raw) as List)
        .map(
          (item) =>
              PatoghCategory.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();

    for (final category in stored) {
      final index = categories.indexWhere((item) => item.id == category.id);
      if (index == -1) {
        categories.add(category);
      } else {
        categories[index] = category;
      }
    }

    categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Future<void> _persistRoles() async {
    await _prefs?.setStringList(
      'enabled_roles',
      enabledRoles.map((role) => role.key).toList(),
    );
    await _prefs?.setString('active_role', activeRole.key);
  }

  Future<void> _persistProfile() async {
    final current = profile;
    if (current == null) return;
    await _prefs?.setString('profile', jsonEncode(current.toJson()));
  }

  Future<void> _persistSets() async {
    await _prefs?.setStringList('reserved_ids', reservedIds.toList());
    await _prefs?.setStringList('waitlist_ids', waitlistIds.toList());
    await _prefs?.setStringList('favorite_ids', favoriteIds.toList());
    await _prefs?.setStringList('paid_ids', paidIds.toList());
  }

  Future<void> _persistChats() async {
    final encoded = <String, dynamic>{};
    for (final entry in chats.entries) {
      encoded[entry.key] = entry.value
          .map((message) => message.toJson())
          .toList();
    }
    await _prefs?.setString('chats', jsonEncode(encoded));
  }

  Future<void> _persistCategories() async {
    await _prefs?.setString(
      'custom_categories',
      jsonEncode(categories.map((category) => category.toJson()).toList()),
    );
  }

  String _timeNow() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

final AppState appState = AppState();
