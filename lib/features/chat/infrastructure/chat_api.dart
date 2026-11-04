import '../../../core/network/api_client.dart';
import '../domain/chat_message.dart';
import '../domain/conversation.dart';
import '../domain/conversation_detail.dart';

class ChatApi {
  final ApiClient client;
  ChatApi({required this.client});

  Future<List<Conversation>> getConversations() async {
    final json = await client.get('/chat/conversations');
    return (json as List).map((e) => Conversation.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ConversationDetail> createConversation({required String content, String? category}) async {
    final json = await client.post('/chat/conversations', body: {
      'content': content,
      if (category != null) 'category': category,
    });
    return ConversationDetail.fromJson(json as Map<String, dynamic>);
  }

  Future<ConversationDetail> getMessages(int conversationId) async {
    final json = await client.get('/chat/conversations/$conversationId/messages');
    return ConversationDetail.fromJson(json as Map<String, dynamic>);
  }

  Future<(ChatMessage, ChatMessage)> sendMessage({
    required int conversationId,
    required String content,
  }) async {
    final json = await client
        .post('/chat/conversations/$conversationId/messages', body: {'content': content}) as Map<String, dynamic>;
    final userMessage = ChatMessage.fromJson(json['user_message'] as Map<String, dynamic>);
    final aiMessage = ChatMessage.fromJson(json['ai_message'] as Map<String, dynamic>);
    return (userMessage, aiMessage);
  }

  Future<void> deleteConversation(int id) => client.delete('/chat/conversations/$id');
}
