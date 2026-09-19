import 'package:flutter/material.dart';
import 'package:patogh/app.dart';
import 'package:patogh/services/platform_services.dart';
import 'package:patogh/state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PlatformServices.initialize();
  await appState.init();
  runApp(const PatoghApp());
}
