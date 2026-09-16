import 'package:flutter/material.dart';
import 'package:patogh/app.dart';
import 'package:patogh/state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appState.init();
  runApp(const PatoghApp());
}
