class ChatMessage {
  final int id;
  final String role;
  final String content;
  final DateTime? createdAt;

  const ChatMessage({required this.id, required this.role, required this.content, this.createdAt});

  bool get isUser => role == 'user';

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as int,
        role: (json['role'] as String?) ?? 'assistant',
        content: (json['content'] as String?) ?? '',
        createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
      );
}
