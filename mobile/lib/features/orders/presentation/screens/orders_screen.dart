import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brewphoria/core/constants/app_colors.dart';
import 'package:brewphoria/core/errors/app_exception.dart';
import 'package:brewphoria/core/constants/app_spacing.dart';
import 'package:brewphoria/core/constants/app_text_styles.dart';
import 'package:brewphoria/core/router/app_router.dart';
import 'package:brewphoria/core/router/route_names.dart';
import 'package:brewphoria/core/widgets/app_error_widget.dart';
import 'package:brewphoria/core/widgets/coffee_cup.dart';
import 'package:brewphoria/core/widgets/entrance.dart';
import 'package:brewphoria/core/widgets/product_cutout.dart';
import 'package:brewphoria/core/widgets/pressable.dart';
import 'package:brewphoria/core/utils/extensions.dart';
import 'package:brewphoria/features/orders/presentation/providers/orders_provider.dart';
import 'package:brewphoria/features/checkout/domain/order_model.dart';
import 'package:brewphoria/features/cart/presentation/providers/cart_provider.dart';

const _terminalStatuses = {'DELIVERED', 'CANCELLED', 'REFUNDED'};
const _stepLabels = ['Confirmed', 'Preparing', 'On the way', 'Delivered'];

int _stepOf(String s) => switch (s) {
      'PENDING' || 'CONFIRMED' => 0,
      'PREPARING' => 1,
      'OUT_FOR_DELIVERY' => 2,
      'DELIVERED' => 3,
      _ => 0,
    };

/// Stable short numeric order number derived from the cuid.
String _orderNo(String id) =>
    '#${(id.codeUnits.fold<int>(0, (a, b) => a + b) % 9000 + 1000)}';

String _statusMessage(String s) => switch (s) {
      'PENDING' || 'CONFIRMED' => 'Order confirmed',
      'PREPARING' => 'Brewing your order',
      'OUT_FOR_DELIVERY' => 'Out for delivery',
      'DELIVERED' => 'Delivered',
      'CANCELLED' => 'Cancelled',
      'REFUNDED' => 'Refunded',
      _ => s,
    };

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider());

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(ordersProvider()),
        child: ordersAsync.when(
          data: (result) {
            if (result.orders.isEmpty) return const _OrdersEmpty();
            final active = result.orders
                .where((o) => !_terminalStatuses.contains(o.status))
                .toList();
            final past = result.orders
                .where((o) => _terminalStatuses.contains(o.status))
                .toList();
            return ListView(
              padding: EdgeInsets.fromLTRB(
                  22, MediaQuery.of(context).padding.top + 12, 22, kGlassNavClearance),
              children: [
                Text('Orders',
                    style: AppTextStyles.displayMedium.copyWith(fontSize: 28)),
                const SizedBox(height: 18),
                for (var i = 0; i < active.length; i++)
                  Entrance(
                    delay: Duration(milliseconds: 60 * i),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _LiveTracker(order: active[i]),
                    ),
                  ),
                if (past.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: Text('Past orders',
                        style: GoogleFonts.fraunces(
                            fontSize: 17, fontWeight: FontWeight.w600)),
                  ),
                  for (var i = 0; i < past.length; i++)
                    Entrance(
                      delay: Duration(milliseconds: 40 * i),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PastOrderCard(order: past[i]),
                      ),
                    ),
                ],
              ],
            );
          },
          loading: () => const _OrdersSkeleton(),
          error: (e, _) => AppErrorWidget(
            message: friendlyError(e),
            onRetry: () => ref.invalidate(ordersProvider()),
          ),
        ),
      ),
    );
  }
}

// ── Live tracker ─────────────────────────────────────────────────────────────
class _LiveTracker extends StatefulWidget {
  const _LiveTracker({required this.order});
  final OrderModel order;

  @override
  State<_LiveTracker> createState() => _LiveTrackerState();
}

class _LiveTrackerState extends State<_LiveTracker> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Keep the "Ready in ~N min" countdown live without hammering the backend.
    if (_etaLabel() != null) {
      _ticker = Timer.periodic(
          const Duration(seconds: 30), (_) => setState(() {}));
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String? _etaLabel() {
    final order = widget.order;
    final eta = order.estimatedReadyAt;
    if (eta == null) return null;
    if (order.status == 'DELIVERED' || order.status == 'CANCELLED') return null;
    final mins = eta.difference(DateTime.now()).inMinutes;
    if (mins <= 0) return 'Ready any moment';
    return 'Ready in ~$mins min';
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final eta = _etaLabel();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final step = _stepOf(order.status);
    final summary = order.items
        .map((i) => i.quantity > 1
            ? '${i.productName} ×${i.quantity}'
            : i.productName)
        .join(' · ');

    return GestureDetector(
      onTap: () => context.pushNamed(RouteNames.orderDetail,
          pathParameters: {'id': order.id}),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: isDark
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF3B2417), Color(0xFF4A2E1B)],
                  begin: Alignment(-0.8, -1),
                  end: Alignment(0.8, 1)),
          color: isDark ? AppColors.surfaceGlowDark : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
          border: isDark
              ? Border.all(color: AppColors.secondary.withValues(alpha: 0.18))
              : null,
          boxShadow: [
            BoxShadow(
                color: isDark
                    ? const Color(0x66000000)
                    : const Color(0x383B2417),
                blurRadius: 28,
                offset: const Offset(0, 12)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CoffeeCup(
                    fill: (step + 1) / 4,
                    width: 74,
                    height: 104,
                    steam: true,
                    glow: true),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(_statusMessage(order.status).toUpperCase(),
                            style: GoogleFonts.hankenGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: const Color(0xFFF0C888))),
                      ),
                      const SizedBox(height: 8),
                      Text('Order ${_orderNo(order.id)}',
                          style: GoogleFonts.fraunces(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onBackgroundDark)),
                      const SizedBox(height: 3),
                      Text(summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 13, color: const Color(0xFFC9B7A3))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(order.total.toCurrency,
                              style: GoogleFonts.hankenGrotesk(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFF0C888))),
                          if (eta != null) ...[
                            const SizedBox(width: 10),
                            Icon(Icons.schedule_rounded,
                                size: 13, color: const Color(0xFFC9B7A3)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(eta,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.hankenGrotesk(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFC9B7A3))),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _StepRail(currentStep: step),
          ],
        ),
      ),
    );
  }
}

