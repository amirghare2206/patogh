class TimelinePost {
  final String id;
  final String author;
  final String roleLabel;
  final String eventTitle;
  final String text;
  final String createdAt;
  final int likes;

  const TimelinePost({
    required this.id,
    required this.author,
    required this.roleLabel,
    required this.eventTitle,
    required this.text,
    required this.createdAt,
    this.likes = 0,
  });

  TimelinePost copyWith({int? likes}) {
    return TimelinePost(
      id: id,
      author: author,
      roleLabel: roleLabel,
      eventTitle: eventTitle,
      text: text,
      createdAt: createdAt,
      likes: likes ?? this.likes,
    );
  }
}
