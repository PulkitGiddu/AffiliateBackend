import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/product.dart';
import '../../../widgets/empty_state.dart';
import '../providers/wishlist_provider.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistNotifierProvider);
    final productsAsync = ref.watch(wishlistProductsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Wishlist'),
      ),
      body: wishlistAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              message: 'No items in wishlist. Add deals from product details.',
              icon: Icons.favorite_border,
            );
          }
          return productsAsync.when(
            data: (products) {
              if (products.isEmpty) {
                return const EmptyState(
                  message: 'Loading wishlist...',
                  icon: Icons.hourglass_empty,
                );
              }
              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(wishlistNotifierProvider.notifier).load(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (_, i) {
                    final p = products[i];
                    return _WishlistProductTile(
                      product: p,
                      onRemove: () => ref
                          .read(wishlistNotifierProvider.notifier)
                          .remove(productId: p.id),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EmptyState(
              message: e.toString(),
              icon: Icons.error_outline,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          message: e.toString(),
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}

class _WishlistProductTile extends StatelessWidget {
  const _WishlistProductTile({
    required this.product,
    required this.onRemove,
  });

  final Product product;
  final VoidCallback onRemove;

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
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 72,
                    height: 72,
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
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite),
                color: Theme.of(context).colorScheme.error,
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
