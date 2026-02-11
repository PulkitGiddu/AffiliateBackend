import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_providers.dart';
import '../../../models/price_history_entry.dart';
import '../../../models/product.dart';

final productSearchQueryProvider = StateProvider<String>((ref) => '');
final productCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// Mutable list with pagination: refresh and loadMore.
class ProductListState {
  const ProductListState({
    this.items = const [],
    this.loading = false,
    this.loadingMore = false,
    this.hasNext = true,
    this.page = 0,
  });
  final List<Product> items;
  final bool loading;
  final bool loadingMore;
  final bool hasNext;
  final int page;
}

class ProductListNotifier extends StateNotifier<ProductListState> {
  ProductListNotifier(this._ref) : super(const ProductListState()) {
    load();
  }
  final Ref _ref;

  Future<void> load() async {
    state = const ProductListState(loading: true, page: 0);
    final repo = _ref.read(productRepositoryProvider);
    final keyword = _ref.read(productSearchQueryProvider);
    final categoryId = _ref.read(productCategoryFilterProvider);
    final res = await repo.search(
      keyword: keyword.isEmpty ? null : keyword,
      categoryId: categoryId,
      page: 0,
      size: 20,
      active: true,
    );
    state = ProductListState(
      items: res.items,
      hasNext: res.hasNext,
      page: 0,
      loading: false,
    );
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasNext) return;
    state = ProductListState(
      items: state.items,
      loadingMore: true,
      hasNext: state.hasNext,
      page: state.page,
    );
    final repo = _ref.read(productRepositoryProvider);
    final keyword = _ref.read(productSearchQueryProvider);
    final categoryId = _ref.read(productCategoryFilterProvider);
    final res = await repo.search(
      keyword: keyword.isEmpty ? null : keyword,
      categoryId: categoryId,
      page: state.page + 1,
      size: 20,
      active: true,
    );
    state = ProductListState(
      items: [...state.items, ...res.items],
      hasNext: res.hasNext,
      page: state.page + 1,
      loadingMore: false,
    );
  }
}

final productListNotifierProvider =
    StateNotifierProvider.autoDispose<ProductListNotifier, ProductListState>((ref) {
  return ProductListNotifier(ref);
});

/// First page of products for home "Top Deals".
final topDealsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final res = await repo.search(
    keyword: null,
    categoryId: null,
    page: 0,
    size: 10,
    active: true,
  );
  return res.items;
});

final productDetailProvider =
    FutureProvider.autoDispose.family<Product, String>((ref, id) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getById(id);
});

final productPriceHistoryProvider =
    FutureProvider.autoDispose.family<List<PriceHistoryEntry>, String>((ref, productId) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getPriceHistory(productId);
});
