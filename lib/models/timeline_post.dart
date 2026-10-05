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
  final int commentsCount;
  final int sharesCount;
  final bool likedByMe;
  final bool savedByMe;
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
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.likedByMe = false,
    this.savedByMe = false,
    this.media = const [],
  });

  factory TimelinePost.fromJson(Map<String, dynamic> json) => TimelinePost(
        id: '${json['id']}',
        authorId: json['authorId'] as String?,
        author: (json['author'] as String?) ?? 'کاربر پاتوق',
        roleLabel: (json['roleLabel'] as String?) ?? 'شرکت‌کننده',
        eventTitle: (json['eventTitle'] as String?) ?? 'پاتوق',
        text: (json['text'] as String?) ?? '',
        createdAt: (json['createdAt'] as String?) ?? 'همین الان',
        likes: (json['likes'] as num?)?.toInt() ?? 0,
        commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
        sharesCount: (json['sharesCount'] as num?)?.toInt() ?? 0,
        likedByMe: (json['likedByMe'] as bool?) ?? false,
        savedByMe: (json['savedByMe'] as bool?) ?? false,
        media: ((json['media'] as List?) ?? const [])
            .map(
              (item) => MediaAttachment.fromMap(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'author': author,
        'roleLabel': roleLabel,
        'eventTitle': eventTitle,
        'text': text,
        'createdAt': createdAt,
        'likes': likes,
        'commentsCount': commentsCount,
        'sharesCount': sharesCount,
        'likedByMe': likedByMe,
        'savedByMe': savedByMe,
        'media': media.map((item) => item.toMap()).toList(),
      };

  TimelinePost copyWith({
    int? likes,
    int? commentsCount,
    int? sharesCount,
    bool? likedByMe,
    bool? savedByMe,
    List<MediaAttachment>? media,
  }) =>
      TimelinePost(
        id: id,
        authorId: authorId,
        author: author,
        roleLabel: roleLabel,
        eventTitle: eventTitle,
        text: text,
        createdAt: createdAt,
        likes: likes ?? this.likes,
        commentsCount: commentsCount ?? this.commentsCount,
        sharesCount: sharesCount ?? this.sharesCount,
        likedByMe: likedByMe ?? this.likedByMe,
        savedByMe: savedByMe ?? this.savedByMe,
        media: media ?? this.media,
      );
}
