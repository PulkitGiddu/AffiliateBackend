import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/product.dart';
import '../../../models/category.dart';
import '../providers/product_provider.dart';
import '../../home/providers/category_provider.dart';
import '../../../widgets/shimmer_loading.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/category_circle.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  static const double _leftColumnWidth = 100;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final pos = _scrollController.position;
      if (pos.pixels >= pos.maxScrollExtent - 200) {
        ref.read(productListNotifierProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String? categoryId) {
    ref.read(productCategoryFilterProvider.notifier).state = categoryId;
    ref.read(productListNotifierProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(productListNotifierProvider);
    final selectedCategoryId = ref.watch(productCategoryFilterProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text('All Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: () {},
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {},
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: const Center(
                    child: Text(
                      '5',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: categories (~1/3 width)
          Container(
            width: _leftColumnWidth,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
            ),
            child: categoriesAsync.when(
              data: (categories) => ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _CategorySideItem(
                    label: 'For You',
                    meta: categoryMetaFor('All', 'all'),
                    isSelected: selectedCategoryId == null,
                    onTap: () => _onCategorySelected(null),
                  ),
                  ...categories.map((c) => _CategorySideItem(
                        label: c.name,
                        meta: categoryMetaFor(c.name, c.slug),
                        isSelected: selectedCategoryId == c.id,
                        onTap: () => _onCategorySelected(c.id),
                      )),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Icon(Icons.error_outline)),
            ),
          ),
          // Right: content (products)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: listState.loading && listState.items.isEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: 8,
                          itemBuilder: (_, __) => const _ProductTileShimmer(),
                        )
                      : listState.items.isEmpty
                          ? const EmptyState(
                              message: 'No products in this category.',
                              icon: Icons.inventory_2_outlined,
                            )
                          : RefreshIndicator(
                              onRefresh: () =>
                                  ref.read(productListNotifierProvider.notifier).load(),
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
                                itemCount: listState.items.length +
                                    (listState.loadingMore ? 1 : 0),
                                itemBuilder: (_, i) {
                                  if (i == listState.items.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }
                                  return _ProductTile(product: listState.items[i]);
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    ref.read(productSearchQueryProvider.notifier).state = _searchController.text;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
            onSubmitted: (v) {
              ref.read(productSearchQueryProvider.notifier).state = v;
              ref.read(productListNotifierProvider.notifier).load();
              Navigator.of(ctx).pop();
            },
          ),
        ),
      ),
    );
  }
}

class _CategorySideItem extends StatelessWidget {
  const _CategorySideItem({
    required this.label,
    required this.meta,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final CategoryMeta meta;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final circleBg = isDark ? meta.iconColor.withOpacity(0.18) : meta.bgColor;
    final circleFg = isDark ? meta.iconColor.withOpacity(0.9) : meta.iconColor;
    final textColor = isSelected ? scheme.primary : scheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Material(
        color: isSelected
            ? scheme.primaryContainer.withOpacity(isDark ? 0.2 : 0.4)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleBg,
                    border: isSelected
                        ? Border.all(color: scheme.primary, width: 2)
                        : Border.all(color: isDark ? meta.iconColor.withOpacity(0.12) : Colors.transparent, width: 1),
                  ),
                  child: Icon(meta.icon, size: 22, color: circleFg),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: textColor,
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/products/${product.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${product.salePrice.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (product.discountPercent != null)
                      Text(
                        '${product.discountPercent!.toStringAsFixed(0)}% off',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductTileShimmer extends StatelessWidget {
  const _ProductTileShimmer();

  @override
  Widget build(BuildContext context) {
    return const ShimmerLoading(
      child: Card(
        margin: EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              ShimmerBox(width: 80, height: 80),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(height: 14, width: double.infinity),
                    SizedBox(height: 8),
                    ShimmerBox(height: 12, width: 60),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
