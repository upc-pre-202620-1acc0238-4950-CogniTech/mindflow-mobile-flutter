import '../domain/chat_repository.dart';
import '../domain/conversation_detail.dart';

class StartConversationUseCase {
  final ChatRepository repository;
  StartConversationUseCase({required this.repository});

  Future<ConversationDetail> execute({required String content, String? category}) =>
      repository.createConversation(content: content, category: category);
}
