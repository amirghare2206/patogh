import 'package:flutter/material.dart';
import 'package:patogh/models/media_attachment.dart';

class MediaAttachmentStrip extends StatelessWidget {
  final List<MediaAttachment> media;
  final double height;
  const MediaAttachmentStrip({
    super.key,
    required this.media,
    this.height = 150,
  });
  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: media.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = media[index];
          if (item.kind == MediaKind.image && item.url != null) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                item.url!,
                width: 150,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(item),
              ),
            );
          }
          return _placeholder(item);
        },
      ),
    );
  }

  Widget _placeholder(MediaAttachment item) {
    final icon = switch (item.kind) {
      MediaKind.video => Icons.play_circle_fill_rounded,
      MediaKind.audio => Icons.graphic_eq_rounded,
      MediaKind.image => Icons.image_rounded,
    };
    return Container(
      width: 150,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(child: Icon(icon, size: 42)),
    );
  }
}
