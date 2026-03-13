import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/notification_model.dart';
import '../../../widgets/empty_state.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _selectedFilter = 0; // 0 = All, 1 = Offers

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationListProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: "Notifications(N)" + back button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  notificationsAsync.when(
                    data: (list) => Text(
                      'Notifications(${list.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                    ),
                    loading: () => Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                    ),
                    error: (_, __) => Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Filter chips: All | Offers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: _selectedFilter == 0,
                    onTap: () => setState(() => _selectedFilter = 0),
                    scheme: scheme,
                  ),
                  const SizedBox(width: 10),
                  _FilterChip(
                    label: 'Offers',
                    icon: Icons.local_offer_outlined,
                    isSelected: _selectedFilter == 1,
                    onTap: () => setState(() => _selectedFilter = 1),
                    scheme: scheme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Notification list
            Expanded(
              child: notificationsAsync.when(
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
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: scheme.outlineVariant.withOpacity(0.4),
                      ),
                      itemBuilder: (_, i) => _NotificationCard(notification: list[i]),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => EmptyState(
                  message: e.toString(),
                  icon: Icons.error_outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
    required this.scheme,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? scheme.primary : scheme.outline,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final timeAgo = _formatTimeAgo(notification.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blue dot for unread
          if (!notification.isRead)
            Container(
              margin: const EdgeInsets.only(top: 6, right: 8),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message ?? 'Notification',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
                        color: scheme.onSurface,
                        height: 1.4,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (timeAgo.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    timeAgo,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Thumbnail
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'lib/asserts/iconPack/icons8-notification-50.png',
                width: 36,
                height: 36,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.notifications_rounded,
                  color: scheme.primary,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} min ago';
    }
    return 'Just now';
  }
}
