import 'package:flutter/material.dart';
import 'package:patogh/models/media_attachment.dart';
import 'package:patogh/services/media_policy.dart';
import 'package:patogh/services/media_service.dart';

class MediaPickerPanel extends StatefulWidget {
  final List<SelectedMedia> items;
  final bool postOrStory;
  final bool allowAudio;
  const MediaPickerPanel({
    super.key,
    required this.items,
    required this.postOrStory,
    this.allowAudio = false,
  });
  @override
  State<MediaPickerPanel> createState() => _MediaPickerPanelState();
}

class _MediaPickerPanelState extends State<MediaPickerPanel> {
  String? error;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: _addImages,
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('عکس'),
          ),
          OutlinedButton.icon(
            onPressed: _addVideo,
            icon: const Icon(Icons.video_library_rounded),
            label: const Text('ویدئو'),
          ),
          if (widget.allowAudio)
            OutlinedButton.icon(
              onPressed: _addAudio,
              icon: const Icon(Icons.mic_rounded),
              label: const Text('ویس/صوت'),
            ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          widget.postOrStory
              ? 'حداکثر ۲۰ رسانه؛ ویدئو حداکثر ۲ دقیقه'
              : 'عکس و ویس محدودیت تعداد ندارند؛ ویدئو حداکثر ۱۰ مگابایت',
          style: const TextStyle(color: Color(0xFF999999), fontSize: 10),
        ),
      ),
      if (error != null)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            error!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 11),
          ),
        ),
      if (widget.items.isNotEmpty) ...[
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(widget.items.length, (index) {
            final item = widget.items[index];
            return InputChip(
              avatar: Icon(switch (item.kind) {
                MediaKind.video => Icons.videocam_rounded,
                MediaKind.audio => Icons.graphic_eq_rounded,
                MediaKind.image => Icons.image_rounded,
              }, size: 16),
              label: Text(
                '${index + 1}. ${item.fileName}',
                overflow: TextOverflow.ellipsis,
              ),
              onDeleted: () => setState(() => widget.items.removeAt(index)),
            );
          }),
        ),
      ],
    ],
  );
  Future<void> _addImages() async {
    final picked = await MediaService.pickImages();
    if (!mounted) return;
    if (widget.postOrStory &&
        widget.items.length + picked.length > MediaPolicy.maxPostStoryItems) {
      setState(() => error = 'در هر پست یا استوری حداکثر ۲۰ رسانه مجاز است.');
      return;
    }
    setState(() {
      error = null;
      widget.items.addAll(picked);
    });
  }

  Future<void> _addVideo() async {
    final picked = await MediaService.pickVideo();
    if (picked == null || !mounted) return;
    final message = widget.postOrStory
        ? MediaPolicy.validatePostStory(
            existingItems: widget.items.length,
            kind: picked.kind,
            durationMs: picked.durationMs,
          )
        : MediaPolicy.validateCommunity(
            kind: picked.kind,
            sizeBytes: picked.sizeBytes,
          );
    if (message != null) {
      setState(() => error = message);
      return;
    }
    setState(() {
      error = null;
      widget.items.add(picked);
    });
  }

  Future<void> _addAudio() async {
    final picked = await MediaService.pickAudio();
    if (!mounted) return;
    setState(() {
      error = null;
      widget.items.addAll(picked);
    });
  }
}
