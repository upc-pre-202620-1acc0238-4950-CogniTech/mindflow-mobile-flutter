class Conversation {
  final int id;
  final String title;
  final String category;
  final int messageCount;
  final String? lastMessage;
  final DateTime? updatedAt;

  const Conversation({
    required this.id,
    required this.title,
    required this.category,
    required this.messageCount,
    this.lastMessage,
    this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] as int,
        title: (json['title'] as String?) ?? '',
        category: (json['category'] as String?) ?? '',
        messageCount: (json['message_count'] as num?)?.toInt() ?? 0,
        lastMessage: json['last_message'] as String?,
        updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
      );
}
