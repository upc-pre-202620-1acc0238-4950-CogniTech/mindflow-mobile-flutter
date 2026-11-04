import 'chat_message.dart';

class ConversationDetail {
  final int id;
  final String title;
  final String category;
  final List<ChatMessage> messages;

  const ConversationDetail({
    required this.id,
    required this.title,
    required this.category,
    required this.messages,
  });

  factory ConversationDetail.fromJson(Map<String, dynamic> json) => ConversationDetail(
        id: json['id'] as int,
        title: (json['title'] as String?) ?? '',
        category: (json['category'] as String?) ?? '',
        messages: ((json['messages'] as List?) ?? [])
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
