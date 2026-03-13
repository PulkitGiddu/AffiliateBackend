import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_providers.dart';
import '../widgets/main_bottom_nav.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/referral_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/products/screens/product_detail_screen.dart';
import '../features/products/screens/products_screen.dart';
import '../features/wishlist/screens/wishlist_screen.dart';
import '../features/budgets/screens/budgets_screen.dart';
import '../features/coupons/screens/coupons_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/dashboard/screens/make_link_screen.dart';
import '../features/help/screens/help_chat_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Wraps a route child in a smooth fade + slight slide transition for a faster, polished feel.
/// Uses a key scoped to the route path to avoid duplicate key with StatefulShellRoute on back (Navigator keyReservation assertion).
Page<void> _transitionPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: ValueKey('transition-${state.matchedLocation}'),
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const curve = Curves.easeOutCubic;
      final fade = CurvedAnimation(parent: animation, curve: curve);
      final slide = Tween<Offset>(begin: const Offset(0.02, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: curve));
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: child,
        ),
      );
    },
  );
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final skippedLogin = ref.watch(skippedLoginProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final location = state.matchedLocation;

      if (location == '/' && !isLoggedIn && !skippedLogin) {
        return '/login';
      }
      final protectedRoutes = ['/profile', '/notifications'];
      final isProtected = protectedRoutes.any((r) => location.startsWith(r));
      if (isProtected && !isLoggedIn) {
        return '/login';
      }
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _ShellWithNav(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          // Tab 1: Categories (Products)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                builder: (_, __) => const ProductsScreen(),
              ),
              GoRoute(
                path: '/products/:id',
                pageBuilder: (_, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return _transitionPage(state, ProductDetailScreen(productId: id));
                },
              ),
            ],
          ),
          // Tab 2: Notifications
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (_, __) => const NotificationsScreen(),
              ),
            ],
          ),
          // Tab 3: Account (was Profile)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (_, state) => _transitionPage(state, const EditProfileScreen()),
                  ),
                  GoRoute(
                    path: 'wishlist',
                    pageBuilder: (_, state) => _transitionPage(state, const WishlistScreen()),
                  ),
                  GoRoute(
                    path: 'budgets',
                    pageBuilder: (_, state) => _transitionPage(state, const BudgetsScreen()),
                  ),
                  GoRoute(
                    path: 'make-link',
                    pageBuilder: (_, state) => _transitionPage(state, const MakeLinkScreen()),
                  ),
                  GoRoute(
                    path: 'help',
                    pageBuilder: (_, state) => _transitionPage(state, const HelpChatScreen()),
                  ),
                ],
              ),
            ],
          ),
          
        ],
      ),
      GoRoute(
        path: '/coupons',
        pageBuilder: (_, state) => _transitionPage(state, const CouponsScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (_, state) => _transitionPage(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (_, state) => _transitionPage(state, const RegisterScreen()),
      ),
      GoRoute(
        path: '/referral',
        pageBuilder: (_, state) => _transitionPage(state, const ReferralScreen()),
      ),
    ],
  );
});

class _ShellWithNav extends ConsumerWidget {
  const _ShellWithNav({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(bottomNavVisibleProvider);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          navigationShell,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              offset: visible ? Offset.zero : const Offset(0, 1.5),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: visible ? 1.0 : 0.0,
                child: MainBottomNav(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: (i) {
                    ref.read(bottomNavVisibleProvider.notifier).state = true;
                    navigationShell.goBranch(i);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
