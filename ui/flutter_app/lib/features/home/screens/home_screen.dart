import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import '../../../config/app_providers.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../auth/providers/auth_provider.dart';
import '../../products/providers/product_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../providers/category_provider.dart';
import '../../../core/utils/network_utils.dart';
import '../../../widgets/shimmer_loading.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/category_circle.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0;
  final _scrollController = ScrollController();
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final delta = offset - _lastScrollOffset;
    _lastScrollOffset = offset;

    if (offset <= 0) {
      ref.read(bottomNavVisibleProvider.notifier).state = true;
      return;
    }

    if (delta > 4) {
      ref.read(bottomNavVisibleProvider.notifier).state = false;
    } else if (delta < -4) {
      ref.read(bottomNavVisibleProvider.notifier).state = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider).valueOrNull;
    if (auth != null && auth.userId.isNotEmpty) {
      ref.watch(userProfileProvider(auth.userId));
    }

    final categoriesAsync = ref.watch(categoryListProvider);
    final productsAsync = ref.watch(topDealsProvider);
    final wishlistProductsAsync = ref.watch(wishlistProductsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(categoryListProvider);
          ref.invalidate(topDealsProvider);
          ref.invalidate(wishlistNotifierProvider);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
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
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [scheme.surfaceContainerHigh, scheme.surfaceContainer]
                        : [scheme.primary, scheme.secondary],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sliding toggle: Home | TheJewels + wishlist icon
                    Row(
                      children: [
                        _HeaderToggle(
                          labels: const ['Home', 'TheJewels'],
                          selectedIndex: _selectedTab,
                          onChanged: (i) {
                            if (mounted) setState(() => _selectedTab = i);
                          },
                          scheme: scheme,
                        ),
                        const Spacer(),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.push('/profile/wishlist'),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? scheme.surfaceContainerHighest.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.favorite_border_rounded,
                                size: 22,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? scheme.onSurface
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Search bar
                    Builder(builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      final searchBg = isDark
                          ? scheme.surfaceContainerHighest
                          : Colors.white.withOpacity(0.95);
                      final searchIcon = isDark ? scheme.primary : scheme.primary;
                      final searchHint = isDark ? scheme.onSurfaceVariant : scheme.onSurfaceVariant;
                      return Material(
                        color: searchBg,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 0,
                        child: InkWell(
                          onTap: () => context.push('/products'),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            child: Row(
                              children: [
                                Icon(Icons.search_rounded, size: 22, color: searchIcon),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    'Search for products',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: searchHint,
                                        ),
                                  ),
                                ),
                                Icon(Icons.mic_rounded, size: 20, color: searchIcon.withOpacity(0.8)),
                                const SizedBox(width: 12),
                                Icon(Icons.camera_alt_outlined, size: 20, color: searchIcon.withOpacity(0.8)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Content switches between Home feed and TheJewels
            if (_selectedTab == 1) ...[
              const SliverFillRemaining(
                child: _TheJewelsVideoSection(),
              ),
            ] else ...[
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
                )
                    .animate()
                    .fadeIn(duration: 380.ms, curve: Curves.easeOut)
                    .slideY(begin: 0.04, end: 0, curve: Curves.easeOut),
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
            // 3. Sponsored (banner carousel) + optional Lottie hero
            SliverToBoxAdapter(
              child: _SponsoredBannersSection()
                  .animate()
                  .fadeIn(delay: 80.ms, duration: 400.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.03, end: 0, delay: 80.ms, duration: 400.ms, curve: Curves.easeOut),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // 5. Top Picks for you
            SliverToBoxAdapter(
              child: _TopPicksSection(ref: ref, productsAsync: productsAsync)
                  .animate()
                  .fadeIn(delay: 120.ms, duration: 380.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.02, end: 0, delay: 120.ms, duration: 380.ms, curve: Curves.easeOut),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // 6. From your wishlist (X left in wishlist)
            SliverToBoxAdapter(
              child: _WishlistSection(ref: ref, wishlistProductsAsync: wishlistProductsAsync)
                  .animate()
                  .fadeIn(delay: 140.ms, duration: 380.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.02, end: 0, delay: 140.ms, duration: 380.ms, curve: Curves.easeOut),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // 7. Recommended deals for you (Amazon-style grouped cards)
            SliverToBoxAdapter(
              child: _RecommendedDealsSection(
                categoriesAsync: categoriesAsync,
                productsAsync: productsAsync,
              ).animate()
                  .fadeIn(delay: 160.ms, duration: 380.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.02, end: 0, delay: 160.ms, duration: 380.ms, curve: Curves.easeOut),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // 8. Ads section (dummy)
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
              )
                  .animate()
                  .fadeIn(delay: 120.ms, duration: 350.ms)
                  .slideX(begin: -0.02, end: 0, delay: 120.ms, duration: 350.ms, curve: Curves.easeOut),
            ),
            productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyDealsLottie(
                      message: 'No deals right now. Check back later!',
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final p = products[i];
                        return _ProductCard(product: p)
                            .animate()
                            .fadeIn(delay: (50 * i).ms, duration: 350.ms, curve: Curves.easeOut)
                            .slideX(begin: 0.02, end: 0, delay: (50 * i).ms, duration: 350.ms, curve: Curves.easeOut);
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
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ],
        ),
      ),
    );
  }
}

const String _kDefaultProfilePhotoUrl =
    'https://avatars.githubusercontent.com/u/101356458?v=4';

/// Empty state with optional Lottie and fallback icon.
class _EmptyDealsLottie extends StatelessWidget {
  const _EmptyDealsLottie({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 140,
              child: Lottie.asset(
                'assets/lottie/placeholder.json',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.local_offer_outlined,
                  size: 80,
                  color: scheme.primary.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// User avatar for home header (top left). Taps to profile. Shows guest icon when logged out.
class _HeaderUserAvatar extends ConsumerWidget {
  const _HeaderUserAvatar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider).valueOrNull;
    final primary = Theme.of(context).colorScheme.primary;

    // Logged out: show guest avatar (no profile photo)
    if (auth == null || auth.userId.isEmpty) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/profile'),
          borderRadius: BorderRadius.circular(20),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withOpacity(0.3),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_rounded, size: 24, color: primary),
            ),
          ),
        ),
      );
    }

    final userId = auth.userId;
    final userAsync = ref.watch(userProfileProvider(userId));
    final user = userAsync.valueOrNull;
    final photoUrl = user?.profilePictureUrl ?? _kDefaultProfilePhotoUrl;
    final name = user != null
        ? [user.firstName, user.lastName].where((e) => e != null && e.isNotEmpty).join(' ').trim()
        : '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/profile'),
        borderRadius: BorderRadius.circular(20),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white.withOpacity(0.3),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: photoUrl,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                placeholder: (_, __) => Text(
                  initial,
                  style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                errorWidget: (_, __, ___) => Text(
                  initial,
                  style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Video showcase for TheJewels tab.
class _TheJewelsVideoSection extends StatefulWidget {
  const _TheJewelsVideoSection();

  @override
  State<_TheJewelsVideoSection> createState() => _TheJewelsVideoSectionState();
}

class _TheJewelsVideoSectionState extends State<_TheJewelsVideoSection> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('lib/asserts/animation/animation.mp4')
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _initialized = true);
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_initialized) {
      return Center(
        child: CircularProgressIndicator(color: scheme.primary),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
                // Gradient overlay at bottom for text readability
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'TheJewels',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Premium jewellery deals coming soon',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Play/pause tap
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                      child: Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

/// Glassmorphic sliding toggle for header tabs (Home / TheJewels).
class _HeaderToggle extends StatelessWidget {
  const _HeaderToggle({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    required this.scheme,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const itemH = 40.0;
    const itemW = 100.0;
    const pad = 3.0;
    final totalW = itemW * labels.length + pad * 2;

    final trackColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.18);
    final trackBorder = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.white.withOpacity(0.25);

    final bubbleColor = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.white.withOpacity(0.85);
    final bubbleBorder = isDark
        ? Colors.white.withOpacity(0.15)
        : Colors.white.withOpacity(0.5);

    final selectedTextColor = isDark ? Colors.white : scheme.primary;
    final unselectedTextColor = isDark
        ? Colors.white.withOpacity(0.6)
        : Colors.white.withOpacity(0.9);

    return ClipRRect(
      borderRadius: BorderRadius.circular((itemH + pad * 2) / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: totalW,
          height: itemH + pad * 2,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular((itemH + pad * 2) / 2),
            border: Border.all(color: trackBorder, width: 1),
          ),
          child: Stack(
            children: [
              // Glass bubble indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                left: pad + selectedIndex * itemW,
                top: pad,
                child: Container(
                  width: itemW,
                  height: itemH,
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(itemH / 2),
                    border: Border.all(color: bubbleBorder, width: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
              // Labels
              Row(
                children: List.generate(labels.length, (i) {
                  final selected = selectedIndex == i;
                  return GestureDetector(
                    onTap: () => onChanged(i),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: itemW,
                      height: itemH + pad * 2,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: selected ? selectedTextColor : unselectedTextColor,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 14,
                          ),
                          child: Text(labels[i]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown when user is not logged in and Dashboard tab is selected.
class _DashboardLoginGate extends StatelessWidget {
  const _DashboardLoginGate();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 64,
            color: scheme.primary.withOpacity(0.7),
          ),
          const SizedBox(height: 24),
          Text(
            'Log in to access the dashboard',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Earnings, reports, and exclusive tools are available after you sign in.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.login_rounded, size: 20),
            label: const Text('Log in'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashboard: user summary cards + Money / Exclusive Tools / Reports (theme-aware).
class _DashboardContent extends ConsumerWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final auth = ref.watch(authStateProvider).valueOrNull;
    final userId = auth?.userId ?? '';
    final userAsync = userId.isNotEmpty ? ref.watch(userProfileProvider(userId)) : null;
    final user = userAsync?.valueOrNull;
    final displayName = user != null
        ? [user.firstName, user.lastName].where((e) => e != null && e.isNotEmpty).join(' ').trim()
        : 'Guest';
    final displayNameFallback = displayName.isEmpty ? 'User' : displayName;
    final initial = displayNameFallback.isNotEmpty ? displayNameFallback[0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header cards row (profile, User ID, Total Profit)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [scheme.primary, scheme.secondary],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _DashboardHeaderCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: Text(
                            initial,
                            style: TextStyle(
                              color: scheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            displayNameFallback,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DashboardHeaderCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'User ID',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userId.isEmpty ? '—' : userId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DashboardHeaderCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total Profit',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '₹30',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Three columns on wide screens; single column on narrow to avoid overflow
          LayoutBuilder(
            builder: (context, constraints) {
              final useColumn = constraints.maxWidth < 500;
              // Order: Money, Exclusive Tools, Reports (Exclusive above Reports)
              final sectionCards = [
                _DashboardSectionCard(
                  title: 'Money',
                  scheme: scheme,
                  items: [
                    _DashboardItem(icon: Icons.currency_rupee_rounded, label: 'My Earnings'),
                    _DashboardItem(icon: Icons.request_quote_rounded, label: 'Request Payment'),
                    _DashboardItem(icon: Icons.history_rounded, label: 'Payment History'),
                  ],
                ),
                _DashboardSectionCard(
                  title: 'Exclusive Tools',
                  scheme: scheme,
                  items: [
                    _DashboardItem(icon: Icons.link_rounded, label: 'Make Link', route: '/profile/make-link'),
                    _DashboardItem(icon: Icons.trending_up_rounded, label: 'Profit Share'),
                    _DashboardItem(icon: Icons.badge_rounded, label: 'EK Affiliaters'),
                  ],
                ),
                _DashboardSectionCard(
                  title: 'Reports',
                  scheme: scheme,
                  items: [
                    _DashboardItem(icon: Icons.show_chart_rounded, label: 'Reports'),
                    _DashboardItem(icon: Icons.description_rounded, label: 'Flipkart Reports'),
                    _DashboardItem(icon: Icons.link_rounded, label: 'My Link Performance'),
                  ],
                ),
              ];
              if (useColumn) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < sectionCards.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      sectionCards[i],
                    ],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: sectionCards[0]),
                  const SizedBox(width: 12),
                  Expanded(child: sectionCards[1]),
                  const SizedBox(width: 12),
                  Expanded(child: sectionCards[2]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardHeaderCard extends StatelessWidget {
  const _DashboardHeaderCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _DashboardItem {
  const _DashboardItem({required this.icon, required this.label, this.route});
  final IconData icon;
  final String label;
  final String? route;
}

class _DashboardSectionCard extends StatelessWidget {
  const _DashboardSectionCard({
    required this.title,
    required this.scheme,
    required this.items,
  });
  final String title;
  final ColorScheme scheme;
  final List<_DashboardItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: scheme.surfaceContainerHighest.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
            ),
            const SizedBox(height: 10),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Material(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: item.route != null
                        ? () => context.push(item.route!)
                        : null,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: scheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(item.icon, size: 16, color: scheme.primary),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: 0),
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, size: 18, color: scheme.primary),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
                  onPressed: () => context.push('/profile/wishlist'),
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

class _AdsSection extends StatelessWidget {
  const _AdsSection();

  static const _offers = [
    _OfferAsset('lib/asserts/Offers/apple.png', 'Apple'),
    _OfferAsset('lib/asserts/Offers/apple17pro.jpg', 'iPhone 17 Pro'),
    _OfferAsset('lib/asserts/Offers/samsungS.webp', 'Samsung Galaxy S'),
    _OfferAsset('lib/asserts/Offers/nothing.webp', 'Nothing Phone'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Offers',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 340,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _offers.length,
            itemBuilder: (_, i) {
              final offer = _offers[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: isDark ? scheme.surfaceContainerHigh : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? scheme.outlineVariant.withOpacity(0.2)
                          : scheme.outlineVariant.withOpacity(0.25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Container(
                          width: 300,
                          height: 340,
                          color: isDark ? scheme.surfaceContainerHighest : const Color(0xFFF5F5F5),
                          child: Image.asset(
                            offer.assetPath,
                            width: 300,
                            height: 340,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.local_offer_rounded, size: 32, color: scheme.primary),
                                  const SizedBox(height: 4),
                                  Text(offer.label, style: Theme.of(context).textTheme.labelLarge),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Ad',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
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

class _OfferAsset {
  const _OfferAsset(this.assetPath, this.label);
  final String assetPath;
  final String label;
}

const List<_BannerItem> _sponsoredBanners = [
  _BannerItem('lib/asserts/sales/flipkartbig.jpg', 'Flipkart Big Sale'),
  _BannerItem('lib/asserts/sales/flipkarrsale.webp', 'Flipkart Sale'),
  _BannerItem('lib/asserts/sales/myntra.jpg', 'Myntra Sale'),
  _BannerItem('lib/asserts/sales/myntrasale.jpg', 'Myntra End of Season'),
  _BannerItem('lib/asserts/sales/amazon.jpeg', 'Amazon Deals'),
  _BannerItem('lib/asserts/sales/amazonsale.jpeg', 'Amazon Great Sale'),
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
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: scheme.surfaceContainerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        shadowColor: scheme.shadow.withOpacity(0.06),
        child: InkWell(
          onTap: () => context.push('/products/${product.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl ?? '',
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 88,
                      height: 88,
                      color: scheme.surfaceContainerHighest,
                      child: Icon(Icons.image_rounded, color: scheme.outline),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 88,
                      height: 88,
                      color: scheme.surfaceContainerHighest,
                      child: Icon(Icons.image_not_supported_rounded, color: scheme.outline),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${product.salePrice.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (product.discountPercent != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${product.discountPercent!.toStringAsFixed(0)}% off',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: scheme.tertiary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: scheme.outline, size: 22),
              ],
            ),
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

/// Horizontally scrollable category strip with colored circular icons.
class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryTap,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final void Function(String? categoryId) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;

    return Container(
      color: isDark ? scheme.surfaceContainerLow : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: 90,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: categories.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              final isAll = selectedCategoryId == null || selectedCategoryId!.isEmpty;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CategoryCircle(
                  label: 'All\nCategories',
                  meta: categoryMetaFor('All', 'all'),
                  isSelected: isAll,
                  onTap: () => onCategoryTap(null),
                ),
              );
            }
            final c = categories[i - 1];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CategoryCircle(
                label: c.name,
                meta: categoryMetaFor(c.name, c.slug),
                isSelected: selectedCategoryId == c.id,
                onTap: () => onCategoryTap(c.id),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recommended deals section (Amazon-style: horizontally scrollable category
// cards, each with a 2x2 product grid, discount badges, and deal labels).
// ---------------------------------------------------------------------------

class _RecommendedDealsSection extends StatelessWidget {
  const _RecommendedDealsSection({
    required this.categoriesAsync,
    required this.productsAsync,
  });

  final AsyncValue<List<Category>> categoriesAsync;
  final AsyncValue<List<Product>> productsAsync;

  @override
  Widget build(BuildContext context) {
    return categoriesAsync.when(
      data: (categories) => productsAsync.when(
        data: (products) {
          if (products.isEmpty) return const SizedBox.shrink();

          final grouped = <String, List<Product>>{};
          grouped['Deals for you'] = products.take(4).toList();
          for (final cat in categories) {
            final catProducts = products.where((p) => p.categoryId == cat.id).toList();
            if (catProducts.isNotEmpty) {
              grouped[cat.name] = catProducts.take(4).toList();
            }
          }
          if (grouped.length <= 1) {
            final remaining = products.skip(4).toList();
            if (remaining.length >= 4) {
              grouped['Trending Now'] = remaining.take(4).toList();
            }
            if (remaining.length >= 8) {
              grouped['Best Sellers'] = remaining.skip(4).take(4).toList();
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Recommended deals for you',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 330,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: grouped.length,
                  itemBuilder: (context, i) {
                    final entry = grouped.entries.elementAt(i);
                    return _DealCard(
                      title: entry.key,
                      products: entry.value,
                      onTapMore: () => context.push('/products'),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => _RecommendedDealsShimmer(),
        error: (_, __) => const SizedBox.shrink(),
      ),
      loading: () => _RecommendedDealsShimmer(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard({
    required this.title,
    required this.products,
    required this.onTapMore,
  });

  final String title;
  final List<Product> products;
  final VoidCallback onTapMore;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? scheme.surfaceContainerHigh : Colors.white;

    final gridItems = products.take(4).toList();
    while (gridItems.length < 4) {
      gridItems.add(gridItems.last);
    }

    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? scheme.outlineVariant.withOpacity(0.2) : scheme.outlineVariant.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: onTapMore,
                  child: Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant, size: 24),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.82,
                physics: const NeverScrollableScrollPhysics(),
                children: gridItems.map((p) => _DealGridItem(product: p)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DealGridItem extends StatelessWidget {
  const _DealGridItem({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final discount = product.discountPercent;
    final hasExpiry = product.dealsExpiresAt != null &&
        product.dealsExpiresAt!.isAfter(DateTime.now());

    String dealLabel;
    if (hasExpiry) {
      final diff = product.dealsExpiresAt!.difference(DateTime.now());
      final h = diff.inHours.toString().padLeft(2, '0');
      final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
      dealLabel = 'Ends in $h:$m:$s';
    } else {
      dealLabel = 'Limited time deal';
    }

    return GestureDetector(
      onTap: () => context.push('/products/${product.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark
                    ? scheme.surfaceContainerHighest
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(Icons.image_outlined, color: scheme.onSurfaceVariant, size: 28),
                        ),
                      )
                    : Center(
                        child: Icon(Icons.image_outlined, color: scheme.onSurfaceVariant, size: 28),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (discount != null && discount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFCC0C39),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${discount.toStringAsFixed(0)}% off',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 3),
          Text(
            dealLabel,
            style: TextStyle(
              color: const Color(0xFFCC0C39),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _RecommendedDealsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ShimmerLoading(
            child: ShimmerBox(width: 220, height: 22),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 330,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 3,
            itemBuilder: (_, __) => Container(
              width: 280,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: ShimmerLoading(
                child: ShimmerBox(
                  width: 280,
                  height: 330,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
