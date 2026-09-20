import 'package:flutter/material.dart';
import 'package:patogh/pages/auth/login_page.dart';
import 'package:patogh/pages/auth/profile_setup_page.dart';
import 'package:patogh/pages/root_shell.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class PatoghApp extends StatelessWidget {
  const PatoghApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'پاتوق',
      theme: PatoghTheme.dark,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          if (!appState.loggedIn) return const LoginPage();
          if (appState.profile == null) return const ProfileSetupPage();
          return const RootShell();
        },
      ),
    );
  }
}
