import 'package:flutter/material.dart';
import 'package:patogh/theme/patogh_theme.dart';

class AdminEntitiesPage extends StatelessWidget {
  const AdminEntitiesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final sections = const [
      ('کسب‌وکارهای میزبان', '۶۳', Icons.storefront_rounded),
      ('هماهنگ‌کننده‌ها', '۲۷', Icons.badge_rounded),
      ('برگزارکننده‌ها و آژانس‌ها', '۳۸', Icons.campaign_rounded),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('نقش‌های حرفه‌ای'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: sections
            .map(
              (s) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(s.$3, color: PatoghTheme.orange, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        s.$1,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text(
                      s.$2,
                      style: const TextStyle(
                        fontSize: 20,
                        color: PatoghTheme.orange,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
