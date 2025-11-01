class Message {
  final int? id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final bool webSearchUsed;
  final int chatId;
  final String? imageBase64; // Base64 encoded image data for vision models
  final String? imagePath; // Local file path for displaying image
  final String? thinkingContent; // Content of AI thinking process
  final bool isThinking; // Whether AI is in thinking mode

  Message({
    this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.webSearchUsed = false,
    required this.chatId,
    this.imageBase64,
    this.imagePath,
    this.thinkingContent,
    this.isThinking = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'webSearchUsed': webSearchUsed ? 1 : 0,
      'chatId': chatId,
      'imageBase64': imageBase64,
      'imagePath': imagePath,
      'thinkingContent': thinkingContent,
      'isThinking': isThinking ? 1 : 0,
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
      imageBase64: map['imageBase64'],
      imagePath: map['imagePath'],
      thinkingContent: map['thinkingContent'],
      isThinking: map['isThinking'] != null && map['isThinking'] == 1,
    );
  }

  Map<String, dynamic> toApiFormat() {
    // For messages with images (vision models), use OpenAI's format
    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      return {
        'role': role,
        'content': [
          {
            'type': 'text',
            'text': content,
          },
          {
            'type': 'image_url',
            'image_url': {
              'url': 'data:image/jpeg;base64,$imageBase64',
            },
          },
        ],
      };
    }
    
    // Standard text-only message
    return {
      'role': role,
      'content': content,
    };
  }
}
