import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../services/local_storage_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/coupon_repository.dart';
import '../repositories/wishlist_repository.dart';
import '../repositories/budget_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/affiliate_click_repository.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) throw StateError('SharedPreferences not ready');
  return LocalStorageService(prefs);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return ApiClient.getInstance(
    getToken: () => storage.token,
    onTokenInvalid: () {}, // 401 handled per-request; UI can redirect to login
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(localStorageServiceProvider),
  );
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(apiClientProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(apiClientProvider));
});

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  return CouponRepository(ref.watch(apiClientProvider));
});

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository(ref.watch(apiClientProvider));
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.watch(apiClientProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(apiClientProvider));
});

final affiliateClickRepositoryProvider = Provider<AffiliateClickRepository>((ref) {
  return AffiliateClickRepository(ref.watch(apiClientProvider));
});
