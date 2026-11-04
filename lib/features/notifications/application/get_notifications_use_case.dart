import '../domain/app_notification.dart';
import '../infrastructure/notifications_api.dart';

class GetNotificationsUseCase {
  final NotificationsApi api;
  GetNotificationsUseCase({required this.api});

  Future<List<AppNotification>> execute() => api.getAll();
}
