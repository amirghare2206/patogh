import 'package:patogh/models/user_role.dart';

class StoryItem {
  final String id;
  final String owner;
  final UserRole ownerRole;
  final String title;
  final String subtitle;
  final String createdAt;

  const StoryItem({
    required this.id,
    required this.owner,
    required this.ownerRole,
    required this.title,
    required this.subtitle,
    required this.createdAt,
  });
}
