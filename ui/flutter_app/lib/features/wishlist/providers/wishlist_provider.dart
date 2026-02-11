import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_providers.dart';
import '../../../models/product.dart';
import '../../../models/wishlist_item.dart';
import '../../auth/providers/auth_provider.dart';

final wishlistNotifierProvider =
    StateNotifierProvider.autoDispose<WishlistNotifier, AsyncValue<List<WishlistItem>>>((ref) {
  return WishlistNotifier(ref);
});

class WishlistNotifier extends StateNotifier<AsyncValue<List<WishlistItem>>> {
  WishlistNotifier(this._ref) : super(const AsyncValue.data([])) {
    load();
  }
  final Ref _ref;

  Future<void> load() async {
    final userId = _ref.read(authStateProvider).valueOrNull?.userId;
    if (userId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _ref.read(wishlistRepositoryProvider).getByUser(userId);
    });
  }

  Future<void> add({required String productId}) async {
    final userId = _ref.read(authStateProvider).valueOrNull?.userId;
    if (userId == null) return;
    await _ref.read(wishlistRepositoryProvider).add(userId: userId, productId: productId);
    load();
  }

  Future<void> remove({required String productId}) async {
    final userId = _ref.read(authStateProvider).valueOrNull?.userId;
    if (userId == null) return;
    await _ref.read(wishlistRepositoryProvider).remove(userId: userId, productId: productId);
    load();
  }
}

/// Resolve product details for wishlist product IDs.
final wishlistProductsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final items = ref.watch(wishlistNotifierProvider).valueOrNull ?? [];
  if (items.isEmpty) return [];
  final repo = ref.watch(productRepositoryProvider);
  final products = <Product>[];
  for (final item in items) {
    try {
      products.add(await repo.getById(item.productId));
    } catch (_) {}
  }
  return products;
});
