import '../domain/support_ticket.dart';
import '../infrastructure/support_api.dart';

class GetTicketsUseCase {
  final SupportApi api;
  GetTicketsUseCase({required this.api});

  Future<List<SupportTicket>> execute() => api.getTickets();
}
