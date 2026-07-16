import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brewphoria/core/constants/app_colors.dart';
import 'package:brewphoria/core/constants/app_spacing.dart';
import 'package:brewphoria/core/errors/app_exception.dart';
import 'package:brewphoria/core/constants/app_text_styles.dart';
import 'package:brewphoria/core/router/app_router.dart';
import 'package:brewphoria/core/router/route_names.dart';
import 'package:brewphoria/core/widgets/brew_snack.dart';
import 'package:brewphoria/core/widgets/entrance.dart';
import 'package:brewphoria/core/widgets/fly_to_cart.dart';
import 'package:brewphoria/core/widgets/floating_product_card.dart';
import 'package:brewphoria/core/widgets/product_cutout.dart';
import 'package:brewphoria/core/widgets/pressable.dart';
import 'package:brewphoria/core/widgets/shimmer_widget.dart';
import 'package:brewphoria/core/widgets/app_error_widget.dart';
import 'package:brewphoria/core/utils/extensions.dart';
import 'package:brewphoria/features/shop/presentation/providers/products_provider.dart';
import 'package:brewphoria/features/shop/domain/product_model.dart';
import 'package:brewphoria/features/shop/domain/category_model.dart';
import 'package:brewphoria/features/cart/presentation/providers/cart_provider.dart';
import 'package:brewphoria/features/auth/presentation/providers/auth_provider.dart';
import 'package:brewphoria/features/orders/presentation/providers/orders_provider.dart';
import 'package:brewphoria/features/checkout/domain/order_model.dart';
import 'package:brewphoria/features/notifications/presentation/providers/notifications_provider.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      ref.read(paginatedProductsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addToCart(ProductModel product, GlobalKey sourceKey) async {
    if (product.images.isNotEmpty) {
      await flyToCart(
        context: context,
        sourceKey: sourceKey,
        imageUrl: product.images.first,
      );
    }
    try {
      await ref.read(cartNotifierProvider.notifier).addProduct(product, 1);
      if (!mounted) return;
      showBrewSnack(context, '${product.name} added to your cart',
          icon: Icons.local_cafe_rounded);
    } catch (e) {
      if (!mounted) return;
      showBrewSnack(context, friendlyError(e), kind: BrewSnackKind.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(productFilterNotifierProvider);
    final productsAsync = ref.watch(paginatedProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final lastOrder = user == null
        ? null
        : ref.watch(ordersProvider()).valueOrNull?.orders.firstOrNull;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(paginatedProductsProvider);
          ref.invalidate(categoriesProvider);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    22, MediaQuery.of(context).padding.top + 10, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Header(),
                    const SizedBox(height: 18),
                    _Greeting(name: user?.greetingName ?? 'there'),
                    const SizedBox(height: 16),
                    _SearchRow(controller: _searchController),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            categoriesAsync.when(
              data: (cats) => SliverToBoxAdapter(
                child: _CategoryPills(
                  categories: cats,
                  selectedId: filter.categoryId,
                  onSelected: (id) => ref
                      .read(productFilterNotifierProvider.notifier)
                      .setCategory(id),
                ),
              ),
              loading: () => const SliverToBoxAdapter(child: _PillsSkeleton()),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
            ),
            if (lastOrder != null && lastOrder.items.isNotEmpty) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 18)),
              SliverToBoxAdapter(child: _OrderAgainCard(order: lastOrder)),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            productsAsync.when(
              data: (products) => products.isEmpty
                  ? _EmptyResults(
                      onClear: () {
                        _searchController.clear();
                        ref
                            .read(productFilterNotifierProvider.notifier)
                            .setSearch(null);
                      },
                    )
                  : _Bento(
                      products: products,
                      onAdd: _addToCart,
                    ),
              loading: () => const _BentoSkeleton(),
              error: (e, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: AppErrorWidget(
                  message: friendlyError(e),
                  onRetry: () => ref.invalidate(paginatedProductsProvider),
                ),
              ),
            ),
            if (productsAsync.hasValue &&
                ref.watch(paginatedProductsProvider.notifier).hasMore)
              const SliverToBoxAdapter(child: _LoadMoreIndicator()),
            const SliverToBoxAdapter(
                child: SizedBox(height: kGlassNavClearance)),
          ],
        ),
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────
class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unread = ref
            .watch(notificationsNotifierProvider)
            .valueOrNull
            ?.where((n) => !n.isRead)
            .length ??
        0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('BrewPhoria',
            style: AppTextStyles.wordmark(24,
                color: isDark
                    ? AppColors.onBackgroundDark
                    : AppColors.onBackground)),
        Row(
          children: [
            _HeaderIconButton(
              semanticLabel: 'Notifications',
              onTap: () => context.pushNamed(RouteNames.notifications),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 21,
                      color: isDark
                          ? AppColors.onSurfaceDark
                          : AppColors.onSurface),
                  if (unread > 0)
                    Positioned(
                      top: -1,
                      right: -1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.surface,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // AI Barista entry (profile lives in the nav bar).
            Semantics(
              button: true,
              label: 'Ask the AI barista',
              child: Pressable(
              onTap: () => context.pushNamed(RouteNames.chat),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE7C173), Color(0xFFB8863C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3)),
                  ],
                ),
                // Same gold steam-cup glyph as the barista mark used in chat /
                // product detail, for a consistent AI-barista identity.
                child: const Icon(Icons.local_cafe_rounded,
                    size: 20, color: Colors.white),
              ),
            ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton(
      {required this.child, required this.onTap, this.semanticLabel});
  final Widget child;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Pressable(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: isDark ? Border.all(color: AppColors.amberBorderDark) : null,
          boxShadow: isDark ? null : AppColors.cardShadow,
        ),
        child: Center(child: child),
      ),
    ),
    );
  }
}

