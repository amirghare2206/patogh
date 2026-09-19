import 'package:flutter/material.dart';
import 'package:patogh/models/v8_models.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class SocialLinksPage extends StatelessWidget {
  const SocialLinksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شبکه‌های اجتماعی'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text(
                'برای هر شبکه جداگانه تعیین کن چه کسانی اجازه دیدنش را داشته باشند.',
                style: TextStyle(color: Color(0xFFAAAAAA), height: 1.7),
              ),
              const SizedBox(height: 16),
              ...appState.socialLinks.map(
                (link) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link_rounded, color: PatoghTheme.orange),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              link.platform,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              link.handleOrUrl,
                              style: const TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<SocialLinkVisibility>(
                        tooltip: 'سطح دسترسی',
                        initialValue: link.visibility,
                        onSelected: (value) =>
                            appState.setSocialLinkVisibility(link.id, value),
                        itemBuilder: (_) => SocialLinkVisibility.values
                            .map(
                              (value) => PopupMenuItem(
                                value: value,
                                child: Text(value.label),
                              ),
                            )
                            .toList(),
                        child: Chip(label: Text(link.visibility.label)),
                      ),
                    ],
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => _add(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('افزودن شبکه اجتماعی'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _add(BuildContext context) async {
    final platform = TextEditingController();
    final url = TextEditingController();
    var visibility = SocialLinkVisibility.public;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('شبکه اجتماعی جدید'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: platform,
                decoration: const InputDecoration(
                  hintText: 'مثلاً اینستاگرام، ایتا، لینکدین، آپارات...',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: url,
                decoration: const InputDecoration(hintText: 'آدرس یا شناسه'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<SocialLinkVisibility>(
                initialValue: visibility,
                items: SocialLinkVisibility.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setLocalState(() => visibility = value);
                },
                decoration: const InputDecoration(labelText: 'سطح دسترسی'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('انصراف'),
            ),
            FilledButton(
              onPressed: () async {
                if (platform.text.trim().isEmpty || url.text.trim().isEmpty) {
                  return;
                }
                await appState.addSocialLink(
                  platform: platform.text.trim(),
                  url: url.text.trim(),
                  visibility: visibility,
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );

    platform.dispose();
    url.dispose();
  }
}
