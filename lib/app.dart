import 'package:flutter/material.dart';
import 'package:patogh/pages/auth/login_page.dart';
import 'package:patogh/pages/auth/interests_page.dart';
import 'package:patogh/pages/root_shell.dart';
import 'package:patogh/pages/startup_diagnostic_page.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/state/startup_state.dart';
import 'package:patogh/theme/patogh_theme.dart';
import 'package:patogh/widgets/page_help_button.dart';

class PatoghApp extends StatelessWidget {
  const PatoghApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'پاتوق',
      theme: PatoghTheme.dark,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: startupState,
          builder: (context, _) => Directionality(
            textDirection: TextDirection.rtl,
            child: Stack(
              fit: StackFit.expand,
              children: [
                child ?? const SizedBox.shrink(),
                if (startupState.isReady)
                  const Positioned(
                    left: 12,
                    bottom: 84,
                    child: SafeArea(child: PageHelpButton()),
                  ),
              ],
            ),
          ),
        );
      },
      home: AnimatedBuilder(
        animation: startupState,
        builder: (context, _) {
          if (!startupState.isReady) {
            return StartupDiagnosticPage(
              key: ValueKey(
                '${startupState.status.name}|${startupState.stage}|${startupState.errorTitle ?? ''}',
              ),
            );
          }

          return AnimatedBuilder(
            animation: appState,
            builder: (context, _) {
              if (!appState.loggedIn) return const LoginPage();
              if (appState.profile == null) return const InterestsPage();
              return const RootShell();
            },
          );
        },
      ),
    );
  }
}
