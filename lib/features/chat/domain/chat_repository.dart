import 'chat_message.dart';
import 'conversation.dart';
import 'conversation_detail.dart';

abstract class ChatRepository {
  Future<List<Conversation>> getConversations();

  Future<ConversationDetail> createConversation({required String content, String? category});

  Future<ConversationDetail> getMessages(int conversationId);

  /// Returns the pair of messages the backend just created (the user's
  /// message and the AI's reply).
  Future<(ChatMessage, ChatMessage)> sendMessage({required int conversationId, required String content});

  Future<void> deleteConversation(int id);
}
