import 'package:flutter/material.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final canPost =
              appState.reservedIds.isNotEmpty ||
              appState.role.name != 'participant';
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'تایم‌لاین پاتوق',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (canPost)
                    FilledButton.icon(
                      onPressed: () => _newPost(context),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('تجربه جدید'),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'تجربه آدم‌ها از پاتوق‌هایی که در آن‌ها حضور داشته‌اند',
                style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 12),
              ),
              const SizedBox(height: 18),
              ...appState.timelinePosts.map(
                (post) => Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFF2A2A2A),
                            child: Icon(Icons.person_rounded),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.author,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  '${post.roleLabel} • ${post.createdAt}',
                                  style: const TextStyle(
                                    color: Color(0xFF8F8F8F),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        post.eventTitle,
                        style: const TextStyle(
                          color: PatoghTheme.orange,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(post.text, style: const TextStyle(height: 1.7)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => appState.likeTimelinePost(post.id),
                            icon: const Icon(Icons.favorite_border_rounded),
                          ),
                          Text('${post.likes}'),
                          const Spacer(),
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          const Text('گفت‌وگو'),
                        ],
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

  Future<void> _newPost(BuildContext context) async {
    final controller = TextEditingController();
    String eventTitle = 'پاتوق';
    for (final event in appState.events) {
      if (appState.reservedIds.contains(event.id)) {
        eventTitle = event.title;
        break;
      }
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('اشتراک تجربه'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'تجربه‌ات از پاتوق رو بنویس...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              await appState.addTimelinePost(
                eventTitle: eventTitle,
                text: text,
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('انتشار'),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}
