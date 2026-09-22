import 'package:flutter/material.dart';
import 'package:patogh/models/media_attachment.dart';
import 'package:patogh/models/user_role.dart';
import 'package:patogh/services/media_service.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';
import 'package:patogh/widgets/media_attachment_strip.dart';
import 'package:patogh/widgets/media_picker_panel.dart';

class StoriesPage extends StatelessWidget {
  const StoriesPage({super.key});
  bool get canCreate =>
      appState.role == UserRole.venue ||
      appState.role == UserRole.organizer ||
      appState.role == UserRole.admin;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: AnimatedBuilder(
      animation: appState,
      builder: (context, _) => RefreshIndicator(
        onRefresh: () => appState.refreshSocialV12(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'استوری‌ها',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ),
                if (canCreate)
                  FilledButton.icon(
                    onPressed: () => _createStory(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('استوری جدید'),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'لحظه‌ها، خبرها و تجربه‌های تازه از دنیای پاتوق',
              style: TextStyle(color: PatoghTheme.muted, fontSize: 12),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 98,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: appState.stories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final story = appState.stories[index];
                  return InkWell(
                    onTap: () => _showStory(
                      context,
                      story.title,
                      story.subtitle,
                      story.media,
                    ),
                    child: SizedBox(
                      width: 74,
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [PatoghTheme.orange, PatoghTheme.blue],
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: const Color(0xFF252525),
                              child: Icon(
                                story.ownerRole == UserRole.venue
                                    ? Icons.storefront_rounded
                                    : Icons.campaign_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            story.owner,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            ...appState.stories.map(
              (story) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF332417), Color(0xFF171717)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: PatoghTheme.orange,
                          child: Icon(
                            story.ownerRole == UserRole.venue
                                ? Icons.storefront_rounded
                                : Icons.campaign_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                story.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                story.subtitle,
                                style: const TextStyle(
                                  color: Color(0xFFBBBBBB),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${story.owner} • ${story.createdAt}',
                                style: const TextStyle(
                                  color: Color(0xFF858585),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (story.media.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      MediaAttachmentStrip(media: story.media, height: 120),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _createStory(BuildContext context) async {
    final title = TextEditingController();
    final subtitle = TextEditingController();
    final media = <SelectedMedia>[];
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('استوری جدید'),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'عنوان'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: subtitle,
                  decoration: const InputDecoration(labelText: 'توضیح'),
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
              if (title.text.trim().isEmpty && media.isEmpty) return;
              await appState.addStory(
                title: title.text.trim(),
                subtitle: subtitle.text.trim(),
                media: media,
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('انتشار'),
          ),
        ],
      ),
    );
    title.dispose();
    subtitle.dispose();
  }

  void _showStory(
    BuildContext context,
    String title,
    String subtitle,
    List<MediaAttachment> media,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF55331D), Color(0xFF111111)],
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.auto_stories_rounded,
                size: 72,
                color: PatoghTheme.orange,
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFD3D3D3), fontSize: 16),
              ),
              if (media.isNotEmpty) ...[
                const SizedBox(height: 16),
                MediaAttachmentStrip(media: media, height: 170),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