// ── Greeting ─────────────────────────────────────────────────────────────────
class _Greeting extends StatelessWidget {
  const _Greeting({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final (part, sub) = switch (hour) {
      < 12 => ('morning', 'A cortado kind of day?'),
      < 17 => ('afternoon', 'Time for an afternoon pick-me-up.'),
      _ => ('evening', 'A nightcap cold brew, maybe?'),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good $part, $name.',
          style: AppTextStyles.displayMedium.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 5),
        Text(sub,
            style: AppTextStyles.bodyMedium
                .copyWith(fontSize: 14.5, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ── Search + filter ──────────────────────────────────────────────────────────
class _SearchRow extends ConsumerStatefulWidget {
  const _SearchRow({required this.controller});
  final TextEditingController controller;

  @override
  ConsumerState<_SearchRow> createState() => _SearchRowState();
}

class _SearchRowState extends ConsumerState<_SearchRow> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String v) {
    setState(() {}); // refresh the clear button
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final q = v.trim();
      ref
          .read(productFilterNotifierProvider.notifier)
          .setSearch(q.isEmpty ? null : q);
    });
  }

  void _clear() {
    _debounce?.cancel();
    widget.controller.clear();
    ref.read(productFilterNotifierProvider.notifier).setSearch(null);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border:
                  isDark ? Border.all(color: AppColors.outlineDark) : null,
              boxShadow: isDark
                  ? null
                  : const [
                      BoxShadow(
                          color: Color(0x123B2417),
                          blurRadius: 12,
                          offset: Offset(0, 3)),
                    ],
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    size: 20, color: AppColors.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: _onChanged,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 14.5),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      hintText: 'Search coffee, pastries…',
                      hintStyle: AppTextStyles.bodyMedium
                          .copyWith(fontSize: 14.5, color: AppColors.textMuted),
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: _clear,
                    child: Icon(Icons.close_rounded,
                        size: 18, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Semantics(
          button: true,
          label: 'Filter and sort',
          child: Pressable(
            onTap: () => _openFilterSheet(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  ),
                  child: Icon(Icons.tune_rounded,
                      size: 20,
                      color:
                          isDark ? AppColors.onPrimaryDark : AppColors.onPrimary),
                ),
                if (ref.watch(productFilterNotifierProvider).hasActiveFilters)
                  Positioned(
                    right: -1,
                    top: -1,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: isDark
                                ? AppColors.backgroundDark
                                : AppColors.background,
                            width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FilterSheet(),
    );
  }
}

// ── Filter & sort sheet ──────────────────────────────────────────────────────
const _kPriceCeiling = 60.0;
const _sortOptions = <(String, String)>[
  ('newest', 'Newest'),
  ('price_asc', 'Price: Low to High'),
  ('price_desc', 'Price: High to Low'),
  ('rating', 'Top rated'),
];

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late String _sort;
  late RangeValues _price;

  @override
  void initState() {
    super.initState();
    final f = ref.read(productFilterNotifierProvider);
    _sort = f.sort ?? 'newest';
    _price = RangeValues(
      f.minPrice ?? 0,
      f.maxPrice ?? _kPriceCeiling,
    );
  }

  void _apply() {
    final hasPrice = _price.start > 0 || _price.end < _kPriceCeiling;
    ref.read(productFilterNotifierProvider.notifier).applyRefinements(
          sort: _sort == 'newest' ? null : _sort,
          minPrice: hasPrice ? _price.start : null,
          maxPrice: hasPrice ? _price.end : null,
        );
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _sort = 'newest';
      _price = const RangeValues(0, _kPriceCeiling);
    });
    ref
        .read(productFilterNotifierProvider.notifier)
        .applyRefinements(sort: null, minPrice: null, maxPrice: null);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 26),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Filter & sort',
                    style: GoogleFonts.fraunces(
                        fontSize: 21, fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton(
                  onPressed: _reset,
                  child: Text('Reset',
                      style: GoogleFonts.hankenGrotesk(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('SORT BY',
                style: AppTextStyles.overline
                    .copyWith(fontSize: 10.5, letterSpacing: 1.6)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (value, label) in _sortOptions)
                  _ChoiceChip(
                    label: label,
                    selected: _sort == value,
                    onTap: () => setState(() => _sort = value),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Text('PRICE RANGE',
                    style: AppTextStyles.overline
                        .copyWith(fontSize: 10.5, letterSpacing: 1.6)),
                const Spacer(),
                Text(
                  '\$${_price.start.round()} – \$${_price.end.round()}'
                  '${_price.end >= _kPriceCeiling ? '+' : ''}',
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary),
                ),
              ],
            ),
            RangeSlider(
              values: _price,
              min: 0,
              max: _kPriceCeiling,
              divisions: 24,
              activeColor: AppColors.secondary,
              inactiveColor: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariant,
              labels: RangeLabels(
                '\$${_price.start.round()}',
                '\$${_price.end.round()}',
              ),
              onChanged: (v) => setState(() => _price = v),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _apply,
                child: const Text('Show results'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondary
              : (isDark ? AppColors.surfaceDark : AppColors.surface),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: selected
                ? AppColors.secondary
                : (isDark ? AppColors.amberBorderDark : const Color(0x1A3B2417)),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.hankenGrotesk(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : (isDark ? AppColors.onSurfaceDark : AppColors.onSurface),
          ),
        ),
      ),
    );
  }
}

