import 'package:flutter/foundation.dart';
import 'package:patogh/models/v9_models.dart';

class V9State extends ChangeNotifier {
  final List<EventMemoryItem> memories = <EventMemoryItem>[
    const EventMemoryItem(
      id: 'memory-1',
      eventId: 'breakfast-01',
      eventTitle: 'قرار صبحانه پاتوق',
      author: 'سارا',
      caption: 'عکس گروهی آخر برنامه؛ با رضایت اعضای حاضر.',
      mediaType: MemoryMediaType.photo,
      visibility: MemoryVisibility.eventMembers,
      retentionDays: 365,
      verifiedAttendance: true,
      sharedToTimeline: false,
      createdAtLabel: 'امروز',
    ),
    const EventMemoryItem(
      id: 'memory-2',
      eventId: 'game-01',
      eventTitle: 'شب بازی پاتوق',
      author: 'آرمان',
      caption: 'لحظه آخر بازی که تیم ما برنده شد :)',
      mediaType: MemoryMediaType.video,
      visibility: MemoryVisibility.circle,
      retentionDays: 0,
      verifiedAttendance: true,
      sharedToTimeline: true,
      createdAtLabel: '۳ روز پیش',
    ),
  ];

  final List<MemoryCapsule> capsules = <MemoryCapsule>[
    const MemoryCapsule(
      eventId: 'breakfast-01',
      eventTitle: 'قرار صبحانه پاتوق',
      eventDateLabel: '۲۶ تیر ۱۴۰۵',
      eventType: 'پاتوق اجتماعی',
      participantCount: 6,
      memoryCount: 18,
      anniversaryEnabled: true,
      nextAnniversaryLabel: '۲۶ تیر ۱۴۰۶',
    ),
    const MemoryCapsule(
      eventId: 'game-01',
      eventTitle: 'شب بازی پاتوق',
      eventDateLabel: '۱۲ مرداد ۱۴۰۵',
      eventType: 'پاتوق بازی',
      participantCount: 14,
      memoryCount: 54,
      anniversaryEnabled: true,
      nextAnniversaryLabel: '۱۲ مرداد ۱۴۰۶',
    ),
  ];

  final List<PrivateEventPlan> privateEvents = <PrivateEventPlan>[
    const PrivateEventPlan(
      id: 'private-1',
      title: 'جشن تولد نازنین',
      eventType: 'تولد',
      dateLabel: 'جمعه ۱۸ مهر، ساعت ۱۷',
      locationLabel: 'مشهد - آدرس فقط برای مهمان‌های تأییدشده',
      privacyMode: 'دعوتی',
      hostCoversHostingCost: true,
      invitedCount: 32,
      acceptedCount: 24,
    ),
    const PrivateEventPlan(
      id: 'private-2',
      title: 'سالگرد خانوادگی',
      eventType: 'سالگرد',
      dateLabel: 'سه‌شنبه ۲۲ آبان، ساعت ۲۰',
      locationLabel: 'خانه میزبان',
      privacyMode: 'خانواده و حلقه',
      hostCoversHostingCost: true,
      invitedCount: 18,
      acceptedCount: 12,
    ),
  ];

  final List<EventInvitation> invitations = <EventInvitation>[
    const EventInvitation(
      id: 'invite-1',
      eventId: 'private-1',
      eventTitle: 'جشن تولد نازنین',
      invitee: '0912***4567',
      deliveryChannel: 'شماره موبایل',
      status: InvitationStatus.accepted,
      plusOneLimit: 1,
    ),
    const EventInvitation(
      id: 'invite-2',
      eventId: 'private-1',
      eventTitle: 'جشن تولد نازنین',
      invitee: '@sara_patogh',
      deliveryChannel: 'نام کاربری پاتوق',
      status: InvitationStatus.invited,
      plusOneLimit: 2,
    ),
  ];

  final List<ConferencePlan> conferences = <ConferencePlan>[
    const ConferencePlan(
      id: 'conference-1',
      title: 'همایش آینده تجربه شهری',
      city: 'مشهد',
      dateLabel: '۲۵ آذر ۱۴۰۵',
      capacity: 600,
      registered: 418,
      ticketTiers: ['عادی', 'دانشجویی', 'VIP'],
      speakers: ['سخنران ۱', 'سخنران ۲', 'پنل تخصصی'],
      certificateEnabled: true,
      sponsorBoothsEnabled: true,
    ),
  ];

  List<EventMemoryItem> memoriesForEvent(String eventId) {
    return memories.where((item) => item.eventId == eventId).toList();
  }

  Future<void> addMemory({
    required String eventId,
    required String eventTitle,
    required String author,
    required String caption,
    required MemoryMediaType mediaType,
    required MemoryVisibility visibility,
    required int retentionDays,
    required bool sharedToTimeline,
  }) async {
    memories.insert(
      0,
      EventMemoryItem(
        id: 'memory-${DateTime.now().microsecondsSinceEpoch}',
        eventId: eventId,
        eventTitle: eventTitle,
        author: author,
        caption: caption,
        mediaType: mediaType,
        visibility: visibility,
        retentionDays: retentionDays,
        verifiedAttendance: true,
        sharedToTimeline: sharedToTimeline,
        createdAtLabel: 'همین الان',
      ),
    );
    notifyListeners();
  }

  Future<void> createPrivateEvent({
    required String title,
    required String eventType,
    required String dateLabel,
    required String locationLabel,
  }) async {
    privateEvents.insert(
      0,
      PrivateEventPlan(
        id: 'private-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        eventType: eventType,
        dateLabel: dateLabel,
        locationLabel: locationLabel,
        privacyMode: 'دعوتی',
        hostCoversHostingCost: true,
        invitedCount: 0,
        acceptedCount: 0,
      ),
    );
    notifyListeners();
  }

  Future<void> inviteGuest({
    required String eventId,
    required String eventTitle,
    required String invitee,
    required String deliveryChannel,
    int plusOneLimit = 0,
  }) async {
    invitations.insert(
      0,
      EventInvitation(
        id: 'invite-${DateTime.now().microsecondsSinceEpoch}',
        eventId: eventId,
        eventTitle: eventTitle,
        invitee: invitee,
        deliveryChannel: deliveryChannel,
        status: InvitationStatus.invited,
        plusOneLimit: plusOneLimit,
      ),
    );
    notifyListeners();
  }

  Future<void> updateInvitationStatus(
    String invitationId,
    InvitationStatus status,
  ) async {
    final index = invitations.indexWhere((item) => item.id == invitationId);
    if (index == -1) return;
    invitations[index] = invitations[index].copyWith(status: status);
    notifyListeners();
  }
}

final V9State v9State = V9State();
