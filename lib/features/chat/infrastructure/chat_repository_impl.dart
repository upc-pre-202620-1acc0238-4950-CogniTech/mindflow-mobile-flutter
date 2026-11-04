import '../domain/chat_message.dart';
import '../domain/chat_repository.dart';
import '../domain/conversation.dart';
import '../domain/conversation_detail.dart';
import 'chat_api.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatApi api;
  ChatRepositoryImpl({required this.api});

  @override
  Future<List<Conversation>> getConversations() => api.getConversations();

  @override
  Future<ConversationDetail> createConversation({required String content, String? category}) =>
      api.createConversation(content: content, category: category);

  @override
  Future<ConversationDetail> getMessages(int conversationId) => api.getMessages(conversationId);

  @override
  Future<(ChatMessage, ChatMessage)> sendMessage({required int conversationId, required String content}) =>
      api.sendMessage(conversationId: conversationId, content: content);

  @override
  Future<void> deleteConversation(int id) => api.deleteConversation(id);
}
