import 'package:flutter/material.dart';

import '../application/create_ticket_use_case.dart';
import '../application/get_tickets_use_case.dart';
import '../domain/support_ticket.dart';

class SupportViewModel extends ChangeNotifier {
  final GetTicketsUseCase getTickets;
  final CreateTicketUseCase createTicket;

  SupportViewModel({required this.getTickets, required this.createTicket}) {
    refresh();
  }

  bool isLoading = true;
  bool isSending = false;
  String? errorMessage;
  List<SupportTicket> tickets = [];
  SupportTicket? lastCreated;

  Future<void> refresh() async {
    isLoading = true;
    notifyListeners();
    try {
      tickets = await getTickets.execute();
      errorMessage = null;
    } catch (_) {
      errorMessage = 'No se pudieron cargar tus tickets.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendTicket(String description) async {
    if (description.trim().isEmpty) return false;
    isSending = true;
    errorMessage = null;
    notifyListeners();
    try {
      final subject = description.trim().length <= 60
          ? description.trim()
          : '${description.trim().substring(0, 60)}...';
      lastCreated = await createTicket.execute(subject: subject, message: description);
      await refresh();
      return true;
    } catch (_) {
      errorMessage = 'No se pudo enviar tu ticket. Intenta de nuevo.';
      return false;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }
}
