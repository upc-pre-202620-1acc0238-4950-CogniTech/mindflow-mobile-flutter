import '../../../core/network/api_client.dart';
import '../domain/app_notification.dart';

class NotificationsApi {
  final ApiClient client;
  NotificationsApi({required this.client});

  Future<List<AppNotification>> getAll() async {
    final json = await client.get('/notifications');
    return (json as List).map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<int> getUnreadCount() async {
    final json = await client.get('/notifications/unread-count') as Map<String, dynamic>;
    return (json['count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markRead(int id) => client.post('/notifications/$id/read');

  Future<void> markAllRead() => client.post('/notifications/read-all');
}
