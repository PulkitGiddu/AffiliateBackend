import 'package:flutter/material.dart';
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
import '../repositories/user_repository.dart';
import '../models/user.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) throw StateError('SharedPreferences not ready');
  return LocalStorageService(prefs);
});

/// True if user chose "Skip" on login. Only read after SharedPreferences is ready.
final skippedLoginProvider = Provider<bool>((ref) {
  return ref.watch(localStorageServiceProvider).hasSkippedLogin;
});

/// Theme mode (system / light / dark). Persisted; only valid after prefs ready.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return ThemeModeNotifier(storage);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._storage) : super(_fromString(_storage.themeMode));
  final LocalStorageService _storage;

  Future<void> setMode(ThemeMode mode) async {
    await _storage.setThemeMode(_themeModeToString(mode));
    state = mode;
  }

  static ThemeMode _fromString(String v) {
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}

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

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(apiClientProvider));
});

/// Fetches current user profile from backend (GET /api/v1/{userId}). Triggers when Profile is opened.
final userProfileProvider = FutureProvider.autoDispose.family<User?, String>((ref, userId) async {
  if (userId.isEmpty) return null;
  final repo = ref.watch(userRepositoryProvider);
  return repo.getById(userId);
});
