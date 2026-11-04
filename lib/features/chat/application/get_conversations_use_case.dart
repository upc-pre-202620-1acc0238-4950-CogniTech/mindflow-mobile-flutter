import '../domain/chat_repository.dart';
import '../domain/conversation.dart';

class GetConversationsUseCase {
  final ChatRepository repository;
  GetConversationsUseCase({required this.repository});

  Future<List<Conversation>> execute() => repository.getConversations();
}
