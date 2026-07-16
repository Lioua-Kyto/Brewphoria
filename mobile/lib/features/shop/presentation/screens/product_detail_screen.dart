import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brewphoria/core/constants/app_colors.dart';
import 'package:brewphoria/core/errors/app_exception.dart';
import 'package:brewphoria/core/constants/app_spacing.dart';
import 'package:brewphoria/core/constants/app_text_styles.dart';
import 'package:brewphoria/core/router/route_names.dart';
import 'package:brewphoria/core/widgets/app_error_widget.dart';
import 'package:brewphoria/core/widgets/auth_gate.dart';
import 'package:brewphoria/core/widgets/brew_snack.dart';
import 'package:brewphoria/core/widgets/coffee_cup.dart';
import 'package:brewphoria/core/widgets/product_cutout.dart';
import 'package:brewphoria/core/widgets/pressable.dart';
import 'package:brewphoria/core/utils/extensions.dart';
import 'package:brewphoria/features/shop/domain/product_model.dart';
import 'package:brewphoria/features/shop/domain/modifier_model.dart';
import 'package:brewphoria/features/shop/presentation/providers/product_detail_provider.dart';
import 'package:brewphoria/features/cart/presentation/providers/cart_provider.dart';
import 'package:brewphoria/features/wishlist/presentation/providers/wishlist_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({required this.slug, super.key});

  final String slug;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  // groupId -> selected optionIds
  final Map<String, Set<String>> _selected = {};
  bool _initialized = false;
  bool _adding = false;

  void _ensureDefaults(ProductModel p) {
    if (_initialized) return;
    _initialized = true;
    for (final g in p.modifierGroups) {
      final defaults =
          g.options.where((o) => o.isDefault).map((o) => o.id).toSet();
      if (g.isMulti) {
        _selected[g.id] = defaults;
      } else if (defaults.isNotEmpty) {
        _selected[g.id] = {defaults.first};
      } else if (g.isRequired && g.options.isNotEmpty) {
        _selected[g.id] = {g.options.first.id};
      } else {
        _selected[g.id] = {};
      }
    }
  }

  void _onSelect(String groupId, String optionId, bool isMulti) {
    setState(() {
      final set = _selected.putIfAbsent(groupId, () => <String>{});
      if (isMulti) {
        set.contains(optionId) ? set.remove(optionId) : set.add(optionId);
      } else {
        _selected[groupId] = {optionId};
      }
    });
  }

  List<String> get _selectedOptionIds =>
      _selected.values.expand((s) => s).toList();

  double _computeUnit(ProductModel p) {
    var price = p.price;
    for (final g in p.modifierGroups) {
      final sel = _selected[g.id] ?? const <String>{};
      for (final o in g.options) {
        if (sel.contains(o.id)) price += o.priceDelta;
      }
    }
    return price;
  }

  Future<void> _addToCart(ProductModel product) async {
    setState(() => _adding = true);
    try {
      await ref
          .read(cartNotifierProvider.notifier)
          .addProduct(product, _quantity, modifiers: _selectedOptionIds);
      if (mounted) {
        showBrewSnack(context, '${product.name} added to your cart',
            icon: Icons.local_cafe_rounded);
      }
    } catch (e) {
      if (mounted) {
        showBrewSnack(context, friendlyError(e), kind: BrewSnackKind.error);
      }
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.slug));
    final wishlistIds = ref.watch(wishlistIdsProvider);
    return Scaffold(
      body: productAsync.when(
        data: (product) {
          _ensureDefaults(product);
          if (product.stock <= 0) return _SoldOutView(product: product);
          return _DetailView(
            product: product,
            quantity: _quantity,
            selected: _selected,
            wishlisted: wishlistIds.contains(product.id),
            adding: _adding,
            unitPrice: _computeUnit(product),
            onQty: (v) => setState(() => _quantity = v),
            onSelect: _onSelect,
            onWishlist: () async {
              if (!await requireAccount(context, ref,
                  action: 'save favourites')) {
                return;
              }
              final nowSaved = !wishlistIds.contains(product.id);
              HapticFeedback.lightImpact();
              try {
                await ref
                    .read(wishlistNotifierProvider.notifier)
                    .toggle(product.id);
                if (context.mounted) {
                  showBrewSnack(
                    context,
                    nowSaved
                        ? 'Saved to your favourites'
                        : 'Removed from favourites',
                    icon: nowSaved
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    kind: BrewSnackKind.info,
                  );
                }
              } catch (_) {}
            },
            onAdd: () => _addToCart(product),
          );
        },
        loading: () => const _DetailSkeleton(),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: AppErrorWidget(
            message: friendlyError(e),
            onRetry: () => ref.invalidate(productDetailProvider(widget.slug)),
          ),
        ),
      ),
    );
  }
}