// ── Category pills ───────────────────────────────────────────────────────────
class _CategoryPills extends StatelessWidget {
  const _CategoryPills({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CategoryModel> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  String _short(String name) => name.split(' & ').first;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _Pill(
              label: 'All',
              selected: selectedId == null,
              onTap: () => onSelected(null),
            );
          }
          final cat = categories[index - 1];
          return _Pill(
            label: _short(cat.name),
            selected: selectedId == cat.id,
            onTap: () => onSelected(cat.id),
          );
        },
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg;
    final Color fg;
    if (selected) {
      bg = isDark ? AppColors.primaryDark : AppColors.primary;
      fg = isDark ? AppColors.onPrimaryDark : AppColors.onPrimary;
    } else {
      bg = isDark ? AppColors.surfaceDark : AppColors.surface;
      fg = isDark ? const Color(0xFFC9B7A3) : const Color(0xFF5C4A3A);
    }
    return Pressable(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 17),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          boxShadow: (!selected && !isDark)
              ? const [
                  BoxShadow(
                      color: Color(0x0F3B2417),
                      blurRadius: 8,
                      offset: Offset(0, 2))
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.hankenGrotesk(
              fontSize: 13.5, fontWeight: FontWeight.w600, color: fg),
        ),
      ),
    );
  }
}

// ── Bento layout ─────────────────────────────────────────────────────────────
class _Bento extends StatelessWidget {
  const _Bento({required this.products, required this.onAdd});

  final List<ProductModel> products;
  final Future<void> Function(ProductModel, GlobalKey) onAdd;

