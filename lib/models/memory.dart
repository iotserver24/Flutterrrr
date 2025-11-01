class Memory {
  final int? id;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Memory({
    this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Memory.fromMap(Map<String, dynamic> map) {
    return Memory(
      id: map['id'] as int?,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Memory copyWith({
    int? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Memory(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
