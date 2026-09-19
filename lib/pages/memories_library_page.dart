import 'package:flutter/material.dart';
import 'package:patogh/pages/event_memories_page.dart';
import 'package:patogh/state/v9_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class MemoriesLibraryPage extends StatelessWidget {
  const MemoriesLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خاطرات و سالگردها'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: AnimatedBuilder(
        animation: v9State,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      color: PatoghTheme.orange,
                      size: 38,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'پاتوق می‌تواند رویدادهای مهمت را به یک کپسول خاطره تبدیل کند؛ عکس‌ها، یادداشت‌ها و یادگاری‌ها با سطح دسترسی‌ای که خودت انتخاب کرده‌ای.',
                        style: TextStyle(height: 1.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'کپسول‌های خاطره',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ...v9State.capsules.map(
                (capsule) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EventMemoriesPage(
                            eventId: capsule.eventId,
                            eventTitle: capsule.eventTitle,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Color(0xFF2A2A2A),
                                  child: Icon(
                                    Icons.photo_album_rounded,
                                    color: PatoghTheme.orange,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        capsule.eventTitle,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        '${capsule.eventDateLabel} • ${capsule.eventType}',
                                        style: const TextStyle(
                                          color: Color(0xFF999999),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 7,
                              runSpacing: 7,
                              children: [
                                Chip(
                                  label: Text('${capsule.memoryCount} یادگاری'),
                                ),
                                Chip(
                                  label: Text(
                                    '${capsule.participantCount} نفر',
                                  ),
                                ),
                                if (capsule.anniversaryEnabled)
                                  Chip(
                                    label: Text(
                                      'سالگرد بعدی: ${capsule.nextAnniversaryLabel}',
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
