import 'package:flutter/foundation.dart';
import 'package:patogh/models/v11_models.dart';

class V11State extends ChangeNotifier {
  final Set<PatoghCalendarLayer> enabledLayers = {
    PatoghCalendarLayer.iranOfficial,
    PatoghCalendarLayer.islamic,
    PatoghCalendarLayer.iranianHeritage,
    PatoghCalendarLayer.global,
    PatoghCalendarLayer.sports,
    PatoghCalendarLayer.seasonal,
    PatoghCalendarLayer.personal,
    PatoghCalendarLayer.circle,
  };

  final List<CalendarOccasion> occasions = const [
    CalendarOccasion(
      id: 'occasion-nowruz',
      title: 'نوروز',
      dateLabel: 'فروردین',
      calendarSystem: 'هجری شمسی',
      layer: PatoghCalendarLayer.iranOfficial,
      regionLabel: 'ایران',
      sourceLabel: 'تقویم مرکزی پاتوق',
      sourceVersion: 'نمونه دمو',
      certaintyLabel: 'پایدار',
      description: 'فرصت برای دورهمی خانوادگی، سفر، بوم‌گردی و جشن‌های محلی.',
    ),
    CalendarOccasion(
      id: 'occasion-yalda',
      title: 'شب یلدا',
      dateLabel: 'پایان آذر',
      calendarSystem: 'هجری شمسی',
      layer: PatoghCalendarLayer.iranianHeritage,
      regionLabel: 'ایران و جامعه ایرانی',
      sourceLabel: 'تقویم فرهنگی پاتوق',
      sourceVersion: 'نمونه دمو',
      certaintyLabel: 'پایدار',
      description:
          'پیشنهاد رویدادهای قصه، موسیقی، شاهنامه، کافه و جمع خانوادگی.',
    ),
    CalendarOccasion(
      id: 'occasion-ramadan',
      title: 'ماه رمضان و افطارهای جمعی',
      dateLabel: 'براساس تقویم قمری',
      calendarSystem: 'هجری قمری',
      layer: PatoghCalendarLayer.islamic,
      regionLabel: 'ایران و جهان اسلام',
      sourceLabel: 'منبع تقویم مذهبی',
      sourceVersion: 'قابل به‌روزرسانی',
      certaintyLabel: 'نیازمند همگام‌سازی سالانه',
      description:
          'فرصت برای افطاری، امور خیریه، گل‌ریزون و رویدادهای اجتماعی.',
    ),
    CalendarOccasion(
      id: 'occasion-child-day',
      title: 'روز جهانی کودک',
      dateLabel: 'تاریخ از منبع جهانی دریافت می‌شود',
      calendarSystem: 'میلادی',
      layer: PatoghCalendarLayer.global,
      regionLabel: 'جهانی',
      sourceLabel: 'منبع جهانی مناسبت‌ها',
      sourceVersion: 'قابل همگام‌سازی',
      certaintyLabel: 'منبع‌محور',
      description: 'پیشنهاد برنامه برای خانه بازی، شهربازی، مهدکودک و خانواده.',
    ),
  ];

  final List<PersonalOccasion> personalOccasions = [
    const PersonalOccasion(
      id: 'personal-1',
      title: 'تولد مادر',
      dateLabel: '۱۴ آذر',
      occasionType: 'تولد',
      audience: OccasionAudience.family,
      reminderLabels: ['یک ماه قبل', 'یک هفته قبل', 'سه روز قبل'],
      repeatsYearly: true,
      suggestEvents: true,
      notifyAudience: false,
    ),
    const PersonalOccasion(
      id: 'personal-2',
      title: 'سالگرد ازدواج',
      dateLabel: '۲۸ خرداد',
      occasionType: 'سالگرد',
      audience: OccasionAudience.private,
      reminderLabels: ['دو هفته قبل', 'سه روز قبل'],
      repeatsYearly: true,
      suggestEvents: true,
    ),
  ];

  final List<SeasonalSportsMoment> moments = const [
    SeasonalSportsMoment(
      id: 'sports-1',
      title: 'مسابقه فوتبال مهم',
      dateLabel: 'زمان از فید ورزشی به‌روزرسانی می‌شود',
      category: 'فوتبال',
      scopeLabel: 'ملی / بین‌المللی',
      statusLabel: 'فرصت تولید رویداد',
      suggestedHostTypes: ['کافه', 'رستوران', 'هتل', 'سالن', 'کلوپ'],
      eventTemplateTitle: 'تماشای گروهی فوتبال',
    ),
    SeasonalSportsMoment(
      id: 'seasonal-1',
      title: 'فصل طبیعت‌گردی و سفر کوتاه',
      dateLabel: 'براساس فصل و شرایط مقصد',
      category: 'گردشگری',
      scopeLabel: 'محلی / منطقه‌ای',
      statusLabel: 'فرصت فصلی',
      suggestedHostTypes: ['بوم‌گردی', 'هتل', 'مزرعه گردشگری', 'کمپ'],
      eventTemplateTitle: 'پاتوق سفر یک‌روزه',
    ),
    SeasonalSportsMoment(
      id: 'sports-olympic',
      title: 'رویدادهای المپیکی و مسابقات بزرگ',
      dateLabel: 'طبق تقویم رسمی مسابقات',
      category: 'چندرشته‌ای',
      scopeLabel: 'جهانی',
      statusLabel: 'منبع خارجی پویا',
      suggestedHostTypes: ['کافه', 'هتل', 'باشگاه ورزشی', 'مرکز فرهنگی'],
      eventTemplateTitle: 'تماشای جمعی مسابقات',
    ),
  ];