// ── Populated detail ─────────────────────────────────────────────────────────
class _DetailView extends StatelessWidget {
  const _DetailView({
    required this.product,
    required this.quantity,
    required this.selected,
    required this.wishlisted,
    required this.adding,
    required this.unitPrice,
    required this.onQty,
    required this.onSelect,
    required this.onWishlist,
    required this.onAdd,
  });

  final ProductModel product;
  final int quantity;
  final Map<String, Set<String>> selected;
  final bool wishlisted;
  final bool adding;
  final double unitPrice;
  final ValueChanged<int> onQty;
  final void Function(String groupId, String optionId, bool isMulti) onSelect;
  final VoidCallback onWishlist;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = unitPrice * quantity;
    final points = (unitPrice * quantity * 10).floor();
    final topInset = MediaQuery.of(context).padding.top;

    // Coordinated entrance driven off the route push animation: the detail
    // sheet rises from the bottom + fades while the hero image flies in, the
    // glass controls fade, and the add-bar lifts up last. Reduced-motion →
    // everything is already settled (kAlwaysCompleteAnimation).
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final routeAnim = reduceMotion
        ? kAlwaysCompleteAnimation
        : (ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation);
    final sheetSlide = Tween<Offset>(
      begin: const Offset(0, 0.16),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: routeAnim,
      curve: const Interval(0.05, 1, curve: Curves.easeOutCubic),
      reverseCurve: Curves.easeInCubic,
    ));
    final contentFade = CurvedAnimation(
      parent: routeAnim,
      curve: const Interval(0.12, 1, curve: Curves.easeOut),
    );
    final barSlide = Tween<Offset>(
      begin: const Offset(0, 1.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: routeAnim,
      curve: const Interval(0.28, 1, curve: Curves.easeOutBack),
      reverseCurve: Curves.easeIn,
    ));
    final controlsFade = CurvedAnimation(
      parent: routeAnim,
      curve: const Interval(0.3, 1, curve: Curves.easeOut),
    );

    return Stack(
      children: [
        // Hero zone (fixed behind the scrolling sheet)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 432,
          child: _HeroZone(product: product),
        ),
        // Scrolling content
        Positioned.fill(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Sheet starts lower so the product photo reads large on open;
                // the card shows minimal info at rest and reveals options on scroll.
                const SizedBox(height: 398),
                SlideTransition(
                  position: sheetSlide,
                  child: FadeTransition(
                    opacity: contentFade,
                    child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.background,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? AppColors.onBackgroundDark
                                    : AppColors.onBackground)
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _overline(product),
                        style: AppTextStyles.overline.copyWith(letterSpacing: 1.8),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: GoogleFonts.fraunces(
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                                height: 1.06,
                                letterSpacing: -0.3,
                                color: isDark
                                    ? AppColors.onBackgroundDark
                                    : AppColors.onBackground,
                              ),
                            ),
                          ),
                          if (product.avgRating > 0) ...[
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => context.pushNamed(
                                RouteNames.reviews,
                                pathParameters: {'id': product.id},
                                extra: {
                                  'name': product.name,
                                  'avgRating': product.avgRating,
                                  'reviewCount': product.reviewCount,
                                },
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded,
                                          size: 16, color: AppColors.secondary),
                                      const SizedBox(width: 3),
                                      Text(product.avgRating.toStringAsFixed(1),
                                          style: GoogleFonts.hankenGrotesk(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('${product.reviewCount} reviews',
                                          style: AppTextStyles.captionText),
                                      const Icon(Icons.chevron_right_rounded,
                                          size: 14,
                                          color: AppColors.textMuted),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (product.calories != null ||
                          product.caffeineMg != null ||
                          product.prepMinutes != null) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            if (product.calories != null)
                              _StatChip(
                                  label: 'Calories',
                                  value: '${product.calories} kcal'),
                            if (product.caffeineMg != null) ...[
                              const SizedBox(width: 8),
                              _StatChip(
                                  label: 'Caffeine',
                                  value: '${product.caffeineMg} mg'),
                            ],
                            if (product.prepMinutes != null) ...[
                              const SizedBox(width: 8),
                              _StatChip(
                                  label: 'Ready in',
                                  value: '${product.prepMinutes} min'),
                            ],
                          ],
                        ),
                      ],
                      if (product.roastLevel != null) ...[
                        const SizedBox(height: 16),
                        _RoastMeter(level: product.roastLevel!),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        product.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                            height: 1.6, color: AppColors.textSecondary),
                      ),
                      if (product.tastingNotes.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final note in product.tastingNotes)
                              _NoteChip(note),
                          ],
                        ),
                      ],
                      for (final group in product.modifierGroups)
                        _ModifierGroupSection(
                          group: group,
                          selected: selected[group.id] ?? const <String>{},
                          onSelect: (optionId) =>
                              onSelect(group.id, optionId, group.isMulti),
                        ),
                      const SizedBox(height: 22),
                      _PointsPreview(points: points),
                    ],
                  ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Top controls
        Positioned(
          top: topInset + 8,
          left: 20,
          child: FadeTransition(
            opacity: controlsFade,
            child: _GlassCircleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              semanticLabel: 'Back',
              onTap: () => context.pop(),
            ),
          ),
        ),
        Positioned(
          top: topInset + 8,
          right: 20,
          child: FadeTransition(
            opacity: controlsFade,
            child: _GlassCircleButton(
              icon: wishlisted
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              iconColor: AppColors.secondary,
              semanticLabel:
                  wishlisted ? 'Remove from favourites' : 'Save to favourites',
              onTap: onWishlist,
            ),
          ),
        ),
        // Sticky glass add bar
        Positioned(
          left: 16,
          right: 16,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SlideTransition(
                position: barSlide,
                child: FadeTransition(
                  opacity: controlsFade,
                  child: _StickyAddBar(
                    quantity: quantity,
                    total: total,
                    adding: adding,
                    onQty: onQty,
                    onAdd: onAdd,
                    maxQty: product.stock,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _overline(ProductModel p) {
    final cat = p.category?.name ?? 'BrewPhoria';
    if (p.roastLevel != null) return '$cat · ${p.roastLevel} Roast';
    return cat;
  }
}

class _HeroZone extends StatelessWidget {
  const _HeroZone({required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.55),
          radius: 1.1,
          colors: isDark
              ? const [Color(0xFF33241A), Color(0xFF251811), Color(0xFF1C130D)]
              : const [Color(0xFFFBF4EA), Color(0xFFEFE3D2), Color(0xFFE7D9C4)],
          stops: const [0, 0.62, 1],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft warm spotlight directly behind the product — code-drawn, no
          // image asset — so it reads as gently lit and floating. The extra
          // gradient stops keep the falloff smooth (no visible banding) on the
          // dark espresso background.
          Padding(
            padding: const EdgeInsets.only(top: 44),
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? const [
                          Color(0x40D98E32),
                          Color(0x26D98E32),
                          Color(0x0DD98E32),
                          Color(0x00D98E32),
                        ]
                      : const [
                          Color(0xFFFFFBF3),
                          Color(0x80FFFBF3),
                          Color(0x1AFFFBF3),
                          Color(0x00FFFBF3),
                        ],
                  stops: const [0.0, 0.42, 0.7, 1.0],
                ),
              ),
            ),
          ),
          if (product.images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: SizedBox(
                height: 320,
                child: Hero(
                  tag: 'product-${product.slug}',
                  createRectTween: (a, b) =>
                      MaterialRectArcTween(begin: a, end: b),
                  child: ProductCutout(
                    url: product.images.first,
                    shadowColor: isDark
                        ? const Color(0x57D98E32)
                        : const Color(0x573B2417),
                    shadowOffset: const Offset(0, 30),
                    shadowBlur: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A five-bean roast meter (design §2) — fills beans to match the roast level.
class _RoastMeter extends StatelessWidget {
  const _RoastMeter({required this.level});
  final String level;

  int get _filled {
    final l = level.toLowerCase();
    if (l.contains('medium-dark') || l.contains('medium dark')) return 4;
    if (l.contains('extra') || l.contains('french') || l.contains('dark')) {
      return 5;
    }
    if (l.contains('medium')) return 3;
    if (l.contains('light') || l.contains('blonde')) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('ROAST',
            style: AppTextStyles.overline
                .copyWith(fontSize: 10, letterSpacing: 1.6)),
        const SizedBox(width: 12),
        for (var i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _BeanIcon(filled: i < _filled),
          ),
        const SizedBox(width: 8),
        Text(level,
            style: GoogleFonts.hankenGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary)),
      ],
    );
  }
}

class _BeanIcon extends StatelessWidget {
  const _BeanIcon({required this.filled});
  final bool filled;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(16, 12), painter: _BeanPainter(filled));
}

class _BeanPainter extends CustomPainter {
  _BeanPainter(this.filled);
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.5);
    final rect = Rect.fromCenter(
        center: Offset.zero, width: size.width, height: size.height * 0.74);
    final body = Paint()
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = filled
          ? AppColors.secondary
          : AppColors.textMuted.withValues(alpha: 0.45);
    canvas.drawOval(rect, body);
    final seam = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = filled
          ? Colors.white.withValues(alpha: 0.75)
          : AppColors.textMuted.withValues(alpha: 0.45);
    final path = Path()
      ..moveTo(-rect.width * 0.30, -rect.height * 0.22)
      ..quadraticBezierTo(0, 0, rect.width * 0.30, rect.height * 0.22);
    canvas.drawPath(path, seam);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BeanPainter old) => old.filled != filled;
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceGlowDark : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isDark ? null : AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.captionText
                    .copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 1),
            Text(value,
                style: GoogleFonts.hankenGrotesk(
                    fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _NoteChip extends StatelessWidget {
  const _NoteChip(this.note);
  final String note;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(note,
          style: GoogleFonts.hankenGrotesk(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.secondary : const Color(0xFFB87423))),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(title,
          style: GoogleFonts.fraunces(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface)),
    );
  }
}

