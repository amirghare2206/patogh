import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  SharedPreferences? _prefs;

  final Set<String> reservedIds = <String>{};
  final Set<String> waitlistIds = <String>{};
  final Set<String> favoriteIds = <String>{};

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    reservedIds
      ..clear()
      ..addAll(_prefs?.getStringList('reserved_ids') ?? <String>[]);
    waitlistIds
      ..clear()
      ..addAll(_prefs?.getStringList('waitlist_ids') ?? <String>[]);
    favoriteIds
      ..clear()
      ..addAll(_prefs?.getStringList('favorite_ids') ?? <String>[]);
  }

  Future<void> reserve(String eventId) async {
    reservedIds.add(eventId);
    waitlistIds.remove(eventId);
    await _persist();
    notifyListeners();
  }

  Future<void> joinWaitlist(String eventId) async {
    waitlistIds.add(eventId);
    await _persist();
    notifyListeners();
  }

  Future<void> cancelReservation(String eventId) async {
    reservedIds.remove(eventId);
    waitlistIds.remove(eventId);
    await _persist();
    notifyListeners();
  }

  Future<void> toggleFavorite(String eventId) async {
    if (favoriteIds.contains(eventId)) {
      favoriteIds.remove(eventId);
    } else {
      favoriteIds.add(eventId);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    await _prefs?.setStringList('reserved_ids', reservedIds.toList());
    await _prefs?.setStringList('waitlist_ids', waitlistIds.toList());
    await _prefs?.setStringList('favorite_ids', favoriteIds.toList());
  }
}

final AppState appState = AppState();
