import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/app_providers.dart';
import '../../../models/product.dart';
import '../providers/product_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../../models/price_history_entry.dart';
import '../../../widgets/shimmer_loading.dart';
import '../../../widgets/empty_state.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    final priceHistoryAsync = ref.watch(productPriceHistoryProvider(productId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => context.push('/wishlist'),
          ),
        ],
      ),
      body: productAsync.when(
        data: (product) => _Content(
          product: product,
          priceHistory: priceHistoryAsync.valueOrNull ?? <PriceHistoryEntry>[],
          onOpenAffiliateLink: () => _openAffiliateLink(context, ref, product),
          onAddWishlist: () => _addWishlist(ref, product),
          onSetBudgetAlert: () => _setBudgetAlert(context, ref, product),
        ),
        loading: () => const _DetailShimmer(),
        error: (e, _) => EmptyState(
          message: e.toString(),
          icon: Icons.error_outline,
        ),
      ),
    );
  }

  static Future<void> _openAffiliateLink(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final clickRepo = ref.read(affiliateClickRepositoryProvider);
    final userId = ref.read(authStateProvider).valueOrNull?.userId;
    try {
      await clickRepo.track(
        userId: userId,
        productId: product.id,
        merchantId: product.merchantId,
      );
    } catch (_) {}
    final uri = Uri.parse(product.affiliateUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  static void _addWishlist(WidgetRef ref, Product product) {
    final userId = ref.read(authStateProvider).valueOrNull?.userId;
    if (userId == null) {
      return;
    }
    ref.read(wishlistNotifierProvider.notifier).add(productId: product.id);
  }

  static void _setBudgetAlert(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) {
    final userId = ref.read(authStateProvider).valueOrNull?.userId;
    if (userId == null) return;
    ref.read(budgetListNotifierProvider.notifier).create(
          productName: product.productName,
          targetPrice: product.salePrice,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget alert set')),
      );
    }
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.product,
    required this.priceHistory,
    required this.onOpenAffiliateLink,
    required this.onAddWishlist,
    required this.onSetBudgetAlert,
  });

  final Product product;
  final List<PriceHistoryEntry> priceHistory;
  final VoidCallback onOpenAffiliateLink;
  final VoidCallback onAddWishlist;
  final VoidCallback onSetBudgetAlert;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
            Image.network(
              product.imageUrl!,
              height: 280,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 280,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.image_not_supported_outlined, size: 64),
              ),
            )
          else
            Container(
              height: 280,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.image_outlined, size: 64),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '₹${product.salePrice.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (product.originalPrice != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '₹${product.originalPrice!.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                      if (product.discountPercent != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${product.discountPercent!.toStringAsFixed(0)}% off',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
                if (product.description != null &&
                    product.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    product.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onOpenAffiliateLink,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open deal (affiliate link)'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onAddWishlist,
                        icon: const Icon(Icons.favorite_border),
                        label: const Text('Wishlist'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSetBudgetAlert,
                        icon: const Icon(Icons.notifications_active_outlined),
                        label: const Text('Price alert'),
                      ),
                    ),
                  ],
                ),
                if (priceHistory.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Price history',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...priceHistory.take(5).map((e) {
                    final price = e.price;
                    final date = e.recordedAt?.toIso8601String() ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('₹${price?.toStringAsFixed(0) ?? "-"}'),
                          Text(
                            date.length > 10 ? date.substring(0, 10) : date,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailShimmer extends StatelessWidget {
  const _DetailShimmer();

  @override
  Widget build(BuildContext context) {
    return const ShimmerLoading(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShimmerBox(height: 280, width: double.infinity),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 24, width: double.infinity),
                SizedBox(height: 8),
                ShimmerBox(height: 20, width: 100),
                SizedBox(height: 24),
                ShimmerBox(height: 48, width: double.infinity),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
