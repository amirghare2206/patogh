import 'package:flutter/material.dart';
import 'package:patogh/app.dart';
import 'package:patogh/state/favorites.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadFavorites();
  runApp(const PatoghApp());
}
