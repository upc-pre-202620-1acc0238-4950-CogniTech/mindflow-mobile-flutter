import '../infrastructure/notifications_api.dart';

class GetUnreadCountUseCase {
  final NotificationsApi api;
  GetUnreadCountUseCase({required this.api});

  Future<int> execute() => api.getUnreadCount();
}
