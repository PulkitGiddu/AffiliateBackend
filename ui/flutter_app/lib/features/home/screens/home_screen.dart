import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../products/providers/product_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../providers/category_provider.dart';
import '../../../core/utils/network_utils.dart';
import '../../../widgets/shimmer_loading.dart';
import '../../../widgets/empty_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final productsAsync = ref.watch(topDealsProvider);
    final wishlistProductsAsync = ref.watch(wishlistProductsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(categoryListProvider);
          ref.invalidate(topDealsProvider);
          ref.invalidate(wishlistNotifierProvider);
        },
        child: CustomScrollView(
          slivers: [
            // 1. Top logo + search bar
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'SnatchMart',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () => context.push('/notifications'),
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => context.push('/products'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Theme.of(context).colorScheme.outline),
                            const SizedBox(width: 12),
                            Text(
                              'Search products, deals...',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const Spacer(),
                            Icon(Icons.mic_none_outlined, size: 20, color: Theme.of(context).colorScheme.outline),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 2. Categories (horizontal strip with outline icons, light purple bg, active indicator)
            categoriesAsync.when(
              data: (categories) => SliverToBoxAdapter(
                child: _CategoryStrip(
                  categories: categories,
                  selectedCategoryId: ref.watch(productCategoryFilterProvider),
                  onCategoryTap: (String? categoryId) {
                    ref.read(productCategoryFilterProvider.notifier).state = categoryId;
                    context.push('/products');
                  },
                ),
              ),
              loading: () => SliverToBoxAdapter(
                child: Builder(
                  builder: (context) {
                    final stripBg = Theme.of(context).colorScheme.brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.surfaceContainerHigh
                        : Theme.of(context).colorScheme.surfaceContainerLow;
                    return ShimmerLoading(
                      child: Container(
                        color: stripBg,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: 5,
                            itemBuilder: (_, __) => const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ShimmerBox(width: 64, height: 64),
                                  SizedBox(height: 8),
                                  ShimmerBox(width: 56, height: 12),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: EmptyState(
                  message: friendlyNetworkError(e),
                  icon: Icons.error_outline,
                ),
              ),
            ),
            // 3. Sponsored (banner carousel, normal speed)
            const SliverToBoxAdapter(
              child: _SponsoredBannersSection(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // 4. Promoted products banners (carousel)
            SliverToBoxAdapter(
              child: _PromoBanners(ref: ref, productsAsync: productsAsync),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // 5. Top Picks for you
            SliverToBoxAdapter(
              child: _TopPicksSection(ref: ref, productsAsync: productsAsync),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // 6. From your wishlist (X left in wishlist)
            SliverToBoxAdapter(
              child: _WishlistSection(ref: ref, wishlistProductsAsync: wishlistProductsAsync),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // 7. Ads section (dummy)
            const SliverToBoxAdapter(
              child: _AdsSection(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // 8. Dummy notifications strip
            const SliverToBoxAdapter(
              child: _NotificationsStrip(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            // 9. Top Deals
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top Deals',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/products'),
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),
            ),
            productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const SliverFillRemaining(
                    child: EmptyState(
                      message: 'No deals right now. Check back later!',
                      icon: Icons.local_offer_outlined,
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final p = products[i];
                        return _ProductCard(product: p);
                      },
                      childCount: products.length,
                    ),
                  ),
                );
              },
              loading: () => SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const _ProductCardShimmer(),
                    childCount: 6,
                  ),
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: EmptyState(
                  message: friendlyNetworkError(e),
                  icon: Icons.error_outline,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
      bottomNavigationBar: _GlassNavBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          switch (i) {
            case 1:
              context.push('/products');
              break;
            case 2:
              context.push('/coupons');
              break;
            case 3:
              context.push('/notifications');
              break;
            case 4:
              context.push('/profile');
              break;
          }
        },
      ),
    );
  }
}

// Promoted banners carousel (uses top deals or placeholder).
class _PromoBanners extends StatelessWidget {
  const _PromoBanners({required this.ref, required this.productsAsync});
  final WidgetRef ref;
  final AsyncValue<List<Product>> productsAsync;

  @override
  Widget build(BuildContext context) {
    final products = productsAsync.valueOrNull ?? [];
    final items = products.take(3).toList();
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _BannerCard(
          title: 'Deals of the day',
          subtitle: 'Up to 50% off on top picks',
          onTap: () => context.push('/products'),
        ),
      );
    }
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final p = items[i];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => context.push('/products/${p.id}'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p.productName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${p.salePrice.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          p.imageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(Icons.image_outlined, size: 48, color: Theme.of(context).colorScheme.primary),
                        ),
                      )
                    else
                      Icon(Icons.local_offer_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.title, required this.subtitle, required this.onTap});
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.6),
              Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

// Top Picks for you — always shows top deals horizontal list.
class _TopPicksSection extends StatelessWidget {
  const _TopPicksSection({required this.ref, required this.productsAsync});
  final WidgetRef ref;
  final AsyncValue<List<Product>> productsAsync;

  @override
  Widget build(BuildContext context) {
    final list = productsAsync.valueOrNull ?? [];
    final topPicks = list.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Picks for you',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (topPicks.isNotEmpty)
                TextButton(
                  onPressed: () => context.push('/products'),
                  child: const Text('See all'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (topPicks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          )
        else
          SizedBox(
            height: 148,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: topPicks.length,
              itemBuilder: (_, i) => _HorizontalProductCard(product: topPicks[i]),
            ),
          ),
      ],
    );
  }
}

// From your wishlist — "X left in wishlist" and horizontal list.
class _WishlistSection extends StatelessWidget {
  const _WishlistSection({
    required this.ref,
    required this.wishlistProductsAsync,
  });
  final WidgetRef ref;
  final AsyncValue<List<Product>> wishlistProductsAsync;

  @override
  Widget build(BuildContext context) {
    final wishlist = wishlistProductsAsync.valueOrNull ?? [];
    final count = wishlist.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                count == 0
                    ? 'From your wishlist'
                    : '$count ${count == 1 ? 'item' : 'items'} left in wishlist',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (count > 0)
                TextButton(
                  onPressed: () => context.push('/wishlist'),
                  child: const Text('See all'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (count == 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Add items from product details to see them here',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          )
        else
          SizedBox(
            height: 148,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: wishlist.length,
              itemBuilder: (_, i) => _HorizontalProductCard(product: wishlist[i]),
            ),
          ),
      ],
    );
  }
}

class _HorizontalProductCard extends StatelessWidget {
  const _HorizontalProductCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => context.push('/products/${product.id}'),
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl ?? '',
                  width: 120,
                  height: 88,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 120,
                    height: 88,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.image_not_supported_outlined, color: Theme.of(context).colorScheme.outline),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product.productName,
                style: Theme.of(context).textTheme.labelMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '₹${product.salePrice.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dummy ads section.
class _AdsSection extends StatelessWidget {
  const _AdsSection();

  @override
  Widget build(BuildContext context) {
    const ads = [
      _AdItem('Brand A', Icons.storefront_rounded),
      _AdItem('Brand B', Icons.shopping_bag_outlined),
      _AdItem('Brand C', Icons.card_giftcard_rounded),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Offers',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: ads.length,
            itemBuilder: (_, i) {
              final item = ads[i];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 160,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item.icon, size: 32, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(height: 4),
                            Text(item.name, style: Theme.of(context).textTheme.labelLarge),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'AD',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AdItem {
  const _AdItem(this.name, this.icon);
  final String name;
  final IconData icon;
}

// Sponsored: 5 banners in carousel, 0.5s per slide.
const List<_BannerItem> _sponsoredBanners = [
  _BannerItem('lib/asserts/banner_1_diwali.png', 'Diwali Sale'),
  _BannerItem('lib/asserts/banner_2_flipkart.png', 'Flipkart Big Billion'),
  _BannerItem('lib/asserts/banner_3_myntra.png', 'Myntra Sale'),
  _BannerItem('lib/asserts/banner_4_mega.png', 'Mega Sale'),
  _BannerItem('lib/asserts/banner_5_super.png', 'Super Savings'),
];

class _BannerItem {
  const _BannerItem(this.assetPath, this.title);
  final String assetPath;
  final String title;
}

class _SponsoredBannersSection extends StatefulWidget {
  const _SponsoredBannersSection();

  @override
  State<_SponsoredBannersSection> createState() => _SponsoredBannersSectionState();
}

class _SponsoredBannersSectionState extends State<_SponsoredBannersSection> {
  static const int _intervalMs = 3500; // normal speed (~3.5 sec per banner)
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      final page = _pageController.page ?? 0;
      final index = page.round() % _sponsoredBanners.length;
      if (index != _currentPage) setState(() => _currentPage = index);
    });
    _timer = Timer.periodic(const Duration(milliseconds: _intervalMs), (_) {
      if (!_pageController.hasClients) return;
      final current = _pageController.page?.round() ?? 0;
      final next = (current + 1) % _sponsoredBanners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Sponsored',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _sponsoredBanners.length,
            itemBuilder: (context, index) {
              final item = _sponsoredBanners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        item.assetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _BannerFallback(title: item.title),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _sponsoredBanners.length,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == i ? 10 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _BannerFallback extends StatelessWidget {
  const _BannerFallback({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}

// Dummy notifications strip.
class _NotificationsStrip extends StatelessWidget {
  const _NotificationsStrip();

  @override
  Widget build(BuildContext context) {
    const notifications = [
      _NotifItem('Flash sale live — up to 40% off', Icons.flash_on_rounded),
      _NotifItem('New coupons added', Icons.card_giftcard_rounded),
      _NotifItem('Price drop on your wishlist items', Icons.favorite_rounded),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Updates',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () => context.push('/notifications'),
                child: const Text('View all'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final item = notifications[i];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/notifications'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(item.icon, size: 22, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.message,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 20, color: Theme.of(context).colorScheme.outline),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NotifItem {
  const _NotifItem(this.message, this.icon);
  final String message;
  final IconData icon;
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

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

class _ProductCardShimmer extends StatelessWidget {
  const _ProductCardShimmer();

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

/// iOS-style bottom nav with frosted glass (blur + semi-transparent surface).
class _GlassNavBar extends StatelessWidget {
  const _GlassNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = Theme.of(context).colorScheme.primary;
    final yellow = Theme.of(context).colorScheme.secondary;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      blue.withOpacity(0.35),
                      yellow.withOpacity(0.15),
                    ]
                  : [
                      blue.withOpacity(0.12),
                      yellow.withOpacity(0.25),
                    ],
            ),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.12)
                    : blue.withOpacity(0.2),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                backgroundColor: Colors.transparent,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                indicatorColor: isDark
                    ? yellow.withOpacity(0.85)
                    : yellow.withOpacity(0.95),
                height: 64,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.grid_view_outlined),
                    selectedIcon: Icon(Icons.grid_view),
                    label: 'Products',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.card_giftcard_outlined),
                    selectedIcon: Icon(Icons.card_giftcard),
                    label: 'Coupons',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.notifications_outlined),
                    selectedIcon: Icon(Icons.notifications),
                    label: 'Notification',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outline icon for category by slug/name (e-commerce style).
IconData _categoryIcon(String? id, String name, String slug) {
  final s = (slug.isEmpty ? name.toLowerCase() : slug).replaceAll(' ', '-');
  if (s.contains('electron')) return Icons.laptop_mac_outlined;
  if (s.contains('fashion') || s.contains('cloth')) return Icons.checkroom_outlined;
  if (s.contains('home') || s.contains('kitchen')) return Icons.lightbulb_outline;
  if (s.contains('sport') || s.contains('fitness')) return Icons.fitness_center_outlined;
  if (s.contains('beauty')) return Icons.face_retouching_natural_outlined;
  if (s.contains('book') || s.contains('station')) return Icons.menu_book_outlined;
  if (s.contains('auto') || s.contains('vehicle')) return Icons.directions_bike_outlined;
  if (s.contains('furniture')) return Icons.chair_outlined;
  if (s.contains('health') || s.contains('hygiene')) return Icons.medication_outlined;
  if (s.contains('mobile')) return Icons.smartphone_outlined;
  return Icons.category_outlined;
}

/// Category strip: theme-aware bg, horizontal scroll, outline icons, active = darker bg + bar.
class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryTap,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final void Function(String? categoryId) onCategoryTap;

  static const double _itemWidth = 72;
  static const double _iconBoxSize = 64;
  static const double _iconSize = 30;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final stripBg = isDark
        ? scheme.surfaceContainerHigh
        : scheme.surfaceContainerLow;
    return Container(
      width: double.infinity,
      color: stripBg,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CategoryItem(
              label: 'For You',
              icon: Icons.shopping_bag_outlined,
              iconBoxSize: _iconBoxSize,
              iconSize: _iconSize,
              isSelected: selectedCategoryId == null || (selectedCategoryId?.isEmpty ?? true),
              onTap: () => onCategoryTap(null),
            ),
            ...categories.map(
              (c) => _CategoryItem(
                label: c.name,
                icon: _categoryIcon(c.id, c.name, c.slug),
                iconBoxSize: _iconBoxSize,
                iconSize: _iconSize,
                isSelected: selectedCategoryId == c.id,
                onTap: () => onCategoryTap(c.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.iconBoxSize,
    required this.iconSize,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final double iconBoxSize;
  final double iconSize;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final itemBg = isSelected
        ? scheme.surfaceContainerHighest
        : scheme.surface;
    final borderColor = isSelected
        ? scheme.outline
        : scheme.outlineVariant;
    final contentColor = scheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: _CategoryStrip._itemWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  child: Container(
                    width: iconBoxSize,
                    height: iconBoxSize,
                    decoration: BoxDecoration(
                      color: itemBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: borderColor,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: iconSize,
                        color: contentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: contentColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 24,
                    height: 3,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(2),
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
