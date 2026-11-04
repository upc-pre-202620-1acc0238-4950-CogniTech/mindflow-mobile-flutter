import '../infrastructure/support_api.dart';

class SendTicketMessageUseCase {
  final SupportApi api;
  SendTicketMessageUseCase({required this.api});

  Future<void> execute({required int ticketId, required String message}) =>
      api.sendMessage(ticketId: ticketId, message: message);
}
