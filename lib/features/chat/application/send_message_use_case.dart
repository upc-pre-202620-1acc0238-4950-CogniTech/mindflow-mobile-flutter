import '../domain/chat_message.dart';
import '../domain/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;
  SendMessageUseCase({required this.repository});

  Future<(ChatMessage, ChatMessage)> execute({required int conversationId, required String content}) =>
      repository.sendMessage(conversationId: conversationId, content: content);
}
