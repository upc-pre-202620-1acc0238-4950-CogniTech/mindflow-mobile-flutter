import 'package:flutter/material.dart';

import '../application/get_conversation_messages_use_case.dart';
import '../application/get_conversations_use_case.dart';
import '../application/send_message_use_case.dart';
import '../application/start_conversation_use_case.dart';
import '../domain/chat_message.dart';

class ChatViewModel extends ChangeNotifier {
  final GetConversationsUseCase getConversations;
  final GetConversationMessagesUseCase getMessages;
  final StartConversationUseCase startConversation;
  final SendMessageUseCase sendMessage;

  ChatViewModel({
    required this.getConversations,
    required this.getMessages,
    required this.startConversation,
    required this.sendMessage,
  }) {
    _load();
  }

  bool isLoading = true;
  bool isSending = false;
  String? errorMessage;
  int? conversationId;
  List<ChatMessage> messages = [];

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();
    try {
      final conversations = await getConversations.execute();
      if (conversations.isNotEmpty) {
        // Most recent first, per the backend's ordering by updated_at desc.
        final detail = await getMessages.execute(conversations.first.id);
        conversationId = detail.id;
        messages = detail.messages;
      }
    } catch (_) {
      errorMessage = 'No se pudo cargar tu conversación.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> send(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty || isSending) return;

    errorMessage = null;
    isSending = true;
    // Optimistic bubble so the message appears instantly.
    final optimistic = ChatMessage(id: -DateTime.now().millisecondsSinceEpoch, role: 'user', content: trimmed);
    messages = [...messages, optimistic];
    notifyListeners();

    try {
      if (conversationId == null) {
        final detail = await startConversation.execute(content: trimmed);
        conversationId = detail.id;
        messages = detail.messages;
      } else {
        final (userMessage, aiMessage) =
            await sendMessage.execute(conversationId: conversationId!, content: trimmed);
        messages = [...messages.where((m) => m.id != optimistic.id), userMessage, aiMessage];
      }
    } catch (_) {
      messages = messages.where((m) => m.id != optimistic.id).toList();
      errorMessage = 'No se pudo enviar el mensaje. Intenta de nuevo.';
    } finally {
      isSending = false;
      notifyListeners();
    }
  }
}