class _ModifierGroupSection extends StatelessWidget {
  const _ModifierGroupSection({
    required this.group,
    required this.selected,
    required this.onSelect,
  });
  final ModifierGroupModel group;
  final Set<String> selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(group.name),
        if (group.isMulti)
          _MultiOptions(
              options: group.options, selected: selected, onSelect: onSelect)
        else if (group.options.length <= 3)
          _SegmentedOptions(
              options: group.options, selected: selected, onSelect: onSelect)
        else
          _PillOptions(
              options: group.options, selected: selected, onSelect: onSelect),
      ],
    );
  }
}

class _SegmentedOptions extends StatelessWidget {
  const _SegmentedOptions(
      {required this.options, required this.selected, required this.onSelect});
  final List<ModifierOptionModel> options;
  final Set<String> selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceGlowDark : const Color(0xFFEDE3D5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: Pressable(
                onTap: () => onSelect(o.id),
                scale: 0.97,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected.contains(o.id)
                        ? (isDark ? AppColors.primaryDark : AppColors.surface)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: selected.contains(o.id) && !isDark
                        ? const [
                            BoxShadow(
                                color: Color(0x143B2417),
                                blurRadius: 8,
                                offset: Offset(0, 2))
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    o.label,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected.contains(o.id)
                          ? (isDark
                              ? AppColors.onPrimaryDark
                              : AppColors.onBackground)
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PillOptions extends StatelessWidget {
  const _PillOptions(
      {required this.options, required this.selected, required this.onSelect});
  final List<ModifierOptionModel> options;
  final Set<String> selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Even two-column grid so options line up cleanly instead of a ragged wrap
    // with an orphan on the last row.
    const spacing = 10.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final o in options)
              SizedBox(
                width: cellWidth,
                child: Pressable(
                  onTap: () => onSelect(o.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected.contains(o.id)
                          ? AppColors.secondary
                          : (isDark ? Colors.transparent : AppColors.surface),
                      borderRadius: BorderRadius.circular(14),
                      border: selected.contains(o.id)
                          ? null
                          : Border.all(
                              color: isDark
                                  ? AppColors.outlineDark
                                  : AppColors.outline),
                    ),
                    child: Text(
                      o.priceDelta > 0
                          ? '${o.label}  +\$${o.priceDelta.toStringAsFixed(2)}'
                          : o.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: selected.contains(o.id)
                            ? const Color(0xFF241812)
                            : (isDark
                                ? const Color(0xFFC9B7A3)
                                : AppColors.onBackground),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MultiOptions extends StatelessWidget {
  const _MultiOptions(
      {required this.options, required this.selected, required this.onSelect});
  final List<ModifierOptionModel> options;
  final Set<String> selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        for (final o in options)
          Pressable(
            onTap: () => onSelect(o.id),
            scale: 0.99,
            child: Container(
              margin: const EdgeInsets.only(bottom: 9),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceGlowDark : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: selected.contains(o.id)
                          ? AppColors.secondary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: selected.contains(o.id)
                          ? null
                          : Border.all(
                              color: (isDark
                                      ? AppColors.onBackgroundDark
                                      : AppColors.onBackground)
                                  .withValues(alpha: 0.3),
                              width: 1.5),
                    ),
                    child: selected.contains(o.id)
                        ? const Icon(Icons.check_rounded,
                            size: 16, color: Color(0xFF241812))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(o.label,
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 14.5, fontWeight: FontWeight.w500)),
                  ),
                  if (o.priceDelta > 0)
                    Text('+\$${o.priceDelta.toStringAsFixed(2)}',
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.secondary
                                : const Color(0xFFB87423))),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PointsPreview extends StatelessWidget {
  const _PointsPreview({required this.points});
  final int points;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : const LinearGradient(
                colors: [Color(0xFF3B2417), Color(0xFF4A2E1B)],
                begin: Alignment(-0.8, -1),
                end: Alignment(0.8, 1),
              ),
        color: isDark ? AppColors.surfaceGlowDark : null,
        border: isDark
            ? Border.all(color: AppColors.secondary.withValues(alpha: 0.2))
            : null,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CoffeeCup(fill: 0.81, width: 52, height: 74, glow: true),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("You'll earn +$points pts",
                    style: GoogleFonts.fraunces(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF0C888))),
                const SizedBox(height: 3),
                Text('Tops up your cup toward the next tier.',
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 12.5,
                        height: 1.5,
                        color: isDark
                            ? const Color(0xFFA2917D)
                            : const Color(0xFFC9B7A3))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  const _GlassCircleButton(
      {required this.icon, required this.onTap, this.iconColor, this.semanticLabel});
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Pressable(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0x801C130D)
                  : const Color(0x99FFFFFF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? AppColors.secondary.withValues(alpha: 0.2)
                    : const Color(0xB3FFFFFF),
              ),
            ),
            child: Icon(icon,
                size: 20,
                color: iconColor ??
                    (isDark
                        ? AppColors.onBackgroundDark
                        : AppColors.onBackground)),
          ),
        ),
      ),
    ),
    );
  }
}

