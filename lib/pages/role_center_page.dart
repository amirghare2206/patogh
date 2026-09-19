import 'package:flutter/material.dart';
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
        title: const Text('نقش و سطح دسترسی'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'نقش فعلی',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            appState.role.label,
            style: const TextStyle(
              color: PatoghTheme.orange,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'در نسخه واقعی، نقش‌های کسب‌وکار میزبان، هماهنگ‌کننده و برگزارکننده بعد از بررسی ادمین فعال می‌شوند. برای تست Demo می‌توانی نقش را فوراً تغییر بدهی.',
            style: TextStyle(
              color: Color(0xFFAAAAAA),
              height: 1.7,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          ...roles.map(
            (role) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      role.label,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  if (role == UserRole.participant)
                    FilledButton(
                      onPressed: () => appState.setDemoRole(role),
                      child: const Text('فعال کن'),
                    )
                  else if (role == UserRole.admin)
                    OutlinedButton(
                      onPressed: () => appState.setDemoRole(role),
                      child: const Text('فقط دمو'),
                    )
                  else
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _requestRole(context, role),
                          child: const Text('درخواست'),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton(
                          onPressed: () => appState.setDemoRole(role),
                          child: const Text('دمو'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
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
            hintText: 'درباره تجربه یا کسب‌وکار خودت توضیح بده...',
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
