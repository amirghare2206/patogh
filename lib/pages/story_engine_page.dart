import 'package:flutter/material.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/state/engagement_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class StoryEnginePage extends StatelessWidget {
  const StoryEnginePage({super.key});

  @override
  Widget build(BuildContext context) {
    final blueprint = engagementState.blueprints.first;
    return Scaffold(
      appBar: AppBar(
        title: const Text('داستان یک پاتوق'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF50311E), Color(0xFF171717)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'قبل از رویداد • وعده تجربه',
                  style: TextStyle(
                    color: PatoghTheme.orange,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  blueprint.promise,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'فصل‌های تجربه',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...blueprint.chapters.asMap().entries.map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF2A2119),
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: PatoghTheme.orange,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.value.title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          entry.value.prompt,
                          style: const TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 11,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
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
                  'بعد از رویداد • ساخت خاطره',
                  style: TextStyle(
                    color: PatoghTheme.orange,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  blueprint.memoryPrompt,
                  style: const TextStyle(height: 1.7),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'در Production، عکس‌ها، ویدئوها و پیام‌های ${appState.profile?.name ?? 'کاربر'} با اجازه او به روایت جمعی تبدیل می‌شوند.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('پیش‌نمایش داستان خاطره'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
