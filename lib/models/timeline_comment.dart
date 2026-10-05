class TimelineComment {
  final String id;
  final String postId;
  final String? authorId;
  final String authorName;
  final String text;
  final String createdAt;

  const TimelineComment({
    required this.id,
    required this.postId,
    this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  factory TimelineComment.fromMap(Map<String, dynamic> map) => TimelineComment(
        id: '${map['id']}',
        postId: '${map['post_id'] ?? map['postId'] ?? ''}',
        authorId: (map['user_id'] ?? map['authorId']) as String?,
        authorName:
            (map['author_name'] ?? map['authorName']) as String? ?? 'کاربر پاتوق',
        text: (map['text'] as String?) ?? '',
        createdAt: '${map['created_at'] ?? map['createdAt'] ?? ''}',
      );

  factory TimelineComment.fromJson(Map<String, dynamic> json) =>
      TimelineComment.fromMap(json);

  Map<String, dynamic> toJson() => {
        'id': id,
        'post_id': postId,
        'user_id': authorId,
        'author_name': authorName,
        'text': text,
        'created_at': createdAt,
      };
}
