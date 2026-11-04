import '../infrastructure/notifications_api.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationsApi api;
  MarkAllNotificationsReadUseCase({required this.api});

  Future<void> execute() => api.markAllRead();
}
