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
  bool _mounted = true;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> load() async {
    final userId = _ref.read(authStateProvider).valueOrNull?.userId;
    if (userId == null) {
      if (_mounted) state = const AsyncValue.data([]);
      return;
    }
    if (!_mounted) return;
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      return _ref.read(wishlistRepositoryProvider).getByUser(userId);
    });
    if (_mounted) state = result;
  }

  Future<void> add({required String productId}) async {
    final userId = _ref.read(authStateProvider).valueOrNull?.userId;
    if (userId == null || !_mounted) return;
    await _ref.read(wishlistRepositoryProvider).add(userId: userId, productId: productId);
    if (_mounted) load();
  }

  Future<void> remove({required String productId}) async {
    final userId = _ref.read(authStateProvider).valueOrNull?.userId;
    if (userId == null || !_mounted) return;
    await _ref.read(wishlistRepositoryProvider).remove(userId: userId, productId: productId);
    if (_mounted) load();
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
