import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _favoritesKey = 'favorite_places';

final ValueNotifier<Set<String>> favoritePlaces = ValueNotifier<Set<String>>(
  <String>{},
);

Future<void> loadFavorites() async {
  final prefs = await SharedPreferences.getInstance();
  final savedFavorites = prefs.getStringList(_favoritesKey) ?? <String>[];
  favoritePlaces.value = savedFavorites.toSet();
}

Future<void> toggleFavorite(String title) async {
  final updated = Set<String>.from(favoritePlaces.value);

  if (updated.contains(title)) {
    updated.remove(title);
  } else {
    updated.add(title);
  }

  favoritePlaces.value = updated;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(_favoritesKey, updated.toList());
}
