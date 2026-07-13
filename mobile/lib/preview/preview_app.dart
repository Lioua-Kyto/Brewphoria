// Design-preview harness — renders real screens with sample data and bundled
// asset art so the redesign can be captured without a backend / Firebase.
// Not shipped; excluded from the production entrypoint (main.dart).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:async';
import 'package:coffee_card/core/theme/app_theme.dart';
import 'package:coffee_card/core/widgets/glass_tab_bar.dart';
import 'package:coffee_card/core/widgets/floating_product_card.dart';
import 'package:coffee_card/features/shop/domain/product_model.dart';
import 'package:coffee_card/features/shop/domain/category_model.dart';
import 'package:coffee_card/features/shop/domain/modifier_model.dart';
import 'package:coffee_card/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:coffee_card/features/shop/data/product_remote_datasource.dart';
import 'package:coffee_card/features/shop/presentation/providers/products_provider.dart';
import 'package:coffee_card/features/shop/presentation/providers/product_detail_provider.dart';
import 'package:coffee_card/features/reviews/data/review_remote_datasource.dart';
import 'package:coffee_card/features/shop/presentation/screens/shop_screen.dart';
import 'package:coffee_card/features/shop/presentation/screens/product_detail_screen.dart';
import 'package:coffee_card/features/auth/domain/user_model.dart';
import 'package:coffee_card/features/auth/presentation/providers/auth_provider.dart';
import 'package:coffee_card/features/cart/domain/cart_model.dart';
import 'package:coffee_card/features/cart/domain/cart_item_model.dart';
import 'package:coffee_card/features/cart/presentation/providers/cart_provider.dart';
import 'package:coffee_card/features/cart/presentation/screens/cart_screen.dart';
import 'package:coffee_card/features/loyalty/domain/loyalty_model.dart';
import 'package:coffee_card/features/loyalty/presentation/providers/loyalty_provider.dart';
import 'package:coffee_card/features/profile/domain/profile_model.dart';
import 'package:coffee_card/features/profile/presentation/providers/profile_provider.dart';
import 'package:coffee_card/features/profile/presentation/screens/profile_screen.dart';
import 'package:coffee_card/features/loyalty/data/loyalty_remote_datasource.dart';
import 'package:coffee_card/features/loyalty/presentation/screens/loyalty_screen.dart';
import 'package:coffee_card/features/chatbot/presentation/screens/chatbot_screen.dart';
import 'package:coffee_card/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:coffee_card/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:coffee_card/features/auth/presentation/screens/login_screen.dart';
import 'package:coffee_card/features/reviews/presentation/screens/reviews_screen.dart';
import 'package:coffee_card/features/reviews/domain/review_model.dart';
import 'package:coffee_card/features/checkout/domain/order_model.dart';
import 'package:coffee_card/features/orders/data/orders_remote_datasource.dart';
import 'package:coffee_card/features/orders/presentation/providers/orders_provider.dart';
import 'package:coffee_card/features/orders/presentation/screens/orders_screen.dart';

// ── Sample data ──────────────────────────────────────────────────────────────
const _espresso = CategoryModel(
    id: 'c1', name: 'Espresso & Hot Drinks', slug: 'espresso-hot-drinks');
const _cold = CategoryModel(id: 'c2', name: 'Cold Brew & Iced', slug: 'cold');
const _pastry =
    CategoryModel(id: 'c3', name: 'Pastries & Baked Goods', slug: 'pastries');
const _beans =
    CategoryModel(id: 'c4', name: 'Coffee Beans & Grounds', slug: 'beans');
const _tea = CategoryModel(id: 'c5', name: 'Tea & Alternatives', slug: 'tea');
const _merch = CategoryModel(id: 'c6', name: 'Merchandise', slug: 'merch');

final _sampleCategories = [_espresso, _cold, _pastry, _beans, _tea, _merch];

ProductModel _p(String id, String name, double price, String img, CategoryModel cat,
        {bool featured = false, String desc = '', double rating = 4.7, int reviews = 42}) =>
    ProductModel(
      id: id,
      name: name,
      slug: id,
      description: desc.isEmpty
          ? 'A house favourite, pulled fresh and finished with care.'
          : desc,
      price: price,
      images: ['assets/img/$img'],
      stock: 25,
      isFeatured: featured,
      avgRating: rating,
      reviewCount: reviews,
      category: cat,
      categoryId: cat.id,
    );

ModifierOptionModel _o(String id, String label, double delta,
        {bool isDefault = false}) =>
    ModifierOptionModel(
        id: id, label: label, priceDelta: delta, isDefault: isDefault);

