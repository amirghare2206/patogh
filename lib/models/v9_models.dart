enum MemoryVisibility { privateOnly, eventMembers, circle, publicTimeline }

extension MemoryVisibilityX on MemoryVisibility {
  String get label {
    switch (this) {
      case MemoryVisibility.privateOnly:
        return 'فقط خودم';
      case MemoryVisibility.eventMembers:
        return 'اعضای همین رویداد';
      case MemoryVisibility.circle:
        return 'حلقه من';
      case MemoryVisibility.publicTimeline:
        return 'تایم‌لاین عمومی';
    }
  }
}

enum MemoryMediaType { photo, video, text, audio, guestbook }

extension MemoryMediaTypeX on MemoryMediaType {
  String get label {
    switch (this) {
      case MemoryMediaType.photo:
        return 'عکس';
      case MemoryMediaType.video:
        return 'ویدئو';
      case MemoryMediaType.text:
        return 'خاطره متنی';
      case MemoryMediaType.audio:
        return 'یادداشت صوتی';
      case MemoryMediaType.guestbook:
        return 'یادگاری / دفتر مهمان';
    }
  }
}

class EventMemoryItem {
  final String id;
  final String eventId;
  final String eventTitle;
  final String author;
  final String caption;
  final MemoryMediaType mediaType;
  final MemoryVisibility visibility;
  final int retentionDays;
  final bool verifiedAttendance;
  final bool sharedToTimeline;
  final String createdAtLabel;

  const EventMemoryItem({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.author,
    required this.caption,
    required this.mediaType,
    required this.visibility,
    required this.retentionDays,
    required this.verifiedAttendance,
    required this.sharedToTimeline,
    required this.createdAtLabel,
  });
}

class MemoryCapsule {
  final String eventId;
  final String eventTitle;
  final String eventDateLabel;
  final String eventType;
  final int participantCount;
  final int memoryCount;
  final bool anniversaryEnabled;
  final String nextAnniversaryLabel;

  const MemoryCapsule({
    required this.eventId,
    required this.eventTitle,
    required this.eventDateLabel,
    required this.eventType,
    required this.participantCount,
    required this.memoryCount,
    required this.anniversaryEnabled,
    required this.nextAnniversaryLabel,
  });
}

enum InvitationStatus { invited, accepted, declined, maybe }

extension InvitationStatusX on InvitationStatus {
  String get label {
    switch (this) {
      case InvitationStatus.invited:
        return 'دعوت شده';
      case InvitationStatus.accepted:
        return 'می‌آید';
      case InvitationStatus.declined:
        return 'نمی‌آید';
      case InvitationStatus.maybe:
        return 'شاید';
    }
  }
}

class EventInvitation {
  final String id;
  final String eventId;
  final String eventTitle;
  final String invitee;
  final String deliveryChannel;
  final InvitationStatus status;
  final int plusOneLimit;

  const EventInvitation({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.invitee,
    required this.deliveryChannel,
    required this.status,
    this.plusOneLimit = 0,
  });

  EventInvitation copyWith({InvitationStatus? status}) {
    return EventInvitation(
      id: id,
      eventId: eventId,
      eventTitle: eventTitle,
      invitee: invitee,
      deliveryChannel: deliveryChannel,
      status: status ?? this.status,
      plusOneLimit: plusOneLimit,
    );
  }
}

class PrivateEventPlan {
  final String id;
  final String title;
  final String eventType;
  final String dateLabel;
  final String locationLabel;
  final String privacyMode;
  final bool hostCoversHostingCost;
  final int invitedCount;
  final int acceptedCount;

  const PrivateEventPlan({
    required this.id,
    required this.title,
    required this.eventType,
    required this.dateLabel,
    required this.locationLabel,
    required this.privacyMode,
    required this.hostCoversHostingCost,
    required this.invitedCount,
    required this.acceptedCount,
  });
}

class ConferencePlan {
  final String id;
  final String title;
  final String city;
  final String dateLabel;
  final int capacity;
  final int registered;
  final List<String> ticketTiers;
  final List<String> speakers;
  final bool certificateEnabled;
  final bool sponsorBoothsEnabled;

  const ConferencePlan({
    required this.id,
    required this.title,
    required this.city,
    required this.dateLabel,
    required this.capacity,
    required this.registered,
    required this.ticketTiers,
    required this.speakers,
    required this.certificateEnabled,
    required this.sponsorBoothsEnabled,
  });
}
