import 'package:patogh/models/media_attachment.dart';

class TimelinePost {
  final String id;
  final String? authorId;
  final String author;
  final String roleLabel;
  final String eventTitle;
  final String text;
  final String createdAt;
  final int likes;
  final List<MediaAttachment> media;
  const TimelinePost({
    required this.id,
    this.authorId,
    required this.author,
    required this.roleLabel,
    required this.eventTitle,
    required this.text,
    required this.createdAt,
    this.likes = 0,
    this.media = const [],
  });
  TimelinePost copyWith({int? likes, List<MediaAttachment>? media}) =>
      TimelinePost(
        id: id,
        authorId: authorId,
        author: author,
        roleLabel: roleLabel,
        eventTitle: eventTitle,
        text: text,
        createdAt: createdAt,
        likes: likes ?? this.likes,
        media: media ?? this.media,
      );
}