class _StickyAddBar extends StatelessWidget {
  const _StickyAddBar({
    required this.quantity,
    required this.total,
    required this.adding,
    required this.onQty,
    required this.onAdd,
    required this.maxQty,
  });

  final int quantity;
  final double total;
  final bool adding;
  final ValueChanged<int> onQty;
  final VoidCallback onAdd;
  final int maxQty;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 70,
          padding: const EdgeInsets.fromLTRB(14, 11, 12, 11),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xA81C130D) : const Color(0xB8F7F1EA),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: isDark
                    ? AppColors.secondary.withValues(alpha: 0.22)
                    : const Color(0xB3FFFFFF)),
            boxShadow: [
              BoxShadow(
                  color: isDark
                      ? const Color(0x80000000)
                      : const Color(0x3D3B2417),
                  blurRadius: 34,
                  offset: const Offset(0, 14)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceGlowDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _QtyButton(
                        icon: Icons.remove_rounded,
                        semanticLabel: 'Decrease quantity',
                        onTap: quantity > 1 ? () => onQty(quantity - 1) : null),
                    Container(
                      constraints: const BoxConstraints(minWidth: 22),
                      alignment: Alignment.center,
                      child: Text('$quantity',
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                    _QtyButton(
                        icon: Icons.add_rounded,
                        semanticLabel: 'Increase quantity',
                        onTap:
                            quantity < maxQty ? () => onQty(quantity + 1) : null),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Pressable(
                  onTap: adding ? null : onAdd,
                  scale: 0.98,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (adding)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Color(0xFFF0C888)),
                              )
                            else
                              Text('Add to cart',
                                  style: GoogleFonts.hankenGrotesk(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.onPrimaryDark
                                          : AppColors.onPrimary)),
                          ],
                        ),
                        Text(total.toCurrency,
                            style: GoogleFonts.fraunces(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.onPrimaryDark
                                    : const Color(0xFFF0C888))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton(
      {required this.icon, required this.onTap, this.semanticLabel});
  final IconData icon;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon,
              size: 20,
              color: onTap == null
                  ? AppColors.textMuted
                  : Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }
}