  final List<EventOpportunity> opportunities = const [
    EventOpportunity(
      id: 'opp-1',
      title: 'شب تماشای فوتبال در کافه',
      reason: 'رویداد ورزشی نزدیک + تقاضای بالا + ظرفیت میزبان',
      locationLabel: 'مشهد',
      demandCount: 184,
      matchingHosts: 12,
      opportunityScore: 94,
      suggestedTemplate: 'تماشای گروهی فوتبال',
    ),
    EventOpportunity(
      id: 'opp-2',
      title: 'کارگاه کودک و خانواده',
      reason: 'مناسبت کودک + کاربران والد + خانه‌های بازی فعال',
      locationLabel: 'مشهد',
      demandCount: 76,
      matchingHosts: 8,
      opportunityScore: 88,
      suggestedTemplate: 'کارگاه خلاق کودک',
    ),
    EventOpportunity(
      id: 'opp-3',
      title: 'دورهمی یلدایی محلی',
      reason: 'مناسبت فرهنگی + تقاضای محلی + ظرفیت خالی میزبان‌ها',
      locationLabel: 'محلی',
      demandCount: 129,
      matchingHosts: 17,
      opportunityScore: 91,
      suggestedTemplate: 'شب یلدا',
    ),
  ];

  final List<MemorialProfile> memorials = [
    const MemorialProfile(
      id: 'memorial-1',
      personName: 'یادبود خانوادگی نمونه',
      lifeLabel: 'صفحه نمونه برای نمایش ساختار مموریال',
      relationLabel: 'ایجادکننده: عضو خانواده',
      anniversaryLabel: 'یادآوری سالانه فعال',
      visibility: MemorialVisibility.invited,
      status: MemorialStatus.verified,
      memoryCount: 14,
      condolenceCount: 23,
    ),
  ];

  final List<MemorialMessage> memorialMessages = [
    const MemorialMessage(
      id: 'mem-msg-1',
      memorialId: 'memorial-1',
      authorLabel: 'یکی از اعضای خانواده',
      text: 'یاد و خاطره‌اش همیشه برای ما عزیز خواهد ماند.',
      createdAtLabel: 'نمونه پیام یادبود',
    ),
  ];

  final List<OccasionReminderLog> reminderLogs = [];

  void toggleLayer(PatoghCalendarLayer layer) {
    if (enabledLayers.contains(layer)) {
      enabledLayers.remove(layer);
    } else {
      enabledLayers.add(layer);
    }
    notifyListeners();
  }

  Future<void> addPersonalOccasion({
    required String title,
    required String dateLabel,
    required String occasionType,
    required OccasionAudience audience,
    required List<String> reminderLabels,
    required bool suggestEvents,
    required bool notifyAudience,
  }) async {
    personalOccasions.insert(
      0,
      PersonalOccasion(
        id: 'personal-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        dateLabel: dateLabel,
        occasionType: occasionType,
        audience: audience,
        reminderLabels: reminderLabels,
        repeatsYearly: true,
        suggestEvents: suggestEvents,
        notifyAudience: notifyAudience,
      ),
    );
    notifyListeners();
  }

  Future<void> scheduleDemoReminder(PersonalOccasion occasion) async {
    reminderLogs.insert(
      0,
      OccasionReminderLog(
        id: 'reminder-${DateTime.now().microsecondsSinceEpoch}',
        title: occasion.title,
        deliveryLabel: occasion.reminderLabels.join('، '),
        audienceLabel: occasion.notifyAudience
            ? occasion.audience.label
            : 'فقط صاحب مناسبت',
        scheduledLabel: occasion.dateLabel,
      ),
    );
    notifyListeners();
  }

  Future<void> createMemorial({
    required String personName,
    required String lifeLabel,
    required String relationLabel,
    required String anniversaryLabel,
    required MemorialVisibility visibility,
  }) async {
    memorials.insert(
      0,
      MemorialProfile(
        id: 'memorial-${DateTime.now().microsecondsSinceEpoch}',
        personName: personName,
        lifeLabel: lifeLabel,
        relationLabel: relationLabel,
        anniversaryLabel: anniversaryLabel,
        visibility: visibility,
        status: MemorialStatus.pending,
      ),
    );
    notifyListeners();
  }

  Future<void> approveMemorial(String id) async {
    final index = memorials.indexWhere((item) => item.id == id);
    if (index == -1) return;
    memorials[index] = memorials[index].copyWith(
      status: MemorialStatus.verified,
    );
    notifyListeners();
  }

  Future<void> addMemorialMessage({
    required String memorialId,
    required String authorLabel,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;
    memorialMessages.insert(
      0,
      MemorialMessage(
        id: 'mem-msg-${DateTime.now().microsecondsSinceEpoch}',
        memorialId: memorialId,
        authorLabel: authorLabel,
        text: text.trim(),
        createdAtLabel: 'همین الان',
      ),
    );

    final index = memorials.indexWhere((item) => item.id == memorialId);
    if (index != -1) {
      memorials[index] = memorials[index].copyWith(
        memoryCount: memorials[index].memoryCount + 1,
      );
    }
    notifyListeners();
  }
}

final V11State v11State = V11State();
