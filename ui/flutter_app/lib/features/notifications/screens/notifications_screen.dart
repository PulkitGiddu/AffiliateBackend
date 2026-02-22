import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/notification_model.dart';
import '../../../widgets/empty_state.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text('Notifications'),
      ),
      body: notificationsAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              message: 'No notifications yet.',
              icon: Icons.notifications_none_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationListProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (_, i) => _NotificationTile(notification: list[i]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          message: e.toString(),
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.isRead
          ? null
          : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: ListTile(
        leading: Icon(
          notification.isRead ? Icons.notifications_none : Icons.notifications,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          notification.message ?? 'Notification',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: notification.createdAt != null
            ? Text(
                notification.createdAt!.toIso8601String().substring(0, 16),
                style: Theme.of(context).textTheme.labelSmall,
              )
            : null,
      ),
    );
  }
}
