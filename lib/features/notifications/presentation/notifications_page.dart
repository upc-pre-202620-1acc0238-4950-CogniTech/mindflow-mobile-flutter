import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/app_notification.dart';
import 'notifications_view_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<NotificationsViewModel>();
    _viewModel.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              if (_viewModel.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: _viewModel.markEverythingRead,
                child: const Text('Marcar todas leídas'),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_viewModel.errorMessage != null && _viewModel.notifications.isEmpty) {
              return Center(
                  child: Text(_viewModel.errorMessage!, style: TextStyle(color: colors.crisisText)));
            }
            if (_viewModel.notifications.isEmpty) {
              return Center(
                  child: Text('Aún no hay notificaciones.', style: TextStyle(color: colors.textSecondary)));
            }
            return RefreshIndicator(
              onRefresh: _viewModel.loadAll,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _viewModel.notifications.length,
                separatorBuilder: (_, index) => Divider(height: 1, color: colors.border),
                itemBuilder: (context, i) => _NotificationRow(
                  notification: _viewModel.notifications[i],
                  onTap: () => _viewModel.openNotification(_viewModel.notifications[i]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  const _NotificationRow({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 10),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: notification.isRead ? Colors.transparent : colors.primary,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(notification.body, style: TextStyle(fontSize: 14, color: colors.textSecondary)),
                  if (notification.createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(DateFormat('d MMM · HH:mm').format(notification.createdAt!),
                        style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
