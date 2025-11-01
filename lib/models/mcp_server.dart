class McpServer {
  final int? id;
  final String name;
  final String url;
  final String? apiKey;
  final String description;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  McpServer({
    this.id,
    required this.name,
    required this.url,
    this.apiKey,
    required this.description,
    this.isEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'apiKey': apiKey,
      'description': description,
      'isEnabled': isEnabled ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory McpServer.fromMap(Map<String, dynamic> map) {
    return McpServer(
      id: map['id'],
      name: map['name'],
      url: map['url'],
      apiKey: map['apiKey'],
      description: map['description'],
      isEnabled: map['isEnabled'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  McpServer copyWith({
    int? id,
    String? name,
    String? url,
    String? apiKey,
    String? description,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return McpServer(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      apiKey: apiKey ?? this.apiKey,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
