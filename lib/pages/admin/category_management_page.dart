import 'package:flutter/material.dart';
import 'package:patogh/models/patogh_category.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class CategoryManagementPage extends StatelessWidget {
  const CategoryManagementPage({super.key});

  static const _iconChoices = <IconData>[
    Icons.groups_rounded,
    Icons.forum_rounded,
    Icons.sports_esports_rounded,
    Icons.travel_explore_rounded,
    Icons.school_rounded,
    Icons.work_rounded,
    Icons.sports_basketball_rounded,
    Icons.palette_rounded,
    Icons.restaurant_rounded,
    Icons.music_note_rounded,
    Icons.local_cafe_rounded,
    Icons.volunteer_activism_rounded,
  ];

  static const _colorChoices = <Color>[
    PatoghTheme.orange,
    PatoghTheme.teal,
    PatoghTheme.blue,
    PatoghTheme.purple,
    PatoghTheme.pink,
    PatoghTheme.yellow,
    PatoghTheme.green,
  ];

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
                    'سربرگ‌های رویداد',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton.filled(
                  onPressed: () => _newCategory(context),
                  icon: const Icon(Icons.add_rounded),
                  tooltip: 'سربرگ جدید',
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'برای هر سربرگ عنوان، توضیح، رنگ و لوگوی آماده انتخاب کن. اگر لینک لوگوی اختصاصی وارد شود همان تصویر نمایش داده می‌شود.',
              style: TextStyle(
                color: PatoghTheme.muted,
                fontSize: 12,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 18),
            ...appState.categories.map(
              (category) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: PatoghTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  child: SwitchListTile(
                    value: category.isActive,
                    onChanged: (_) => appState.toggleCategory(category.id),
                    secondary: _categoryLogo(category),
                    title: Text(
                      category.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      category.subtitle,
                      style: const TextStyle(
                        color: PatoghTheme.muted,
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

  Widget _categoryLogo(PatoghCategory category) {
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: category.accent.withAlpha(35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: category.logoUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                category.logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Icon(category.icon, color: category.accent),
              ),
            )
          : Icon(category.icon, color: category.accent),
    );
  }

  Future<void> _newCategory(BuildContext context) async {
    final title = TextEditingController();
    final subtitle = TextEditingController();
    final logoUrl = TextEditingController();
    var selectedIcon = _iconChoices.first;
    var selectedColor = _colorChoices.first;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('سربرگ جدید رویداد'),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'نام سربرگ'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: subtitle,
                    decoration: const InputDecoration(labelText: 'توضیح کوتاه'),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'لوگوی آماده',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _iconChoices.map((icon) {
                      final selected = icon.codePoint == selectedIcon.codePoint;
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => setLocalState(() => selectedIcon = icon),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: selected
                                ? selectedColor.withAlpha(55)
                                : PatoghTheme.surface2,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? selectedColor
                                  : const Color(0xFF3C426D),
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: selected ? selectedColor : Colors.white70,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'رنگ سربرگ',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: _colorChoices.map((color) {
                      final selected =
                          color.toARGB32() == selectedColor.toARGB32();
                      return InkWell(
                        onTap: () => setLocalState(() => selectedColor = color),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: selected
                              ? const Icon(Icons.check_rounded, size: 18)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: logoUrl,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'لینک لوگوی اختصاصی (اختیاری)',
                      hintText: 'https://.../logo.png',
                      helperText:
                          'اگر خالی باشد لوگوی آماده بالا استفاده می‌شود.',
                    ),
                  ),
                ],
              ),
            ),
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
                final customLogo = logoUrl.text.trim();
                await appState.addCategory(
                  PatoghCategory(
                    id: 'category-${DateTime.now().microsecondsSinceEpoch}',
                    title: name,
                    subtitle: subtitle.text.trim(),
                    iconCodePoint: selectedIcon.codePoint,
                    colorValue: selectedColor.toARGB32(),
                    sortOrder: appState.categories.length + 1,
                    logoUrl: customLogo.isEmpty ? null : customLogo,
                  ),
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
    subtitle.dispose();
    logoUrl.dispose();
  }
}
