import 'package:flutter/material.dart';
import 'package:patogh/models/patogh_category.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class CategoryManagementPage extends StatelessWidget {
  const CategoryManagementPage({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: appState,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'مدیریت دسته‌بندی‌ها',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton.filled(
                  onPressed: () => _newCategory(context),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'هر دسته فعال در صفحه رزرو کاربران نمایش داده می‌شود.',
              style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 12),
            ),
            const SizedBox(height: 18),
            ...appState.categories.map(
              (category) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(18),
                  child: SwitchListTile(
                    value: category.isActive,
                    onChanged: (_) => appState.toggleCategory(category.id),
                    secondary: Icon(category.icon, color: category.accent),
                    title: Text(
                      category.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      category.subtitle,
                      style: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _newCategory(BuildContext context) async {
    final title = TextEditingController();
    final subtitle = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('دسته‌بندی جدید'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'نام دسته'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: subtitle,
              decoration: const InputDecoration(labelText: 'توضیح کوتاه'),
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
              final name = title.text.trim();
              if (name.isEmpty) return;
              await appState.addCategory(
                PatoghCategory(
                  id: 'category-${DateTime.now().microsecondsSinceEpoch}',
                  title: name,
                  subtitle: subtitle.text.trim(),
                  iconCodePoint: Icons.category_rounded.codePoint,
                  colorValue: PatoghTheme.orange.toARGB32(),
                  sortOrder: appState.categories.length + 1,
                ),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('افزودن'),
          ),
        ],
      ),
    );
    title.dispose();
    subtitle.dispose();
  }
}
