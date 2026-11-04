import '../infrastructure/notifications_api.dart';

class MarkNotificationReadUseCase {
  final NotificationsApi api;
  MarkNotificationReadUseCase({required this.api});

  Future<void> execute(int id) => api.markRead(id);
}
