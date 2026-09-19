class VenueType {
  final String id;
  final String title;
  final String group;
  final bool familyFriendly;
  final bool childFriendly;

  const VenueType({
    required this.id,
    required this.title,
    required this.group,
    this.familyFriendly = false,
    this.childFriendly = false,
  });
}

class DependentProfile {
  final String id;
  final String name;
  final int age;
  final String relation;

  const DependentProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.relation,
  });
}

class EventAudiencePolicy {
  final String eventId;
  final String geographicLevel;
  final String geographicLabel;
  final int minAge;
  final int maxAge;
  final String genderPolicy;
  final String attendanceMode;
  final bool sponsored;
  final String sponsorName;
  final int noShowPenalty;

  const EventAudiencePolicy({
    required this.eventId,
    required this.geographicLevel,
    required this.geographicLabel,
    required this.minAge,
    required this.maxAge,
    required this.genderPolicy,
    required this.attendanceMode,
    this.sponsored = false,
    this.sponsorName = '',
    this.noShowPenalty = 0,
  });
}

class ReputationProfile {
  final String id;
  final String title;
  final String entityType;
  final double overall;
  final int verifiedReviews;
  final int confidence;
  final int claimMatch;
  final Map<String, double> metrics;
  final List<String> claims;
  final List<String> strengths;
  final List<String> improvements;

  const ReputationProfile({
    required this.id,
    required this.title,
    required this.entityType,
    required this.overall,
    required this.verifiedReviews,
    required this.confidence,
    required this.claimMatch,
    required this.metrics,
    required this.claims,
    required this.strengths,
    required this.improvements,
  });
}

class FeedbackEntry {
  final String id;
  final String eventId;
  final String eventTitle;
  final String targetTitle;
  final String targetType;
  final double score;
  final String comment;
  final bool verifiedAttendance;

  const FeedbackEntry({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.targetTitle,
    required this.targetType,
    required this.score,
    required this.comment,
    this.verifiedAttendance = true,
  });
}

class EventRequestItem {
  final String id;
  final String title;
  final String city;
  final String category;
  final String ageRange;
  final int supporters;
  final String status;

  const EventRequestItem({
    required this.id,
    required this.title,
    required this.city,
    required this.category,
    required this.ageRange,
    required this.supporters,
    required this.status,
  });
}

class BookingGroupMember {
  final String name;
  final String status;
  final bool dependent;

  const BookingGroupMember({
    required this.name,
    required this.status,
    this.dependent = false,
  });
}

class MenuItemModel {
  final String id;
  final String title;
  final String category;
  final int price;
  final String description;
  final bool available;

  const MenuItemModel({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.description,
    this.available = true,
  });
}

class DiscountCampaign {
  final String id;
  final String title;
  final String code;
  final String audience;
  final int percent;
  final int maxDiscount;
  final String status;

  const DiscountCampaign({
    required this.id,
    required this.title,
    required this.code,
    required this.audience,
    required this.percent,
    required this.maxDiscount,
    required this.status,
  });
}

class BannerItem {
  final String id;
  final String title;
  final String subtitle;
  final String placement;
  final String audience;
  final String actionLabel;
  final bool sponsored;

  const BannerItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.placement,
    required this.audience,
    required this.actionLabel,
    this.sponsored = false,
  });
}

class OrganizationAccount {
  final String id;
  final String name;
  final String type;
  final int employees;
  final int monthlyBudget;
  final int usedBudget;

  const OrganizationAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.employees,
    required this.monthlyBudget,
    required this.usedBudget,
  });
}

class SponsorshipPlan {
  final String id;
  final String sponsorName;
  final String purpose;
  final String eventTitle;
  final int capacity;
  final int invited;
  final int registered;
  final int unitCost;
  final String status;

  const SponsorshipPlan({
    required this.id,
    required this.sponsorName,
    required this.purpose,
    required this.eventTitle,
    required this.capacity,
    required this.invited,
    required this.registered,
    required this.unitCost,
    required this.status,
  });
}

class AttendanceRecord {
  final String title;
  final String status;
  final int impact;

  const AttendanceRecord({
    required this.title,
    required this.status,
    required this.impact,
  });
}

class CorporateRequestItem {
  final String id;
  final String title;
  final String city;
  final int people;
  final int budget;
  final bool catering;
  final String status;

  const CorporateRequestItem({
    required this.id,
    required this.title,
    required this.city,
    required this.people,
    required this.budget,
    required this.catering,
    required this.status,
  });
}

class EventCommentItem {
  final String id;
  final String eventId;
  final String author;
  final String text;
  final String createdAt;

  const EventCommentItem({
    required this.id,
    required this.eventId,
    required this.author,
    required this.text,
    required this.createdAt,
  });
}
