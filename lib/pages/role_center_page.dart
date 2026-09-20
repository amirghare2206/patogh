import 'package:flutter/material.dart';
import 'package:patogh/config/app_config.dart';
import 'package:patogh/models/user_role.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class RoleCenterPage extends StatelessWidget {
  const RoleCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    const roles = [
      UserRole.participant,
      UserRole.venue,
      UserRole.coordinator,
      UserRole.organizer,
      UserRole.admin,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('نقش‌های من'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'حالت فعال',
                    style: TextStyle(color: Color(0xFFAAAAAA)),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    appState.role.label,
                    style: const TextStyle(
                      color: PatoghTheme.orange,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'یک نفر می‌تواند همزمان شرکت‌کننده، میزبان، هماهنگ‌کننده و برگزارکننده باشد. فقط بین پنل‌های فعال جابه‌جا می‌شوی.',
                    style: TextStyle(
                      color: Color(0xFFBBBBBB),
                      fontSize: 11,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...roles.map((role) {
              final enabled = appState.enabledRoles.contains(role);
              final active = appState.role == role;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF2A2119)
                      : const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(
                      active
                          ? Icons.radio_button_checked_rounded
                          : Icons.badge_outlined,
                      color: active ? PatoghTheme.orange : Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            role.label,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            enabled
                                ? 'فعال برای این حساب'
                                : (role == UserRole.admin
                                      ? 'فقط با دسترسی مدیریتی'
                                      : 'نیازمند درخواست و تأیید'),
                            style: const TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (enabled && !active)
                      FilledButton(
                        onPressed: () => appState.switchRole(role),
                        child: const Text('ورود به نقش'),
                      )
                    else if (!enabled && role != UserRole.admin)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _requestRole(context, role),
                            child: const Text('درخواست'),
                          ),
                          if (AppConfig.isDemo)
                            OutlinedButton(
                              onPressed: () => appState.setDemoRole(role),
                              child: const Text('دمو'),
                            ),
                        ],
                      )
                    else if (!enabled &&
                        role == UserRole.admin &&
                        AppConfig.isDemo)
                      OutlinedButton(
                        onPressed: () => appState.setDemoRole(role),
                        child: const Text('ادمین Demo'),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _requestRole(BuildContext context, UserRole role) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('درخواست ${role.label}'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'درباره تجربه، کسب‌وکار یا سابقه هماهنگی توضیح بده...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () async {
              await appState.requestRole(role, controller.text.trim());
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('ارسال درخواست'),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}
