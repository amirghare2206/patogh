import 'package:patogh/models/media_attachment.dart';

class ChatMessage {
  final String id;
  final String? userId;
  final String text;
  final bool mine;
  final String time;
  final List<MediaAttachment> media;
  const ChatMessage({
    this.id = '',
    this.userId,
    required this.text,
    required this.mine,
    required this.time,
    this.media = const [],
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'text': text,
    'mine': mine,
    'time': time,
  };
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: (json['id'] as String?) ?? '',
    userId: json['userId'] as String?,
    text: (json['text'] as String?) ?? '',
    mine: (json['mine'] as bool?) ?? false,
    time: (json['time'] as String?) ?? '',
  );
}
