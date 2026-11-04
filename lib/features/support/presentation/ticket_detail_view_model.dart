import 'package:flutter/material.dart';

import '../application/get_ticket_use_case.dart';
import '../application/send_ticket_message_use_case.dart';
import '../domain/support_ticket.dart';

class TicketDetailViewModel extends ChangeNotifier {
  final GetTicketUseCase getTicket;
  final SendTicketMessageUseCase sendMessage;

  TicketDetailViewModel({required this.getTicket, required this.sendMessage});

  bool isLoading = true;
  bool isSending = false;
  String? errorMessage;
  SupportTicket? ticket;

  Future<void> load(int id) async {
    isLoading = true;
    notifyListeners();
    try {
      ticket = await getTicket.execute(id);
      errorMessage = null;
    } catch (_) {
      errorMessage = 'Could not load this ticket.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reply(String message) async {
    if (ticket == null || message.trim().isEmpty) return;
    isSending = true;
    notifyListeners();
    try {
      await sendMessage.execute(ticketId: ticket!.id, message: message.trim());
      ticket = await getTicket.execute(ticket!.id);
    } catch (_) {
      errorMessage = 'Could not send your reply.';
    } finally {
      isSending = false;
      notifyListeners();
    }
  }
}
