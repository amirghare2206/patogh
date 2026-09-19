import 'package:flutter/material.dart';
import 'package:patogh/models/v9_models.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/state/v9_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class EventMemoriesPage extends StatelessWidget {
  final String eventId;
  final String eventTitle;

  const EventMemoriesPage({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خاطرات این رویداد'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addMemory(context),
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('ثبت یادگاری'),
      ),
      body: AnimatedBuilder(
        animation: v9State,
        builder: (context, _) {
          final items = v9State.memoriesForEvent(eventId);

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A2C19), Color(0xFF171717)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: PatoghTheme.orange,
                      size: 34,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      eventTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'عکس، ویدئو، متن، صدا یا یادگاری ثبت کن. برای هر محتوا خودت تعیین می‌کنی چه کسانی ببینند و تا چه مدت در فضای مشترک رویداد بماند.',
                      style: TextStyle(
                        color: Color(0xFFCCCCCC),
                        fontSize: 11,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 42),
                  child: Center(
                    child: Text(
                      'هنوز خاطره‌ای برای این رویداد ثبت نشده.',
                      style: TextStyle(color: Color(0xFFAAAAAA)),
                    ),
                  ),
                )
              else
                ...items.map((item) => _memoryCard(item)),
            ],
          );
        },
      ),
    );
  }

  Widget _memoryCard(EventMemoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF242424)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF2A2A2A),
                child: Icon(
                  _iconFor(item.mediaType),
                  color: PatoghTheme.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.author,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '${item.mediaType.label} • ${item.createdAtLabel}',
                      style: const TextStyle(
                        color: Color(0xFF8F8F8F),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.verifiedAttendance)
                const Tooltip(
                  message: 'حضور تأییدشده',
                  child: Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF7BE0A8),
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height:
                item.mediaType == MemoryMediaType.text ||
                    item.mediaType == MemoryMediaType.guestbook
                ? 0
                : 130,
            decoration:
                item.mediaType == MemoryMediaType.text ||
                    item.mediaType == MemoryMediaType.guestbook
                ? null
                : BoxDecoration(
                    color: const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(16),
                  ),
            child:
                item.mediaType == MemoryMediaType.text ||
                    item.mediaType == MemoryMediaType.guestbook
                ? null
                : Center(
                    child: Icon(
                      _iconFor(item.mediaType),
                      size: 46,
                      color: const Color(0xFF777777),
                    ),
                  ),
          ),
          if (item.mediaType != MemoryMediaType.text &&
              item.mediaType != MemoryMediaType.guestbook)
            const SizedBox(height: 10),
          Text(item.caption, style: const TextStyle(height: 1.7)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              Chip(label: Text(item.visibility.label)),
              Chip(
                label: Text(
                  item.retentionDays == 0
                      ? 'یادگاری دائمی'
                      : 'نمایش مشترک ${item.retentionDays} روز',
                ),
              ),
              if (item.sharedToTimeline)
                const Chip(label: Text('اشتراک در تایم‌لاین')),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconFor(MemoryMediaType type) {
    switch (type) {
      case MemoryMediaType.photo:
        return Icons.photo_rounded;
      case MemoryMediaType.video:
        return Icons.videocam_rounded;
      case MemoryMediaType.text:
        return Icons.edit_note_rounded;
      case MemoryMediaType.audio:
        return Icons.mic_rounded;
      case MemoryMediaType.guestbook:
        return Icons.menu_book_rounded;
    }
  }

  Future<void> _addMemory(BuildContext context) async {
    final captionController = TextEditingController();
    var mediaType = MemoryMediaType.photo;
    var visibility = MemoryVisibility.eventMembers;
    var retentionDays = 365;
    var shareToTimeline = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('ثبت یادگاری'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<MemoryMediaType>(
                      initialValue: mediaType,
                      decoration: const InputDecoration(labelText: 'نوع محتوا'),
                      items: MemoryMediaType.values
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() => mediaType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: captionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'خاطره / توضیح',
                        hintText:
                            'چیزی که می‌خواهی از این برنامه به یادگار بماند...',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<MemoryVisibility>(
                      initialValue: visibility,
                      decoration: const InputDecoration(
                        labelText: 'چه کسانی ببینند؟',
                      ),
                      items: MemoryVisibility.values
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() => visibility = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      initialValue: retentionDays,
                      decoration: const InputDecoration(
                        labelText: 'ماندگاری در فضای مشترک',
                      ),
                      items: const [
                        DropdownMenuItem(value: 30, child: Text('۳۰ روز')),
                        DropdownMenuItem(value: 365, child: Text('یک سال')),
                        DropdownMenuItem(value: 0, child: Text('دائمی')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() => retentionDays = value);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      value: shareToTimeline,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) =>
                          setLocalState(() => shareToTimeline = value),
                      title: const Text('همزمان در تایم‌لاین هم منتشر شود'),
                    ),
                    const Text(
                      'در نسخه Production، فایل اصلی روی Object Storage ذخیره و دسترسی آن بر اساس همین انتخاب‌ها کنترل می‌شود.',
                      style: TextStyle(
                        color: Color(0xFF8F8F8F),
                        fontSize: 9,
                        height: 1.6,
                      ),
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
                    final caption = captionController.text.trim();
                    if (caption.isEmpty) return;

                    await v9State.addMemory(
                      eventId: eventId,
                      eventTitle: eventTitle,
                      author: appState.profile?.name ?? 'کاربر پاتوق',
                      caption: caption,
                      mediaType: mediaType,
                      visibility: visibility,
                      retentionDays: retentionDays,
                      sharedToTimeline: shareToTimeline,
                    );

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('ثبت خاطره'),
                ),
              ],
            );
          },
        );
      },
    );

    captionController.dispose();
  }
}
