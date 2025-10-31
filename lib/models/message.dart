class Message {
  final int? id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final bool webSearchUsed;
  final int chatId;

  Message({
    this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.webSearchUsed = false,
    required this.chatId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'webSearchUsed': webSearchUsed ? 1 : 0,
      'chatId': chatId,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      role: map['role'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
      webSearchUsed: map['webSearchUsed'] == 1,
      chatId: map['chatId'],
    );
  }

  Map<String, dynamic> toApiFormat() {
    return {
      'role': role,
      'content': content,
    };
  }
}
