import 'package:flutter/material.dart';

import '../application/get_notifications_use_case.dart';
import '../application/get_unread_count_use_case.dart';
import '../application/mark_all_notifications_read_use_case.dart';
import '../application/mark_notification_read_use_case.dart';
import '../domain/app_notification.dart';

class NotificationsViewModel extends ChangeNotifier {
  final GetNotificationsUseCase getNotifications;
  final GetUnreadCountUseCase getUnreadCount;
  final MarkNotificationReadUseCase markRead;
  final MarkAllNotificationsReadUseCase markAllRead;

  NotificationsViewModel({
    required this.getNotifications,
    required this.getUnreadCount,
    required this.markRead,
    required this.markAllRead,
  }) {
    refreshUnreadCount();
  }

  bool isLoading = true;
  String? errorMessage;
  List<AppNotification> notifications = [];
  int unreadCount = 0;

  Future<void> refreshUnreadCount() async {
    try {
      unreadCount = await getUnreadCount.execute();
      notifyListeners();
    } catch (_) {
      // Non-critical; the badge just stays at its last known value.
    }
  }

  Future<void> loadAll() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      notifications = await getNotifications.execute();
      await refreshUnreadCount();
    } catch (_) {
      errorMessage = 'Could not load your notifications.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openNotification(AppNotification notification) async {
    if (notification.isRead) return;
    try {
      await markRead.execute(notification.id);
      await loadAll();
    } catch (_) {
      // Keep showing it as unread if the call failed.
    }
  }

  Future<void> markEverythingRead() async {
    try {
      await markAllRead.execute();
      await loadAll();
    } catch (_) {
      errorMessage = 'Could not mark all as read.';
      notifyListeners();
    }
  }
}