final _sampleGroups = <ModifierGroupModel>[
  ModifierGroupModel(
    id: 'g-size',
    name: 'Size',
    selectionType: 'SINGLE',
    isRequired: true,
    sortOrder: 0,
    options: [
      _o('sz-s', 'Small', -0.40),
      _o('sz-m', 'Medium', 0, isDefault: true),
      _o('sz-l', 'Large', 0.60),
    ],
  ),
  ModifierGroupModel(
    id: 'g-milk',
    name: 'Milk',
    sortOrder: 1,
    options: [
      _o('mk-w', 'Whole', 0, isDefault: true),
      _o('mk-o', 'Oat', 0.60),
      _o('mk-a', 'Almond', 0.60),
      _o('mk-s', 'Skim', 0),
    ],
  ),
  ModifierGroupModel(
    id: 'g-sweet',
    name: 'Sweetness',
    sortOrder: 2,
    options: [
      _o('sw-0', 'No sugar', 0),
      _o('sw-1', 'Light', 0, isDefault: true),
      _o('sw-2', 'Regular', 0),
      _o('sw-3', 'Extra sweet', 0),
    ],
  ),
  ModifierGroupModel(
    id: 'g-add',
    name: 'Add-ons',
    selectionType: 'MULTI',
    sortOrder: 3,
    options: [
      _o('ad-shot', 'Extra espresso shot', 0.80),
      _o('ad-van', 'Vanilla syrup', 0.50),
      _o('ad-car', 'Caramel drizzle', 0.50),
      _o('ad-whip', 'Whipped cream', 0.40),
    ],
  ),
];

final _macchiato = _p('macchiato', 'Caramel Macchiato', 5.40, 'macchiato.png',
        _espresso,
        rating: 4.9,
        reviews: 128,
        desc:
            'Espresso layered over vanilla-sweetened milk, finished with a caramel lattice. Balanced, not too sweet — a house favourite.')
    .copyWith(
  roastLevel: 'Medium',
  calories: 240,
  caffeineMg: 150,
  prepMinutes: 5,
  tastingNotes: ['Caramel', 'Vanilla', 'Toffee'],
  modifierGroups: _sampleGroups,
);

final _sampleProducts = <ProductModel>[
  _p('cappuccino', 'Honey Oat Cappuccino', 5.20, 'cappuccino.png', _espresso,
      featured: true,
      desc: 'Double shot · oat milk · a thread of wildflower honey.'),
  _p('iced-latte', 'Iced Vanilla Latte', 4.80, 'iced-latte.png', _cold),
  _p('nitro', 'Nitro Cold Brew', 4.75, 'nitro.png', _cold),
  _p('macchiato', 'Caramel Macchiato', 5.40, 'macchiato.png', _espresso),
  _p('cinnamon-roll', 'Cinnamon Roll', 3.80, 'cinnamon-roll.png', _pastry),
  _p('croissant', 'Butter Croissant', 3.20, 'croissant.png', _pastry),
  _p('cold-brew', 'Signature Cold Brew', 4.75, 'cold-brew.png', _cold),
  _p('flat-white', 'Flat White', 4.60, 'flat-white.png', _espresso),
];

final _sampleUser = UserModel(
  id: 'u1',
  firebaseUid: 'uid1',
  email: 'maya@brewphoria.co',
  displayName: 'Maya Chen',
  createdAt: DateTime(2025, 1, 1),
);

// Preview notifiers avoid the Firebase / Hive calls the real ones make on build.
class _PreviewAuthNotifier extends AuthNotifier {
  @override
  AsyncValue<UserModel?> build() => AsyncValue.data(_sampleUser);
}

final _sampleCartItems = [
  CartItemModel(id: 'ci1', quantity: 1, product: _macchiato),
  CartItemModel(id: 'ci2', quantity: 2, product: _sampleProducts[2]), // nitro
  CartItemModel(id: 'ci3', quantity: 1, product: _sampleProducts[4]), // cinnamon
];

class _PreviewWishlist extends WishlistNotifier {
  @override
  Future<List<ProductModel>> build() async =>
      [_macchiato, _sampleProducts[2], _sampleProducts[5]];
}

class _PreviewPaginatedProducts extends PaginatedProducts {
  @override
  Future<List<ProductModel>> build() async => _sampleProducts;
}

final _sampleHistory = LoyaltyTransactionsResult(
  transactions: [
    LoyaltyTransactionModel(
        id: 't1',
        type: 'EARNED',
        points: 65,
        description: 'Caramel Macchiato',
        createdAt: DateTime.now().subtract(const Duration(hours: 2))),
    LoyaltyTransactionModel(
        id: 't2',
        type: 'EARNED',
        points: 95,
        description: 'Nitro Cold Brew ×2',
        createdAt: DateTime.now().subtract(const Duration(days: 1))),
    LoyaltyTransactionModel(
        id: 't3',
        type: 'BONUS',
        points: 50,
        description: 'Reached Gold tier',
        createdAt: DateTime.now().subtract(const Duration(days: 3))),
  ],
  total: 3,
  totalPages: 1,
  page: 1,
);

