class ChatMessage {
  final String text;
  final bool mine;
  final String time;

  const ChatMessage({
    required this.text,
    required this.mine,
    required this.time,
  });

  Map<String, dynamic> toJson() => {'text': text, 'mine': mine, 'time': time};

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: (json['text'] as String?) ?? '',
      mine: (json['mine'] as bool?) ?? false,
      time: (json['time'] as String?) ?? '',
    );
  }
}
