import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:patogh/models/chat_message.dart';
import 'package:patogh/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  SharedPreferences? _prefs;

  bool loggedIn = false;
  String phone = '';
  UserProfile? profile;

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

    final chatRaw = _prefs?.getString('chats');
    if (chatRaw != null && chatRaw.isNotEmpty) {
      final decoded = Map<String, dynamic>.from(jsonDecode(chatRaw) as Map);
      for (final entry in decoded.entries) {
        final list = (entry.value as List)
            .map(
              (item) =>
                  ChatMessage.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList();
        chats[entry.key] = list;
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

  Future<void> verifyDemoOtp(String phoneNumber, String code) async {
    if (code != '1234') {
      throw Exception('کد آزمایشی صحیح 1234 است.');
    }
    phone = phoneNumber;
    loggedIn = true;
    await _prefs?.setBool('logged_in', true);
    await _prefs?.setString('phone', phoneNumber);
    notifyListeners();
  }

  Future<void> logout() async {
    loggedIn = false;
    await _prefs?.setBool('logged_in', false);
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile newProfile) async {
    profile = newProfile;
    await _prefs?.setString('profile', jsonEncode(newProfile.toJson()));
    notifyListeners();
  }

  Future<void> reserve(String eventId) async {
    reservedIds.add(eventId);
    waitlistIds.remove(eventId);
    await _persistSets();
    notifyListeners();
  }

  Future<void> payAndReserve(String eventId) async {
    paidIds.add(eventId);
    reservedIds.add(eventId);
    waitlistIds.remove(eventId);
    await _persistSets();
    notifyListeners();
  }

  Future<void> joinWaitlist(String eventId) async {
    waitlistIds.add(eventId);
    await _persistSets();
    notifyListeners();
  }

  Future<void> cancelReservation(String eventId) async {
    reservedIds.remove(eventId);
    waitlistIds.remove(eventId);
    paidIds.remove(eventId);
    await _persistSets();
    notifyListeners();
  }

  Future<void> toggleFavorite(String eventId) async {
    if (favoriteIds.contains(eventId)) {
      favoriteIds.remove(eventId);
    } else {
      favoriteIds.add(eventId);
    }
    await _persistSets();
    notifyListeners();
  }

  Future<void> sendMessage(String roomId, String text) async {
    final list = chats.putIfAbsent(roomId, () => <ChatMessage>[]);
    list.add(ChatMessage(text: text, mine: true, time: _timeNow()));
    await _persistChats();
    notifyListeners();
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

    final score = 72 + overlap * 8;
    return score.clamp(72, 98);
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
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

final AppState appState = AppState();