  @override
  Widget build(BuildContext context) {
    final featured =
        products.firstWhere((p) => p.isFeatured, orElse: () => products.first);
    final rest = products.where((p) => p.id != featured.id).toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: _FeaturedTile(product: featured, onAdd: onAdd),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.70,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = rest[index];
                final imgKey = GlobalKey();
                // Stagger the first screenful; later items (and paginated
                // appends) settle quickly so scrolling never feels gated.
                return Entrance(
                  delay: Duration(milliseconds: (index.clamp(0, 7)) * 55),
                  playOnceId: 'shop-${product.id}',
                  child: FloatingProductCard(
                    imageUrl:
                        product.images.isNotEmpty ? product.images.first : '',
                    name: product.name,
                    price: product.price.toCurrency,
                    heroTag: 'product-${product.slug}',
                    categoryLabel: product.category?.name.split(' & ').first,
                    imageKey: imgKey,
                    onTap: () => context.pushNamed(
                      RouteNames.productDetail,
                      pathParameters: {'slug': product.slug},
                    ),
                    onAdd: () => onAdd(product, imgKey),
                  ),
                );
              },
              childCount: rest.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          const SliverToBoxAdapter(child: _PromoTile()),
        ],
      ),
    );
  }
}

/// Quick "order again" strip for returning customers — one tap re-adds the
/// most recent order to the cart.
class _OrderAgainCard extends ConsumerWidget {
  const _OrderAgainCard({required this.order});
  final OrderModel order;

