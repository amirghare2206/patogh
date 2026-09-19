import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:patogh/config/app_config.dart';
import 'package:patogh/data/mock_data.dart' as mock;
import 'package:patogh/models/chat_message.dart';
import 'package:patogh/models/community.dart';
import 'package:patogh/models/patogh_category.dart';
import 'package:patogh/models/patogh_event.dart';
import 'package:patogh/models/role_request.dart';
import 'package:patogh/models/story_item.dart';
import 'package:patogh/models/timeline_post.dart';
import 'package:patogh/models/user_profile.dart';
import 'package:patogh/models/user_role.dart';
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

  UserRole get role => profile?.role ?? UserRole.participant;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    loggedIn = _prefs?.getBool('logged_in') ?? false;
    phone = _prefs?.getString('phone') ?? '';

    final profileRaw = _prefs?.getString('profile');
    if (profileRaw != null && profileRaw.isNotEmpty) {
      profile = UserProfile.fromJson(
        Map<String, dynamic>.from(jsonDecode(profileRaw) as Map),
      );
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
    final current =
        profile ??
        const UserProfile(
          name: 'کاربر پاتوق',
          age: 25,
          city: 'مشهد',
          interests: [],
          showAge: true,
          allowChat: true,
        );

    profile = current.copyWith(role: newRole);
    await _persistProfile();
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