const _sampleAddresses = [
  AddressModel(
    id: 'a1',
    label: 'Home',
    fullName: 'Maya Chen',
    phone: '555-0142',
    street: '24 Maple Street',
    city: 'Brooklyn',
    state: 'NY',
    postalCode: '11201',
    country: 'US',
    isDefault: true,
  ),
  AddressModel(
    id: 'a2',
    label: 'Work',
    fullName: 'Maya Chen',
    phone: '555-0142',
    street: '9 Roasters Ave, Floor 3',
    city: 'Manhattan',
    state: 'NY',
    postalCode: '10013',
    country: 'US',
  ),
];

class _PreviewAddresses extends AddressesNotifier {
  @override
  AsyncValue<List<AddressModel>> build() =>
      const AsyncValue.data(_sampleAddresses);
}

OrderItemModel _oi(String name, String img, double price, int qty) =>
    OrderItemModel(
      id: 'oi-$name',
      productId: name,
      productName: name,
      productImage: 'assets/img/$img',
      unitPrice: price,
      quantity: qty,
      subtotal: price * qty,
    );

OrderModel _order(String id, String status, double total,
        List<OrderItemModel> items, DateTime date,
        {DateTime? estimatedReadyAt}) =>
    OrderModel(
      id: id,
      status: status,
      subtotal: total,
      deliveryFee: 0,
      discount: 0,
      loyaltyDiscount: 0,
      total: total,
      pointsEarned: (total * 10).round(),
      pointsRedeemed: 0,
      paymentMethod: 'COD',
      items: items,
      estimatedReadyAt: estimatedReadyAt,
      createdAt: date,
    );

final _sampleOrders = OrdersListResult(
  orders: [
    _order(
        '2847abcd',
        'PREPARING',
        15.15,
        [
          _oi('Caramel Macchiato', 'macchiato.png', 5.40, 1),
          _oi('Nitro Cold Brew', 'nitro.png', 4.75, 2),
        ],
        DateTime(2026, 7, 9),
        estimatedReadyAt: DateTime.now().add(const Duration(minutes: 9))),
    _order('flatw123', 'DELIVERED', 4.20,
        [_oi('Flat White', 'flat-white.png', 4.20, 1)], DateTime(2026, 7, 6)),
    _order(
        'cinn4567',
        'DELIVERED',
        8.60,
        [
          _oi('Cinnamon Roll', 'cinnamon-roll.png', 3.80, 1),
          _oi('Iced Vanilla Latte', 'iced-latte.png', 4.80, 1),
        ],
        DateTime(2026, 7, 4)),
    _order('esp78901', 'DELIVERED', 3.10,
        [_oi('Double Espresso', 'espresso.png', 3.10, 1)], DateTime(2026, 7, 2)),
  ],
  total: 4,
  totalPages: 1,
  page: 1,
);

class _PreviewCartNotifier extends CartNotifier {
  @override
  AsyncValue<CartModel> build() =>
      (_screen == _Screen.cart || _screen == _Screen.checkout)
          ? AsyncValue.data(CartModel(id: 'local', items: _sampleCartItems))
          : const AsyncValue.data(CartModel(id: 'local', items: []));
}

const _sampleLoyalty = LoyaltyModel(
  id: 'l1',
  currentPoints: 340,
  lifetimePoints: 2100,
  tier: 'GOLD',
);

final _sampleReviews = [
  ReviewModel(
    id: 'r1',
    rating: 5,
    comment:
        "Genuinely the best caramel macchiato I've had from an app order. The oat milk swap is spot on and it wasn't drowning in syrup. My new morning ritual.",
    images: const ['assets/img/macchiato.png'],
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    user: const ReviewUserModel(displayName: 'Maya R.'),
  ),
  ReviewModel(
    id: 'r2',
    rating: 4,
    comment:
        "Really solid. Docked one star only because mine came a touch cooler than I'd like — flavour was excellent though. Would order again.",
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    user: const ReviewUserModel(displayName: 'James T.'),
  ),
  ReviewModel(
    id: 'r3',
    rating: 5,
    comment:
        'The AI barista recommended this and nailed it. Sweet enough without being sugary.',
    createdAt: DateTime.now().subtract(const Duration(days: 14)),
    user: const ReviewUserModel(displayName: 'Sofia L.'),
  ),
];

