import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:patogh/config/app_config.dart';
import 'package:patogh/data/mock_data.dart' as mock;
import 'package:patogh/models/chat_message.dart';
import 'package:patogh/models/patogh_event.dart';
import 'package:patogh/models/user_profile.dart';
import 'package:patogh/services/platform_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  SharedPreferences? _prefs;
  StreamSubscription<List<ChatMessage>>? _chatSubscription;

  bool loggedIn = false;
  String phone = '';
  UserProfile? profile;

  final List<PatoghEvent> events = <PatoghEvent>[];

  final Set<String> reservedIds = <String>{};
  final Set<String> waitlistIds = <String>{};
  final Set<String> favoriteIds = <String>{};
  final Set<String> paidIds = <String>{};

  final Map<String, List<ChatMessage>> chats = <String, List<ChatMessage>>{};

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

    if (AppConfig.useSupabase) {
      loggedIn = PlatformServices.hasRemoteSession;

      final remoteEvents = await PlatformServices.fetchEvents();
      if (remoteEvents.isNotEmpty) {
        events
          ..clear()
          ..addAll(remoteEvents);
      }

      if (loggedIn) {
        final remoteProfile = await PlatformServices.loadProfile();
        if (remoteProfile != null) {
          profile = remoteProfile;
          await _persistProfile();
        }

        await _syncReservationsFromRemote();
        final remoteFavorites = await PlatformServices.fetchFavorites();
        favoriteIds
          ..clear()
          ..addAll(remoteFavorites);

        await _persistSets();
        await PlatformServices.registerPushToken();
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

  Future<void> requestOtp(String phoneNumber) async {
    await PlatformServices.requestOtp(phoneNumber);
  }

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
      encoded[entry.key] = entry.value.map((m) => m.toJson()).toList();
    }

    await _prefs?.setString('chats', jsonEncode(encoded));
  }

  String _timeNow() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

final AppState appState = AppState();