  Future<void> _reorder(BuildContext context, WidgetRef ref) async {
    try {
      for (final item in order.items) {
        await ref.read(cartNotifierProvider.notifier).addItem(
              item.productId,
              item.quantity,
              modifiers: item.modifiers.map((m) => m.optionId).toList(),
            );
      }
      if (context.mounted) {
        showBrewSnack(context, 'Your usual is back in the cart',
            icon: Icons.local_cafe_rounded);
      }
    } catch (e) {
      if (context.mounted) {
        showBrewSnack(context, friendlyError(e), kind: BrewSnackKind.error);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summary = order.items
        .map((i) =>
            i.quantity > 1 ? '${i.productName} ×${i.quantity}' : i.productName)
        .join(' · ');
    final firstImage =
        order.items.isNotEmpty ? order.items.first.productImage : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceGlowDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: isDark ? Border.all(color: AppColors.amberBorderDark) : null,
          boxShadow: isDark ? null : AppColors.cardShadow,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: firstImage.isEmpty
                  ? const SizedBox.shrink()
                  : ProductCutout(url: firstImage, decodeWidth: 160),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ORDER AGAIN',
                      style: AppTextStyles.overline
                          .copyWith(fontSize: 9.5, letterSpacing: 1.6)),
                  const SizedBox(height: 2),
                  Text(
                    summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.onSurfaceDark
                          : AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Pressable(
              onTap: () => _reorder(context, ref),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.replay_rounded,
                        size: 16,
                        color: isDark
                            ? AppColors.onPrimaryDark
                            : AppColors.onPrimary),
                    const SizedBox(width: 6),
                    Text('Reorder',
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.onPrimaryDark
                                : AppColors.onPrimary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Translates its child vertically as the featured tile scrolls through the
/// viewport, giving the hero image a slow parallax drift (one motion moment).
class _ParallaxImage extends StatelessWidget {
  const _ParallaxImage({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) return child;
    return AnimatedBuilder(
      animation: scrollable.position,
      builder: (context, inner) {
        double dy = 0;
        final box = context.findRenderObject() as RenderBox?;
        final viewport = scrollable.context.findRenderObject() as RenderBox?;
        if (box != null && box.attached && viewport != null) {
          final centerY = box
                  .localToGlobal(box.size.center(Offset.zero), ancestor: viewport)
                  .dy;
          final frac = (centerY / viewport.size.height).clamp(0.0, 1.0);
          dy = (frac - 0.5) * 44; // ±22px drift, top→bottom
        }
        return Transform.translate(offset: Offset(0, dy), child: inner);
      },
      child: child,
    );
  }
}

class _FeaturedTile extends StatelessWidget {
  const _FeaturedTile({required this.product, required this.onAdd});
  final ProductModel product;
  final Future<void> Function(ProductModel, GlobalKey) onAdd;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imgKey = GlobalKey();
    return GestureDetector(
      onTap: () => context.pushNamed(
        RouteNames.productDetail,
        pathParameters: {'slug': product.slug},
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 176),
        padding: const EdgeInsets.all(20),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceGlowDark : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
          border:
              isDark ? Border.all(color: AppColors.amberBorderDark) : null,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0x66000000)
                  : const Color(0x383B2417),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // watermark numeral
            Positioned(
              right: -8,
              bottom: -34,
              child: Text(
                '01',
                style: GoogleFonts.fraunces(
                  fontSize: 120,
                  height: 1,
                  fontStyle: FontStyle.italic,
                  color: AppColors.secondary.withValues(alpha: 0.09),
                ),
              ),
            ),
            // floating product image (right)
            Positioned(
              right: -16,
              top: 0,
              bottom: 0,
              child: Center(
                child: SizedBox(
                  key: imgKey,
                  width: 168,
                  height: 168,
                  child: product.images.isNotEmpty
                      ? _ParallaxImage(
                          child: Hero(
                            tag: 'product-${product.slug}',
                            createRectTween: (a, b) =>
                                MaterialRectArcTween(begin: a, end: b),
                            child: ProductCutout(
                              url: product.images.first,
                              decodeWidth: 400,
                              shadowColor: const Color(0x66000000),
                              shadowOffset: const Offset(0, 20),
                              shadowBlur: 20,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
            // content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('FEATURED TODAY',
                    style: AppTextStyles.overline
                        .copyWith(fontSize: 10.5, letterSpacing: 1.9)),
                const SizedBox(height: 8),
                SizedBox(
                  width: 180,
                  child: Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fraunces(
                      fontSize: 23,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                      color: AppColors.onBackgroundDark,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                SizedBox(
                  width: 190,
                  child: Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 12.5,
                      height: 1.5,
                      color: const Color(0xFFC9B7A3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      product.price.toCurrency,
                      style: GoogleFonts.fraunces(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onBackgroundDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Pressable(
                      onTap: () => onAdd(product, imgKey),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Add',
                                style: GoogleFonts.hankenGrotesk(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF241812))),
                            const SizedBox(width: 5),
                            const Icon(Icons.add,
                                size: 16, color: Color(0xFF241812)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoTile extends StatelessWidget {
  const _PromoTile();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : const LinearGradient(
                colors: [Color(0xFFF6E7D2), Color(0xFFF1DABB)],
                begin: Alignment(-0.7, -1),
                end: Alignment(0.7, 1),
              ),
        color: isDark ? AppColors.secondary.withValues(alpha: 0.13) : null,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.32)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.local_cafe_rounded,
                size: 22, color: Color(0xFF241812)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Free oat milk upgrade',
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.onBackgroundDark
                            : AppColors.onBackground)),
                const SizedBox(height: 1),
                Text('This week only · tap to apply',
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFFB89A78)
                            : const Color(0xFF8A6A45))),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded,
              size: 18, color: Color(0xFFB87423)),
        ],
      ),
    );
  }
}

// ── Empty results ────────────────────────────────────────────────────────────
class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.onClear});
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 40, 40, 120),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded,
                  size: 42, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Text('Nothing brewing here',
                style: AppTextStyles.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'We couldn’t find anything matching your search. Try a different roast.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 180,
              child: OutlinedButton(
                  onPressed: onClear, child: const Text('Clear search')),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeletons ────────────────────────────────────────────────────────────────
class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 22),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
              strokeWidth: 2.4, color: AppColors.secondary),
        ),
      ),
    );
  }
}

class _PillsSkeleton extends StatelessWidget {
  const _PillsSkeleton();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (_, i) => ShimmerWidget(
            width: i == 0 ? 56 : 78, height: 38, borderRadius: 100),
      ),
    );
  }
}

class _BentoSkeleton extends StatelessWidget {
  const _BentoSkeleton();
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      sliver: SliverList.list(children: [
        ShimmerWidget(width: double.infinity, height: 176, borderRadius: 24),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(top: 38),
                    child: ShimmerWidget(
                        width: double.infinity,
                        height: 170,
                        borderRadius: 22))),
            const SizedBox(width: 14),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(top: 38),
                    child: ShimmerWidget(
                        width: double.infinity,
                        height: 170,
                        borderRadius: 22))),
          ],
        ),
      ]),
    );
  }
}
