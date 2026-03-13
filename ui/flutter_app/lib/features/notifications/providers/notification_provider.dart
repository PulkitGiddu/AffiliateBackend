import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_providers.dart';
import '../../../models/notification_model.dart';
import '../../auth/providers/auth_provider.dart';

final notificationListProvider =
    FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  final userId = ref.watch(authStateProvider).valueOrNull?.userId;
  try {
    if (userId != null && userId.isNotEmpty) {
      final list = await ref.watch(notificationRepositoryProvider).getByUser(userId);
      if (list.isNotEmpty) return list;
    }
  } catch (_) {}
  return _defaultNotifications;
});

final List<NotificationModel> _defaultNotifications = [
  NotificationModel(
    id: 'n1',
    message: 'Flash Sale is LIVE! Up to 80% off on electronics. Shop now before it ends!',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
  ),
  NotificationModel(
    id: 'n2',
    message: 'Your wishlist item "Samsung Galaxy S25" price dropped by 20%! Grab it now.',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  NotificationModel(
    id: 'n3',
    message: 'New coupon unlocked! Use SNATCH500 to get ₹500 off on orders above ₹2,999.',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  NotificationModel(
    id: 'n4',
    message: 'Myntra End of Season Sale starts tomorrow. Set a reminder so you don\'t miss out!',
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
  ),
  NotificationModel(
    id: 'n5',
    message: 'Your order #SM-29481 has been shipped! Track it from your dashboard.',
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  NotificationModel(
    id: 'n6',
    message: 'Earn 2x commission this weekend on all fashion affiliate links!',
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
  ),
  NotificationModel(
    id: 'n7',
    message: 'Apple iPhone 17 Pro is now available. Create your affiliate link and start earning!',
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  NotificationModel(
    id: 'n8',
    message: 'Weekly report ready: You earned ₹1,250 last week. View detailed analytics.',
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];
