import 'package:flutter/material.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class VenueMenuPage extends StatelessWidget {
  const VenueMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('منوی میزبان'),
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
                'آیتم‌های فعال در مرحله رزرو به کاربر نمایش داده می‌شوند و سفارش به همان رویداد و شرکت‌کننده متصل خواهد شد.',
                style: TextStyle(color: Color(0xFFAAAAAA), height: 1.7),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () => _add(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('افزودن آیتم منو'),
              ),
              const SizedBox(height: 16),
              ...appState.venueMenu.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF2A2A2A),
                        child: Icon(
                          Icons.restaurant_menu_rounded,
                          color: PatoghTheme.orange,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${item.category} • ${item.description}',
                              style: const TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${item.price}\nتومان',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: PatoghTheme.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
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
    final category = TextEditingController(text: 'پذیرایی');
    final price = TextEditingController();
    final description = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('آیتم جدید'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'نام آیتم'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: category,
                decoration: const InputDecoration(labelText: 'دسته منو'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'قیمت'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: description,
                decoration: const InputDecoration(labelText: 'توضیح'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () async {
              final parsed = int.tryParse(price.text.trim());
              if (title.text.trim().isEmpty || parsed == null) return;
              await appState.addMenuItem(
                title: title.text.trim(),
                category: category.text.trim(),
                price: parsed,
                description: description.text.trim(),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );

    title.dispose();
    category.dispose();
    price.dispose();
    description.dispose();
  }
}
