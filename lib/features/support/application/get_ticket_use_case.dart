import '../domain/support_ticket.dart';
import '../infrastructure/support_api.dart';

class GetTicketUseCase {
  final SupportApi api;
  GetTicketUseCase({required this.api});

  Future<SupportTicket> execute(int id) => api.getTicket(id);
}
