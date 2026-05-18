class ChatMessage {
  final int id;
  final String sender; // 'user' or 'ai'
  final String message;
  final DateTime timestamp;
  final String? modelUsed;
  final int? responseTimeMs;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.message,
    required this.timestamp,
    this.modelUsed,
    this.responseTimeMs,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      sender: json['sender'] ?? 'user',
      message: json['message'] ?? '',
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      modelUsed: json['model_used'],
      responseTimeMs: json['response_time_ms'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'model_used': modelUsed,
      'response_time_ms': responseTimeMs,
    };
  }
}

class ChatSession {
  final String id;
  final int userId;
  final String title;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int messageCount;

  ChatSession({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    this.updatedAt,
    required this.messageCount,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? 'Untitled',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      messageCount: json['message_count'] ?? 0,
    );
  }
}

class LLMModel {
  final String name;
  final String provider;
  final String? size;
  final String? modifiedAt;

  LLMModel({
    required this.name,
    required this.provider,
    this.size,
    this.modifiedAt,
  });

  factory LLMModel.fromJson(Map<String, dynamic> json) {
    return LLMModel(
      name: json['name'] ?? '',
      provider: json['provider'] ?? 'Unknown',
      size: json['size'],
      modifiedAt: json['modified_at'] ?? json['modified'],
    );
  }
}