class _StepRail extends StatelessWidget {
  const _StepRail({required this.currentStep});
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < _stepLabels.length; i++) ...[
              _node(i),
              if (i < _stepLabels.length - 1) Expanded(child: _connector(i)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final label in _stepLabels)
              Text(label,
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 10, color: const Color(0xFFC9B7A3))),
          ],
        ),
      ],
    );
  }

  Widget _node(int i) {
    final done = i < currentStep;
    final current = i == currentStep;
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done
            ? AppColors.secondary
            : (current
                ? const Color(0x24F7F1EA)
                : const Color(0x1FF7F1EA)),
        border: current
            ? Border.all(color: AppColors.secondary, width: 2)
            : null,
      ),
      child: done
          ? const Icon(Icons.check_rounded, size: 15, color: Color(0xFF241812))
          : null,
    );
  }

  Widget _connector(int i) {
    final filled = i < currentStep;
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: (i == currentStep - 1)
            ? const LinearGradient(
                colors: [AppColors.secondary, Color(0x33F7F1EA)])
            : null,
        color: filled ? AppColors.secondary : const Color(0x33F7F1EA),
      ),
    );
  }
}

// ── Past order card ──────────────────────────────────────────────────────────
class _PastOrderCard extends ConsumerWidget {
  const _PastOrderCard({required this.order});
  final OrderModel order;

  Future<void> _reorder(BuildContext context, WidgetRef ref) async {
    HapticFeedback.selectionClick();
    try {
      for (final item in order.items) {
        await ref.read(cartNotifierProvider.notifier).addItem(
              item.productId,
              item.quantity,
              modifiers: item.modifiers.map((m) => m.optionId).toList(),
            );
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: const Text('Added to cart'),
            action: SnackBarAction(
                label: 'View cart',
                onPressed: () => context.go(RoutePaths.cart)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final first = order.items.isNotEmpty ? order.items.first : null;
    final title = order.items.length > 1
        ? '${first?.productName ?? 'Order'} +${order.items.length - 1}'
        : (first?.productName ?? 'Order');

    return GestureDetector(
      onTap: () => context.pushNamed(RouteNames.orderDetail,
          pathParameters: {'id': order.id}),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 80),
            padding: const EdgeInsets.fromLTRB(72, 14, 14, 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceGlowDark : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border:
                  isDark ? Border.all(color: AppColors.amberBorderDark) : null,
              boxShadow: isDark ? null : AppColors.cardShadow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.fraunces(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text('${order.createdAt.toDisplayDate} · ${order.total.toCurrency}',
                          style: AppTextStyles.captionText.copyWith(
                              fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Pressable(
                  onTap: () => _reorder(context, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.secondary
                          .withValues(alpha: isDark ? 0.16 : 0.14),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text('Reorder',
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFB87423))),
                  ),
                ),
              ],
            ),
          ),
          if (first != null && first.productImage.isNotEmpty)
            Positioned(
              left: -4,
              top: 0,
              bottom: 0,
              child: Center(
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: ProductCutout(
                    url: first.productImage,
                    decodeWidth: 200,
                    shadowColor: isDark
                        ? const Color(0x47D98E32)
                        : const Color(0x423B2417),
                    shadowOffset: const Offset(0, 8),
                    shadowBlur: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────
class _OrdersEmpty extends StatelessWidget {
  const _OrdersEmpty();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Center(
            child: Entrance(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(Icons.receipt_long_outlined,
                          size: 44, color: Color(0xFFC9A063)),
                    ),
                    const SizedBox(height: 20),
                    Text('No orders yet',
                        style: GoogleFonts.fraunces(
                            fontSize: 23, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Text(
                      "When you place an order, you'll track it here and be able to reorder in a tap.",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    Pressable(
                      onTap: () => context.go(RoutePaths.shop),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Start an order',
                                style: GoogleFonts.hankenGrotesk(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded,
                                size: 18, color: Color(0xFFF0C888)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrdersSkeleton extends StatelessWidget {
  const _OrdersSkeleton();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase;
    return ListView(
      padding: EdgeInsets.fromLTRB(
          22, MediaQuery.of(context).padding.top + 12, 22, kGlassNavClearance),
      children: [
        Container(
            width: 130,
            height: 28,
            decoration: BoxDecoration(
                color: base, borderRadius: BorderRadius.circular(8))),
        const SizedBox(height: 18),
        Container(
            height: 200,
            decoration: BoxDecoration(
                color: base, borderRadius: BorderRadius.circular(24))),
        const SizedBox(height: 24),
        for (var i = 0; i < 3; i++)
          Container(
            height: 80,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
                color: base, borderRadius: BorderRadius.circular(20)),
          ),
      ],
    );
  }
}
