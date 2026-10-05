import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patogh/models/timeline_comment.dart';
import 'package:patogh/models/timeline_post.dart';
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
                if (appState.timelineLoading) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(minHeight: 2),
                ],
                if (appState.timelineError != null) ...[
                  const SizedBox(height: 12),
                  _errorBanner(context, appState.timelineError!),
                ],
                const SizedBox(height: 12),
                _promoBanner(),
                const SizedBox(height: 18),
                if (!appState.timelineLoading && appState.timelinePosts.isEmpty)
                  _emptyTimeline(canPost)
                else
                  ...appState.timelinePosts.map(
                    (post) => _postCard(context, post),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _errorBanner(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1717),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF6B2D2D)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await appState.refreshTimelineV14();
              } catch (_) {}
            },
            child: const Text('تلاش دوباره'),
          ),
        ],
      ),
    );
  }

  Widget _emptyTimeline(bool canPost) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(Icons.dynamic_feed_rounded, size: 52),
          const SizedBox(height: 12),
          const Text(
            'هنوز تجربه‌ای در تایم‌لاین نیست',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            canPost
                ? 'اولین تجربه این جمع را منتشر کن.'
                : 'بعد از حضور در یک پاتوق می‌توانی تجربه‌ات را منتشر کنی.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: PatoghTheme.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _postCard(BuildContext context, TimelinePost post) {
    final busy = appState.isTimelineActionBusy(post.id);

    return Container(
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
                      style: const TextStyle(fontWeight: FontWeight.w900),
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
              if (post.savedByMe)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.bookmark_rounded,
                    size: 18,
                    color: PatoghTheme.orange,
                  ),
                ),
              if (post.authorId != null &&
                  post.authorId != PlatformServices.currentUserId)
                PopupMenuButton<String>(
                  enabled: !busy,
                  onSelected: (value) async {
                    try {
                      if (value == 'report') {
                        await appState.reportContent(
                          targetType: 'timeline_post',
                          targetId: post.id,
                        );
                        if (context.mounted) {
                          _snack(context, 'گزارش ثبت شد.');
                        }
                      } else if (value == 'block' && post.authorId != null) {
                        await appState.blockUser(post.authorId!);
                        if (context.mounted) {
                          _snack(context, 'کاربر مسدود شد.');
                        }
                      }
                    } catch (error) {
                      if (context.mounted) {
                        _snack(context, 'عملیات انجام نشد: $error');
                      }
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
          const Divider(height: 1, color: Color(0xFF252525)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _actionButton(
                tooltip: post.likedByMe ? 'برداشتن پسند' : 'پسندیدن',
                icon: post.likedByMe
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                count: post.likes,
                active: post.likedByMe,
                enabled: !busy,
                onPressed: () => _like(context, post),
              ),
              _actionButton(
                tooltip: 'کامنت‌ها',
                icon: Icons.chat_bubble_outline_rounded,
                count: post.commentsCount,
                enabled: !busy,
                onPressed: () => _openComments(context, post),
              ),
              _actionButton(
                tooltip: 'کپی برای اشتراک‌گذاری',
                icon: Icons.ios_share_rounded,
                count: post.sharesCount,
                enabled: !busy,
                onPressed: () => _share(context, post),
              ),
              IconButton(
                tooltip: post.savedByMe ? 'حذف از ذخیره‌ها' : 'ذخیره پست',
                onPressed: busy ? null : () => _save(context, post),
                icon: Icon(
                  post.savedByMe
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: post.savedByMe ? PatoghTheme.orange : null,
                ),
              ),
            ],
          ),
          if (busy) const LinearProgressIndicator(minHeight: 1),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String tooltip,
    required IconData icon,
    required int count,
    required VoidCallback onPressed,
    bool active = false,
    bool enabled = true,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: enabled ? onPressed : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: tooltip,
              child: Icon(
                icon,
                size: 21,
                color: active ? PatoghTheme.orange : null,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Text('$count', style: const TextStyle(fontSize: 11)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _like(BuildContext context, TimelinePost post) async {
    try {
      await appState.likeTimelinePost(post.id);
    } catch (error) {
      if (context.mounted) _snack(context, 'ثبت پسند انجام نشد: $error');
    }
  }

  Future<void> _save(BuildContext context, TimelinePost post) async {
    try {
      final saved = await appState.toggleTimelineSave(post.id);
      if (context.mounted) {
        _snack(context, saved ? 'پست ذخیره شد.' : 'از ذخیره‌ها حذف شد.');
      }
    } catch (error) {
      if (context.mounted) _snack(context, 'ذخیره پست انجام نشد: $error');
    }
  }

  Future<void> _share(BuildContext context, TimelinePost post) async {
    try {
      await appState.shareTimelinePost(post.id);
      final text = <String>[
        '${post.author} — ${post.eventTitle}',
        if (post.text.trim().isNotEmpty) post.text.trim(),
        'پاتوق',
      ].join('\n');
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        _snack(
          context,
          'متن پست برای اشتراک‌گذاری کپی شد.',
        );
      }
    } catch (error) {
      if (context.mounted) {
        _snack(context, 'اشتراک‌گذاری ثبت نشد: $error');
      }
    }
  }

  Future<void> _openComments(BuildContext context, TimelinePost post) async {
    try {
      await appState.loadTimelineComments(post.id);
    } catch (error) {
      if (context.mounted) {
        _snack(context, 'کامنت‌ها بارگذاری نشدند: $error');
      }
      return;
    }

    if (!context.mounted) return;
    final controller = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF151515),
      builder: (sheetContext) => AnimatedBuilder(
        animation: appState,
        builder: (sheetContext, _) {
          final comments = appState.commentsForPost(post.id);
          final loading = appState.areTimelineCommentsLoading(post.id);
          final busy = appState.isTimelineActionBusy(post.id);

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 14,
              bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + 14,
            ),
            child: SizedBox(
              height: MediaQuery.sizeOf(sheetContext).height * 0.70,
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF505050),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'گفت‌وگو',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        '${comments.length} کامنت',
                        style: const TextStyle(
                          color: PatoghTheme.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (loading) const LinearProgressIndicator(minHeight: 2),
                  Expanded(
                    child: comments.isEmpty && !loading
                        ? const Center(
                            child: Text(
                              'هنوز کامنتی ثبت نشده؛ شروع‌کننده گفت‌وگو باش.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: PatoghTheme.muted,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: comments.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, index) =>
                                _commentTile(comments[index]),
                          ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          enabled: !busy,
                          minLines: 1,
                          maxLines: 4,
                          maxLength: 2000,
                          decoration: const InputDecoration(
                            hintText: 'کامنت بنویس...',
                            counterText: '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        tooltip: 'ارسال کامنت',
                        onPressed: busy
                            ? null
                            : () async {
                                final text = controller.text.trim();
                                if (text.isEmpty) return;
                                try {
                                  await appState.addTimelineComment(
                                    post.id,
                                    text,
                                  );
                                  controller.clear();
                                } catch (error) {
                                  if (sheetContext.mounted) {
                                    _snack(
                                      sheetContext,
                                      'ارسال کامنت انجام نشد: $error',
                                    );
                                  }
                                }
                              },
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    controller.dispose();
  }

  Widget _commentTile(TimelineComment comment) {
    final mine = comment.authorId != null &&
        comment.authorId == PlatformServices.currentUserId;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: mine ? const Color(0xFF242018) : const Color(0xFF202020),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  comment.authorName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                _commentTime(comment.createdAt),
                style: const TextStyle(
                  color: PatoghTheme.muted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(comment.text, style: const TextStyle(height: 1.6)),
        ],
      ),
    );
  }

  String _commentTime(String raw) {
    final date = DateTime.tryParse(raw)?.toLocal();
    if (date == null) return raw.isEmpty ? 'همین الان' : raw;
    final diff = DateTime.now().difference(date);
    if (diff.isNegative || diff.inMinutes < 1) return 'همین الان';
    if (diff.inMinutes < 60) return '${diff.inMinutes} دقیقه پیش';
    if (diff.inHours < 24) return '${diff.inHours} ساعت پیش';
    if (diff.inDays < 7) return '${diff.inDays} روز پیش';
    return '${date.year}/${date.month}/${date.day}';
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
                  maxLength: 4000,
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
              try {
                await appState.addTimelinePost(
                  eventTitle: eventTitle,
                  text: text,
                  media: media,
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } catch (error) {
                if (dialogContext.mounted) {
                  _snack(dialogContext, 'انتشار پست انجام نشد: $error');
                }
              }
            },
            child: const Text('انتشار'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }
}
