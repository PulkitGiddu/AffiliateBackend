import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_providers.dart';
import '../../../models/notification_model.dart';
import '../../auth/providers/auth_provider.dart';

final notificationListProvider =
    FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  final userId = ref.watch(authStateProvider).valueOrNull?.userId;
  if (userId == null) return [];
  return ref.watch(notificationRepositoryProvider).getByUser(userId);
});
