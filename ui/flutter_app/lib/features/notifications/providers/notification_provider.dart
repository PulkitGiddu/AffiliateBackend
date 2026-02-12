import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_providers.dart';
import '../../../models/notification_model.dart';
import '../../auth/providers/auth_provider.dart';

/// Dummy notifications for demo when API returns empty or fails.
List<NotificationModel> get _dummyNotifications {
  final now = DateTime.now();
  return [
    NotificationModel(
      id: 'dummy-1',
      userId: null,
      message: 'Flash sale starts in 1 hour! Get up to 50% off on electronics.',
      isRead: false,
      createdAt: now.subtract(const Duration(minutes: 15)),
    ),
    NotificationModel(
      id: 'dummy-2',
      userId: null,
      message: 'Your order #SNM1234 has been shipped. Track your delivery.',
      isRead: false,
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: 'dummy-3',
      userId: null,
      message: 'Price drop alert: Item in your wishlist is now 20% cheaper.',
      isRead: true,
      createdAt: now.subtract(const Duration(hours: 5)),
    ),
    NotificationModel(
      id: 'dummy-4',
      userId: null,
      message: 'Welcome to SnatchMart! Complete your profile to get personalized deals.',
      isRead: true,
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    NotificationModel(
      id: 'dummy-5',
      userId: null,
      message: 'New category added: Smart Gadgets. Explore the latest wearables.',
      isRead: true,
      createdAt: now.subtract(const Duration(days: 2)),
    ),
  ];
}

final notificationListProvider =
    FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  final userId = ref.watch(authStateProvider).valueOrNull?.userId;
  if (userId == null) return [];
  try {
    final list = await ref.watch(notificationRepositoryProvider).getByUser(userId);
    // If API returns empty, show dummy data for demo
    if (list.isEmpty) return _dummyNotifications;
    return list;
  } catch (_) {
    return _dummyNotifications;
  }
});
