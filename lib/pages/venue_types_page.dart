import 'package:flutter/material.dart';
import 'package:patogh/models/ecosystem_models.dart';
import 'package:patogh/models/user_role.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class VenueTypesPage extends StatelessWidget {
  const VenueTypesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('انواع میزبان‌ها'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final groups = <String, List<VenueType>>{};
          for (final item in appState.venueTypes) {
            groups.putIfAbsent(item.group, () => <VenueType>[]).add(item);
          }

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text(
                'نوع میزبان از دیتابیس مدیریت می‌شود؛ بنابراین پاتوق محدود به کافه و رستوران نیست و هر فضای تأییدشده می‌تواند میزبان شود.',
                style: TextStyle(color: Color(0xFFAAAAAA), height: 1.7),
              ),
              if (appState.role == UserRole.admin) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _add(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('افزودن نوع میزبان'),
                ),
              ],
              const SizedBox(height: 16),
              ...groups.entries.map(
                (entry) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          color: PatoghTheme.orange,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...entry.value.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(
                                item.childFriendly
                                    ? Icons.child_care_rounded
                                    : Icons.storefront_rounded,
                                size: 18,
                                color: item.childFriendly
                                    ? PatoghTheme.green
                                    : Colors.white70,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(item.title)),
                              if (item.familyFriendly)
                                const Text(
                                  'خانوادگی',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFFAAAAAA),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _add(BuildContext context) async {
    final title = TextEditingController();
    final group = TextEditingController();
    var family = false;
    var child = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('نوع میزبان جدید'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'عنوان'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: group,
                decoration: const InputDecoration(labelText: 'گروه'),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: family,
                onChanged: (value) => setLocalState(() => family = value),
                title: const Text('مناسب خانواده'),
              ),
              SwitchListTile(
                value: child,
                onChanged: (value) => setLocalState(() => child = value),
                title: const Text('مناسب کودک'),
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
                if (title.text.trim().isEmpty || group.text.trim().isEmpty) {
                  return;
                }
                await appState.addVenueType(
                  title: title.text.trim(),
                  group: group.text.trim(),
                  familyFriendly: family,
                  childFriendly: child,
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('افزودن'),
            ),
          ],
        ),
      ),
    );

    title.dispose();
    group.dispose();
  }
}