// ── Sold out ─────────────────────────────────────────────────────────────────
class _SoldOutView extends StatelessWidget {
  const _SoldOutView({required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topInset = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 352,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.55),
                radius: 1.1,
                colors: isDark
                    ? const [Color(0xFF2A2018), Color(0xFF1F1712), Color(0xFF1C130D)]
                    : const [Color(0xFFF1ECE4), Color(0xFFE4DBCE), Color(0xFFDAD0C0)],
                stops: const [0, 0.62, 1],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (product.images.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Opacity(
                      opacity: 0.55,
                      child: ColorFiltered(
                        colorFilter:
                            const ColorFilter.matrix(_grayscaleMatrix),
                        child: SizedBox(
                          height: 250,
                          child: Hero(
                            tag: 'product-${product.slug}',
                            child: ProductCutout(url: product.images.first),
                          ),
                        ),
                      ),
                    ),
                  ),
                Transform.rotate(
                  angle: -0.1,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x66A5473B),
                            blurRadius: 20,
                            offset: Offset(0, 8))
                      ],
                    ),
                    child: Text('SOLD OUT',
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: AppColors.onError)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: topInset + 8,
          left: 20,
          child: _GlassCircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => context.pop(),
          ),
        ),
        Positioned.fill(
          top: 334,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : AppColors.background,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.category?.name.toUpperCase() ?? 'BREWPHORIA',
                    style: AppTextStyles.overline
                        .copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 6),
                Text(product.name,
                    style: GoogleFonts.fraunces(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 26),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceGlowDark
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: (isDark
                                ? AppColors.onBackgroundDark
                                : AppColors.onBackground)
                            .withValues(alpha: 0.22),
                        style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: isDark ? null : AppColors.cardShadow,
                        ),
                        child: const Icon(Icons.notifications_none_rounded,
                            color: Color(0xFFB87423), size: 24),
                      ),
                      const SizedBox(height: 14),
                      Text('Freshly out of this one',
                          style: GoogleFonts.fraunces(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(
                        'Our baristas are restocking. Get a tap on the shoulder the moment it’s back on the menu.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 13.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_rounded,
                      size: 18, color: Color(0xFFF0C888)),
                  label: const Text("Notify me when it's back"),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const List<double> _grayscaleMatrix = [
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0,
];

// ── Loading skeleton ─────────────────────────────────────────────────────────
class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget sk(double w, double h, [double r = 8]) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
            borderRadius: BorderRadius.circular(r),
          ),
        );
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 334,
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.55),
                radius: 1.1,
                colors: [Color(0xFFFBF4EA), Color(0xFFEFE3D2), Color(0xFFE7D9C4)],
                stops: [0, 0.62, 1],
              ),
            ),
            child: Center(child: sk(180, 210, 20)),
          ),
        ),
        Positioned.fill(
          top: 316,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : AppColors.background,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(22, 30, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sk(150, 13, 6),
                const SizedBox(height: 14),
                sk(220, 28),
                const SizedBox(height: 8),
                sk(150, 28),
                const SizedBox(height: 18),
                Row(children: [
                  Expanded(child: sk(double.infinity, 52, 14)),
                  const SizedBox(width: 8),
                  Expanded(child: sk(double.infinity, 52, 14)),
                  const SizedBox(width: 8),
                  Expanded(child: sk(double.infinity, 52, 14)),
                ]),
                const SizedBox(height: 20),
                sk(double.infinity, 14, 6),
                const SizedBox(height: 8),
                sk(300, 14, 6),
                const SizedBox(height: 24),
                sk(60, 18, 6),
                const SizedBox(height: 12),
                sk(double.infinity, 56, 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
