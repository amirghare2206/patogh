import 'package:flutter/material.dart';
import 'package:patogh/app.dart';
import 'package:patogh/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Render the UI first. Previously startup waited for backend initialization
  // before runApp(), which could look like a frozen white screen.
  runApp(const PatoghApp());

  // Keep startup failures visible inside the app.
  await bootstrapPatogh();
}
