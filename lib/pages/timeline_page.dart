import 'package:flutter/material.dart';
import 'package:patogh/models/user_role.dart';
import 'package:patogh/services/media_service.dart';
import 'package:patogh/services/platform_services.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';
import 'package:patogh/widgets/media_attachment_strip.dart';
import 'package:patogh/widgets/media_picker_panel.dart';

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
              appState.role != UserRole.participant;
          return RefreshIndicator(
            onRefresh: () => appState.refreshSocialV12(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                const SizedBox(height: 12),
                _promoBanner(),
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
                            if (post.authorId != null &&
                                post.authorId != PlatformServices.currentUserId)
                              PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'report') {
                                    await appState.reportContent(
                                      targetType: 'timeline_post',
                                      targetId: post.id,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            const SnackBar(
                                              content: Text('گزارش ثبت شد.'),
                                            ),
                                          );
                                    }
                                  } else if (value == 'block' &&
                                      post.authorId != null) {
                                    await appState.blockUser(post.authorId!);
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'report',
                                    child: Text('گزارش محتوا'),
                                  ),
                                  PopupMenuItem(
                                    value: 'block',
                                    child: Text('مسدود کردن کاربر'),
                                  ),
                                ],
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
                        if (post.text.isNotEmpty) ...[
                          const SizedBox(height: 7),
                          Text(post.text, style: const TextStyle(height: 1.7)),
                        ],
                        if (post.media.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          MediaAttachmentStrip(media: post.media),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  appState.likeTimelinePost(post.id),
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
            ),
          );
        },
      ),
    );
  }

  Widget _promoBanner() {
    final items = appState.banners
        .where((item) => item.placement == 'timeline')
        .toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final banner = items.first;
    if (banner.imageAsset != null || banner.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 2.35,
          child: banner.imageAsset != null
              ? Image.asset(
                  banner.imageAsset!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      _promoFallback(banner.title, banner.subtitle),
                )
              : Image.network(
                  banner.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      _promoFallback(banner.title, banner.subtitle),
                ),
        ),
      );
    }
    return _promoFallback(banner.title, banner.subtitle);
  }

  Widget _promoFallback(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PatoghTheme.purple, PatoghTheme.surface],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign_rounded, color: PatoghTheme.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: PatoghTheme.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _newPost(BuildContext context) async {
    final controller = TextEditingController();
    final media = <SelectedMedia>[];
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
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'تجربه‌ات از پاتوق رو بنویس...',
                  ),
                ),
                const SizedBox(height: 12),
                MediaPickerPanel(items: media, postOrStory: true),
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
              final text = controller.text.trim();
              if (text.isEmpty && media.isEmpty) return;
              await appState.addTimelinePost(
                eventTitle: eventTitle,
                text: text,
                media: media,
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
