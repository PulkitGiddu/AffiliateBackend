import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_providers.dart';
import '../../../core/mock/mock_data_loader.dart';
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
    if (useMockWhenOffline) {
      final mock = await getMockNotifications();
      if (mock.isNotEmpty) return mock;
    }
    return [];
  } catch (_) {
    if (useMockWhenOffline) {
      final mock = await getMockNotifications();
      if (mock.isNotEmpty) return mock;
    }
    return [];
  }
});
