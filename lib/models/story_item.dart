import 'package:patogh/models/media_attachment.dart';
import 'package:patogh/models/user_role.dart';

class StoryItem {
  final String id;
  final String? ownerId;
  final String owner;
  final UserRole ownerRole;
  final String title;
  final String subtitle;
  final String createdAt;
  final List<MediaAttachment> media;
  const StoryItem({
    required this.id,
    this.ownerId,
    required this.owner,
    required this.ownerRole,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    this.media = const [],
  });
}
