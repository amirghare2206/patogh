import 'package:flutter/foundation.dart';

final ValueNotifier<Set<String>> favoritePlaces = ValueNotifier<Set<String>>(
  <String>{},
);

void toggleFavorite(String title) {
  final updated = Set<String>.from(favoritePlaces.value);

  if (updated.contains(title)) {
    updated.remove(title);
  } else {
    updated.add(title);
  }

  favoritePlaces.value = updated;
}
