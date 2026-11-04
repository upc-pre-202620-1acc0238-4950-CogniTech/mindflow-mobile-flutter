import '../domain/support_ticket.dart';
import '../infrastructure/support_api.dart';

class CreateTicketUseCase {
  final SupportApi api;
  CreateTicketUseCase({required this.api});

  Future<SupportTicket> execute({required String subject, String? message}) =>
      api.createTicket(subject: subject, message: message);
}
