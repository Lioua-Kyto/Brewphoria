import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:brewphoria/core/router/route_names.dart';
import 'package:brewphoria/features/auth/presentation/screens/login_screen.dart';
import 'package:brewphoria/features/auth/presentation/providers/auth_provider.dart';
import 'package:brewphoria/features/shop/presentation/screens/shop_screen.dart';
import 'package:brewphoria/features/shop/presentation/screens/product_detail_screen.dart';
import 'package:brewphoria/features/cart/presentation/screens/cart_screen.dart';
import 'package:brewphoria/features/cart/presentation/providers/cart_provider.dart';
import 'package:brewphoria/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:brewphoria/features/checkout/presentation/screens/order_success_screen.dart';
import 'package:brewphoria/features/orders/presentation/screens/orders_screen.dart';
import 'package:brewphoria/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:brewphoria/features/loyalty/presentation/screens/loyalty_screen.dart';
import 'package:brewphoria/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:brewphoria/features/profile/presentation/screens/profile_screen.dart';
import 'package:brewphoria/features/chatbot/presentation/screens/chatbot_screen.dart';
import 'package:brewphoria/features/reviews/presentation/screens/write_review_screen.dart';
import 'package:brewphoria/features/reviews/presentation/screens/reviews_screen.dart';
import 'package:brewphoria/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:brewphoria/features/auth/presentation/providers/guest_provider.dart';
import 'package:brewphoria/core/storage/hive_service.dart';
import 'package:brewphoria/core/widgets/glass_tab_bar.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

@riverpod
GoRouter appRouter(Ref ref) {
  // Key routing off the app's own user state (set by both real and demo
  // sign-in), not the raw Firebase stream — otherwise offline/demo login never
  // registers with the router.
  final userState = ref.watch(authNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.shop,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = userState.valueOrNull != null;
      final loc = state.matchedLocation;
      final isLoggingIn = loc == RoutePaths.login;
      final isOnboarding = loc == RoutePaths.onboarding;

      bool onboarded;
      try {
        onboarded =
            HiveService.userPrefsBox.get(HiveKeys.onboardingDone) == true;
      } catch (_) {
        onboarded = true;
      }

      if (isLoggedIn) {
        if (isLoggingIn || isOnboarding) return RoutePaths.shop;
        return null;
      }

      // Not logged in.
      if (!onboarded && !isOnboarding) return RoutePaths.onboarding;

      if (isGuestMode()) {
        // Guests may browse and build a local cart; account-only surfaces
        // (checkout, orders, loyalty, profile) still redirect to sign-in.
        const gated = ['/orders', '/loyalty', '/profile', '/checkout'];
        if (gated.any(loc.startsWith)) return RoutePaths.login;
        if (isOnboarding) return RoutePaths.shop;
        return null; // shop, cart, product detail, chat, reviews, notifications
      }

      if (!isLoggingIn && !isOnboarding) return RoutePaths.login;
      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      ref.read(authNotifierProvider.notifier).authStateChanges(),
    ),
    routes: [
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: OnboardingScreen()),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        pageBuilder: (context, state) => const NoTransitionPage(child: LoginScreen()),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.shop,
            name: RouteNames.shop,
            pageBuilder: (context, state) => const NoTransitionPage(child: ShopScreen()),
            routes: [
              GoRoute(
                path: ':slug',
                name: RouteNames.productDetail,
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) {
                  final slug = state.pathParameters['slug'] ?? '';
                  return CustomTransitionPage(
                    key: state.pageKey,
                    transitionDuration: const Duration(milliseconds: 540),
                    reverseTransitionDuration:
                        const Duration(milliseconds: 420),
                    child: ProductDetailScreen(slug: slug),
                    transitionsBuilder:
                        (context, animation, secondary, child) {
                      // The hero image flies via Hero; the screen itself just
                      // eases in (its sheet/controls self-animate off this
                      // route animation). Background fades so it never hard-cuts.
                      final curved = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                        reverseCurve: Curves.easeInCubic,
                      );
                      return FadeTransition(opacity: curved, child: child);
                    },
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.cart,
            name: RouteNames.cart,
            pageBuilder: (context, state) => const NoTransitionPage(child: CartScreen()),
          ),
          GoRoute(
            path: RoutePaths.orders,
            name: RouteNames.orders,
            pageBuilder: (context, state) => const NoTransitionPage(child: OrdersScreen()),
            routes: [
              GoRoute(
                path: ':id',
                name: RouteNames.orderDetail,
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return MaterialPage(child: OrderDetailScreen(orderId: id));
                },
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.loyalty,
            name: RouteNames.loyalty,
            pageBuilder: (context, state) => const NoTransitionPage(child: LoyaltyScreen()),
          ),
          GoRoute(
            path: RoutePaths.profile,
            name: RouteNames.profile,
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.checkout,
        name: RouteNames.checkout,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return const MaterialPage(child: CheckoutScreen());
        },
      ),
      GoRoute(
        path: RoutePaths.checkoutSuccess,
        name: RouteNames.checkoutSuccess,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MaterialPage(child: OrderSuccessScreen(orderData: extra));
        },
      ),
      GoRoute(
        path: RoutePaths.notifications,
        name: RouteNames.notifications,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(child: NotificationsScreen()),
      ),
      GoRoute(
        path: RoutePaths.chat,
        name: RouteNames.chat,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(child: ChatbotScreen()),
      ),
      GoRoute(
        path: RoutePaths.writeReview,
        name: RouteNames.writeReview,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final orderId = state.pathParameters['orderId'] ?? '';
          return MaterialPage(child: WriteReviewScreen(orderId: orderId));
        },
      ),
      GoRoute(
        path: RoutePaths.reviews,
        name: RouteNames.reviews,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final extra = state.extra as Map<String, dynamic>? ?? const {};
          return MaterialPage(
            child: ReviewsScreen(
              productId: id,
              productName: (extra['name'] as String?) ?? 'Reviews',
              avgRating: (extra['avgRating'] as num?)?.toDouble() ?? 0,
              reviewCount: (extra['reviewCount'] as int?) ?? 0,
            ),
          );
        },
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    // ignore: avoid_dynamic_calls
    _subscription.cancel();
    super.dispose();
  }
}

class ScaffoldWithBottomNav extends ConsumerWidget {
  const ScaffoldWithBottomNav({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location.startsWith('/cart')) {
      currentIndex = 1;
    } else if (location.startsWith('/orders')) {
      currentIndex = 2;
    } else if (location.startsWith('/loyalty')) {
      currentIndex = 3;
    } else if (location.startsWith('/profile')) {
      currentIndex = 4;
    }

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(child: child),
          Align(
            alignment: Alignment.bottomCenter,
            child: GlassTabBar(
              currentIndex: currentIndex,
              cartCount: cartCount,
              onTap: (index) {
                switch (index) {
                  case 0: context.go(RoutePaths.shop);
                  case 1: context.go(RoutePaths.cart);
                  case 2: context.go(RoutePaths.orders);
                  case 3: context.go(RoutePaths.loyalty);
                  case 4: context.go(RoutePaths.profile);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom padding screens should reserve so content clears the floating
/// glass tab bar (Pattern 3.2).
const double kGlassNavClearance = 110;