// Flip this to preview different screens.
const _screen = _Screen.onboarding;

enum _Screen {
  shop,
  productDetail,
  entranceDemo,
  cart,
  checkout,
  orders,
  loyalty,
  profile,
  chat,
  onboarding,
  login,
  reviews
}

void main() {
  runApp(
    ProviderScope(
      overrides: [
        categoriesProvider.overrideWith((ref) async => _sampleCategories),
        productsProvider.overrideWith((ref) async => ProductListResult(
              products: _sampleProducts,
              total: _sampleProducts.length,
              totalPages: 1,
              page: 1,
            )),
        paginatedProductsProvider.overrideWith(_PreviewPaginatedProducts.new),
        productDetailProvider('macchiato').overrideWith((ref) async => _macchiato),
        authNotifierProvider.overrideWith(_PreviewAuthNotifier.new),
        cartNotifierProvider.overrideWith(_PreviewCartNotifier.new),
        loyaltyAccountProvider.overrideWith((ref) async => _sampleLoyalty),
        wishlistNotifierProvider.overrideWith(_PreviewWishlist.new),
        addressesNotifierProvider.overrideWith(_PreviewAddresses.new),
        ordersProvider().overrideWith((ref) async => _sampleOrders),
        userProfileProvider.overrideWith((ref) async => _sampleUser),
        loyaltyHistoryProvider().overrideWith((ref) async => _sampleHistory),
        productReviewsProvider('macchiato')
            .overrideWith((ref) async => _sampleReviews),
        productReviewSummaryProvider('macchiato').overrideWith(
          (ref) async => const ReviewSummary(
            average: 4.6,
            count: 128,
            distribution: {5: 92, 4: 22, 3: 8, 2: 4, 1: 2},
          ),
        ),
      ],
      child: const _PreviewRoot(),
    ),
  );
}

/// Plays the real Shop→Detail transition in slow motion so it can be captured
/// mid-flight: the cutout arcs to the top while the sheet rises from the bottom.
class _EntranceDemo extends StatefulWidget {
  const _EntranceDemo();
  @override
  State<_EntranceDemo> createState() => _EntranceDemoState();
}

class _EntranceDemoState extends State<_EntranceDemo> {
  final _navKey = GlobalKey<NavigatorState>();
  Timer? _timer;

  void _play() {
    _navKey.currentState?.push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 4000),
      reverseTransitionDuration: const Duration(milliseconds: 1500),
      pageBuilder: (_, __, ___) => const ProductDetailScreen(slug: 'macchiato'),
      transitionsBuilder: (context, animation, secondary, child) =>
          FadeTransition(
        opacity:
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: child,
      ),
    ));
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 900), _play);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navKey,
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => _MockShop()),
    );
  }
}

class _MockShop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 340),
              SizedBox(
                width: 172,
                height: 240,
                child: FloatingProductCard(
                  imageUrl: 'assets/img/macchiato.png',
                  name: 'Caramel Macchiato',
                  price: r'$5.40',
                  heroTag: 'product-macchiato',
                  categoryLabel: 'Espresso',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewRoot extends StatefulWidget {
  const _PreviewRoot();
  @override
  State<_PreviewRoot> createState() => _PreviewRootState();
}

class _PreviewRootState extends State<_PreviewRoot> {

  Widget _shell(Widget screen, int index) => Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            Positioned.fill(child: screen),
            Align(
              alignment: Alignment.bottomCenter,
              child: GlassTabBar(
                currentIndex: index,
                cartCount: 4,
                onTap: (_) {},
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(Brightness.light),
      darkTheme: AppTheme.build(Brightness.dark),
      themeMode: ThemeMode.system, // driven by browser prefers-color-scheme
      home: switch (_screen) {
        _Screen.entranceDemo => const _EntranceDemo(),
        _Screen.productDetail =>
          const ProductDetailScreen(slug: 'macchiato'),
        _Screen.cart => _shell(const CartScreen(), 1),
        _Screen.checkout => const CheckoutScreen(tipAmount: 2.81),
        _Screen.orders => _shell(const OrdersScreen(), 2),
        _Screen.loyalty => _shell(const LoyaltyScreen(), 3),
        _Screen.profile => _shell(const ProfileScreen(), 4),
        _Screen.chat => const ChatbotScreen(),
        _Screen.onboarding => const OnboardingScreen(),
        _Screen.login => const LoginScreen(),
        _Screen.reviews => const ReviewsScreen(
            productId: 'macchiato',
            productName: 'Caramel Macchiato',
            avgRating: 4.9,
            reviewCount: 128),
        _Screen.shop => _shell(const ShopScreen(), 0),
      },
    );
  }
}
