enum PatoghCalendarLayer {
  iranOfficial,
  islamic,
  iranianHeritage,
  global,
  sports,
  seasonal,
  personal,
  circle,
  organization,
}

extension PatoghCalendarLayerX on PatoghCalendarLayer {
  String get label {
    switch (this) {
      case PatoghCalendarLayer.iranOfficial:
        return 'رسمی ایران';
      case PatoghCalendarLayer.islamic:
        return 'مذهبی و جهان اسلام';
      case PatoghCalendarLayer.iranianHeritage:
        return 'ایرانی و اساطیری';
      case PatoghCalendarLayer.global:
        return 'جهانی';
      case PatoghCalendarLayer.sports:
        return 'ورزشی';
      case PatoghCalendarLayer.seasonal:
        return 'فصلی';
      case PatoghCalendarLayer.personal:
        return 'شخصی';
      case PatoghCalendarLayer.circle:
        return 'حلقه من';
      case PatoghCalendarLayer.organization:
        return 'سازمانی';
    }
  }
}

class CalendarOccasion {
  final String id;
  final String title;
  final String dateLabel;
  final String calendarSystem;
  final PatoghCalendarLayer layer;
  final String regionLabel;
  final String sourceLabel;
  final String sourceVersion;
  final String certaintyLabel;
  final String description;
  final bool eventGenerationEnabled;

  const CalendarOccasion({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.calendarSystem,
    required this.layer,
    required this.regionLabel,
    required this.sourceLabel,
    required this.sourceVersion,
    required this.certaintyLabel,
    required this.description,
    this.eventGenerationEnabled = true,
  });
}

enum OccasionAudience { private, family, closeFriends, circle, public }

extension OccasionAudienceX on OccasionAudience {
  String get label {
    switch (this) {
      case OccasionAudience.private:
        return 'فقط خودم';
      case OccasionAudience.family:
        return 'خانواده';
      case OccasionAudience.closeFriends:
        return 'دوستان نزدیک';
      case OccasionAudience.circle:
        return 'حلقه انتخابی';
      case OccasionAudience.public:
        return 'عمومی';
    }
  }
}

class PersonalOccasion {
  final String id;
  final String title;
  final String dateLabel;
  final String occasionType;
  final OccasionAudience audience;
  final List<String> reminderLabels;
  final bool repeatsYearly;
  final bool suggestEvents;
  final bool notifyAudience;

  const PersonalOccasion({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.occasionType,
    required this.audience,
    required this.reminderLabels,
    this.repeatsYearly = true,
    this.suggestEvents = true,
    this.notifyAudience = false,
  });
}

class SeasonalSportsMoment {
  final String id;
  final String title;
  final String dateLabel;
  final String category;
  final String scopeLabel;
  final String statusLabel;
  final List<String> suggestedHostTypes;
  final String eventTemplateTitle;

  const SeasonalSportsMoment({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.category,
    required this.scopeLabel,
    required this.statusLabel,
    required this.suggestedHostTypes,
    required this.eventTemplateTitle,
  });
}

class EventOpportunity {
  final String id;
  final String title;
  final String reason;
  final String locationLabel;
  final int demandCount;
  final int matchingHosts;
  final int opportunityScore;
  final String suggestedTemplate;

  const EventOpportunity({
    required this.id,
    required this.title,
    required this.reason,
    required this.locationLabel,
    required this.demandCount,
    required this.matchingHosts,
    required this.opportunityScore,
    required this.suggestedTemplate,
  });
}

enum MemorialStatus { pending, verified, archived }

enum MemorialVisibility { familyOnly, invited, public }

extension MemorialVisibilityX on MemorialVisibility {
  String get label {
    switch (this) {
      case MemorialVisibility.familyOnly:
        return 'فقط خانواده';
      case MemorialVisibility.invited:
        return 'دعوت‌شده‌ها';
      case MemorialVisibility.public:
        return 'عمومی';
    }
  }
}

class MemorialProfile {
  final String id;
  final String personName;
  final String lifeLabel;
  final String relationLabel;
  final String anniversaryLabel;
  final MemorialVisibility visibility;
  final MemorialStatus status;
  final int memoryCount;
  final int condolenceCount;
  final String? golrizonCampaignId;

  const MemorialProfile({
    required this.id,
    required this.personName,
    required this.lifeLabel,
    required this.relationLabel,
    required this.anniversaryLabel,
    required this.visibility,
    required this.status,
    this.memoryCount = 0,
    this.condolenceCount = 0,
    this.golrizonCampaignId,
  });

  MemorialProfile copyWith({
    MemorialStatus? status,
    int? memoryCount,
    int? condolenceCount,
  }) {
    return MemorialProfile(
      id: id,
      personName: personName,
      lifeLabel: lifeLabel,
      relationLabel: relationLabel,
      anniversaryLabel: anniversaryLabel,
      visibility: visibility,
      status: status ?? this.status,
      memoryCount: memoryCount ?? this.memoryCount,
      condolenceCount: condolenceCount ?? this.condolenceCount,
      golrizonCampaignId: golrizonCampaignId,
    );
  }
}

class MemorialMessage {
  final String id;
  final String memorialId;
  final String authorLabel;
  final String text;
  final String createdAtLabel;

  const MemorialMessage({
    required this.id,
    required this.memorialId,
    required this.authorLabel,
    required this.text,
    required this.createdAtLabel,
  });
}

class OccasionReminderLog {
  final String id;
  final String title;
  final String deliveryLabel;
  final String audienceLabel;
  final String scheduledLabel;

  const OccasionReminderLog({
    required this.id,
    required this.title,
    required this.deliveryLabel,
    required this.audienceLabel,
    required this.scheduledLabel,
  });
}
