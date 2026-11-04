import '../../../core/network/api_client.dart';
import '../domain/support_ticket.dart';

class SupportApi {
  final ApiClient client;
  SupportApi({required this.client});

  Future<List<SupportTicket>> getTickets() async {
    final json = await client.get('/support/tickets');
    return (json as List).map((e) => SupportTicket.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SupportTicket> getTicket(int id) async {
    final json = await client.get('/support/tickets/$id');
    return SupportTicket.fromJson(json as Map<String, dynamic>);
  }

  Future<SupportTicket> createTicket({required String subject, String? message}) async {
    final json = await client.post('/support/tickets', body: {
      'subject': subject,
      'category': 'general',
      if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
    });
    return SupportTicket.fromJson(json as Map<String, dynamic>);
  }

  Future<void> sendMessage({required int ticketId, required String message}) =>
      client.post('/support/tickets/$ticketId/messages', body: {'message': message});
}
