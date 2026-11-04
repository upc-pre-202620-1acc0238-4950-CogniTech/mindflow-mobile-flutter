import '../domain/chat_repository.dart';
import '../domain/conversation_detail.dart';

class GetConversationMessagesUseCase {
  final ChatRepository repository;
  GetConversationMessagesUseCase({required this.repository});

  Future<ConversationDetail> execute(int conversationId) => repository.getMessages(conversationId);
}
