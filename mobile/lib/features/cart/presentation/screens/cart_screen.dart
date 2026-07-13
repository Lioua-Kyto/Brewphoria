import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coffee_card/core/constants/app_colors.dart';
import 'package:coffee_card/core/constants/app_text_styles.dart';
import 'package:coffee_card/core/router/app_router.dart';
import 'package:coffee_card/core/router/route_names.dart';
import 'package:coffee_card/core/errors/app_exception.dart';
import 'package:coffee_card/core/widgets/auth_gate.dart';
import 'package:coffee_card/core/widgets/coffee_cup.dart';
import 'package:coffee_card/core/widgets/entrance.dart';
import 'package:coffee_card/core/widgets/product_cutout.dart';
import 'package:coffee_card/core/widgets/pressable.dart';
import 'package:coffee_card/core/utils/extensions.dart';
import 'package:coffee_card/features/cart/presentation/providers/cart_provider.dart';
import 'package:coffee_card/features/cart/domain/cart_item_model.dart';
import 'package:coffee_card/features/loyalty/presentation/providers/loyalty_provider.dart';

const double _freeDeliveryThreshold = 50.0;
const double _deliveryFee = 5.99;

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  String? _note;

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartNotifierProvider);
    final points = ref.watch(loyaltyAccountProvider).valueOrNull?.currentPoints ?? 0;
    final tip = ref.watch(cartTipProvider);

    return Scaffold(
      body: cartAsync.when(
        data: (cart) => cart.items.isEmpty
            ? const _EmptyCart()
            : _CartBody(
                items: cart.items,
                points: points,
                tip: tip,
                note: _note,
                onTip: (v) => ref.read(cartTipProvider.notifier).set(v),
                onNote: (v) => setState(() => _note = v),
              ),
        loading: () => const _CartSkeleton(),
        error: (e, _) => Center(child: Text(friendlyError(e))),
      ),
    );
  }
}

class _CartBody extends ConsumerWidget {
  const _CartBody({
    required this.items,
    required this.points,
    required this.tip,
    required this.note,
    required this.onTip,
    required this.onNote,
  });

  final List<CartItemModel> items;
  final int points;
  final int tip;
  final String? note;
  final ValueChanged<int> onTip;
  final ValueChanged<String?> onNote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal =
        items.fold<double>(0, (s, i) => s + i.effectiveUnitPrice * i.quantity);
    final delivery = subtotal >= _freeDeliveryThreshold ? 0.0 : _deliveryFee;
    final tipAmount = subtotal * tip / 100;
    final maxRedeem = (points / 100).clamp(0, subtotal).toDouble();
    // Points shared with checkout; capped to a multiple of 100 and to subtotal.
    final redeemPoints = ref.watch(checkoutRedeemProvider);
    final maxRedeemPoints =
        ((points ~/ 100) * 100).clamp(0, subtotal.floor() * 100).toInt();
    final discount = (redeemPoints / 100).clamp(0, subtotal).toDouble();
    final total = (subtotal + delivery + tipAmount - discount).clamp(0, double.infinity);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.fromLTRB(
              22, MediaQuery.of(context).padding.top + 12, 22, 210),
          children: [
            Text('Your order',
                style: AppTextStyles.displayMedium.copyWith(
                    fontSize: 28,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 4),
            Text('${items.fold<int>(0, (s, i) => s + i.quantity)} items · ready in ~12 min',
                style: AppTextStyles.bodyMedium.copyWith(color: secondary)),
            const SizedBox(height: 20),
            // Line items (staggered, swipe to delete)
            for (var i = 0; i < items.length; i++)
              Entrance(
                delay: Duration(milliseconds: 60 * i),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SwipeableLine(item: items[i]),
                ),
              ),
            const SizedBox(height: 2),
            _NoteTile(note: note, onNote: onNote),
            const SizedBox(height: 16),
            if (delivery > 0)
              _FreeDeliveryProgress(subtotal: subtotal)
            else
              const _FreeDeliveryUnlocked(),
            const SizedBox(height: 16),
            if (points >= 100)
              _RedeemCard(
                points: points,
                saves: maxRedeem,
                on: redeemPoints > 0,
                onChanged: (v) => ref
                    .read(checkoutRedeemProvider.notifier)
                    .set(v ? maxRedeemPoints : 0),
              ),
            const SizedBox(height: 20),
            Text('Add a tip',
                style: GoogleFonts.fraunces(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _TipSelector(tip: tip, onTip: onTip),
            const SizedBox(height: 20),
            _SummaryRows(
              subtotal: subtotal,
              delivery: delivery,
              tip: tipAmount,
              discount: discount,
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _CheckoutBar(total: total.toDouble(), tip: tipAmount),
        ),
      ],
    );
  }
}

// ── Line item ────────────────────────────────────────────────────────────────
class _SwipeableLine extends ConsumerWidget {
  const _SwipeableLine({required this.item});
  final CartItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartNotifierProvider.notifier);
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 26),
      ),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        final removed = item;
        notifier.removeItem(item.id);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('${removed.product.name} removed'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () => notifier.addItem(
                  removed.product.id,
                  removed.quantity,
                  modifiers:
                      removed.modifiers.map((m) => m.optionId).toList(),
                ),
              ),
            ),
          );
      },
      child: _CartLineCard(item: item),
    );
  }
}

class _CartLineCard extends ConsumerWidget {
  const _CartLineCard({required this.item});
  final CartItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifier = ref.read(cartNotifierProvider.notifier);
    final line = item.effectiveUnitPrice * item.quantity;
    final meta = item.modifiers.isNotEmpty
        ? item.modifierLabel
        : item.product.category?.name;

    return GestureDetector(
      onTap: () => context.pushNamed(RouteNames.productDetail,
          pathParameters: {'slug': item.product.slug}),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 82),
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
                  Text(item.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.fraunces(
                          fontSize: 16, fontWeight: FontWeight.w600, height: 1.1)),
                  if (meta != null && meta.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.captionText
                            .copyWith(fontSize: 12, color: AppColors.textMuted)),
                  ],
                  const SizedBox(height: 6),
                  Text(line.toCurrency,
                      style: GoogleFonts.hankenGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.secondary
                              : const Color(0xFFB87423))),
                ],
              ),
            ),
            _QtyStepper(
              quantity: item.quantity,
              // At 1, the minus button removes the line entirely (shown as a
              // trash icon) instead of being a dead end.
              onDec: item.quantity > 1
                  ? () => notifier.updateItem(item.id, item.quantity - 1)
                  : () => notifier.removeItem(item.id),
              onInc: item.quantity < item.product.stock
                  ? () => notifier.updateItem(item.id, item.quantity + 1)
                  : null,
            ),
              ],
            ),
          ),
          Positioned(
            left: -4,
            top: 0,
            bottom: 0,
            child: Center(
              child: SizedBox(
                width: 72,
                height: 72,
                child: item.product.images.isNotEmpty
                    ? ProductCutout(
                        url: item.product.images.first,
                        decodeWidth: 200,
                        shadowColor: isDark
                            ? const Color(0x4DD98E32)
                            : const Color(0x3D3B2417),
                        shadowOffset: const Offset(0, 8),
                        shadowBlur: 10,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper(
      {required this.quantity, required this.onDec, required this.onInc});
  final int quantity;
  final VoidCallback? onDec;
  final VoidCallback? onInc;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepBtn(
            context,
            quantity <= 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
            onDec,
            danger: quantity <= 1,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: ScaleTransition(scale: anim, child: child),
            ),
            child: Container(
              key: ValueKey(quantity),
              constraints: const BoxConstraints(minWidth: 22),
              alignment: Alignment.center,
              child: Text('$quantity',
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
          _stepBtn(context, Icons.add_rounded, onInc),
        ],
      ),
    );
  }

  Widget _stepBtn(BuildContext context, IconData icon, VoidCallback? onTap,
      {bool danger = false}) {
    final color = onTap == null
        ? AppColors.textMuted
        : danger
            ? AppColors.error
            : Theme.of(context).colorScheme.onSurface;
    return Pressable(
      onTap: onTap,
      scale: 0.85,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

// ── Note ─────────────────────────────────────────────────────────────────────
class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note, required this.onNote});
  final String? note;
  final ValueChanged<String?> onNote;

  Future<void> _edit(BuildContext context) async {
    final controller = TextEditingController(text: note);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Note for the barista',
                  style: GoogleFonts.fraunces(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: 'Oat milk, extra hot, light ice…'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                child: const Text('Save note'),
              ),
            ],
          ),
        ),
      ),
    );
    if (result != null) onNote(result.isEmpty ? null : result);
  }

  @override
  Widget build(BuildContext context) {
    final has = note != null && note!.isNotEmpty;
    return Pressable(
      onTap: () => _edit(context),
      scale: 0.99,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: has
                ? AppColors.secondary.withValues(alpha: 0.4)
                : AppColors.outline,
            style: has ? BorderStyle.solid : BorderStyle.solid,
          ),
          color: has ? AppColors.secondary.withValues(alpha: 0.06) : null,
        ),
        child: Row(
          children: [
            Icon(has ? Icons.edit_note_rounded : Icons.add_rounded,
                size: 19, color: const Color(0xFFB87423)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                has ? note! : 'Add a note for the barista',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: has
                        ? Theme.of(context).colorScheme.onSurface
                        : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Free delivery progress ───────────────────────────────────────────────────
class _FreeDeliveryProgress extends StatelessWidget {
  const _FreeDeliveryProgress({required this.subtotal});
  final double subtotal;

  @override
  Widget build(BuildContext context) {
    final remaining = (_freeDeliveryThreshold - subtotal).clamp(0, double.infinity);
    final progress = (subtotal / _freeDeliveryThreshold).clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceGlowDark : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined,
                  size: 18, color: AppColors.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13.5,
                        color: Theme.of(context).colorScheme.onSurface),
                    children: [
                      const TextSpan(text: 'Add '),
                      TextSpan(
                          text: remaining.toDouble().toCurrency,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFB87423))),
                      const TextSpan(text: ' more for free delivery'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 7,
                backgroundColor:
                    isDark ? AppColors.backgroundDark : AppColors.surfaceVariant,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.secondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeDeliveryUnlocked extends StatelessWidget {
  const _FreeDeliveryUnlocked();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 18, color: AppColors.success),
          const SizedBox(width: 8),
          Text('Free delivery unlocked',
              style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success)),
        ],
      ),
    );
  }
}

// ── Redeem rewards ───────────────────────────────────────────────────────────
class _RedeemCard extends StatelessWidget {
  const _RedeemCard(
      {required this.points,
      required this.saves,
      required this.on,
      required this.onChanged});
  final int points;
  final double saves;
  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final used = (saves * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : const LinearGradient(
                colors: [Color(0xFF3B2417), Color(0xFF4A2E1B)],
                begin: Alignment(-0.8, -1),
                end: Alignment(0.8, 1)),
        color: isDark ? AppColors.surfaceGlowDark : null,
        border: isDark
            ? Border.all(color: AppColors.secondary.withValues(alpha: 0.2))
            : null,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CoffeeCup(fill: (points / 500).clamp(0.1, 1.0), width: 40, height: 56, glow: isDark),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Redeem your points',
                    style: GoogleFonts.fraunces(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF0C888))),
                const SizedBox(height: 2),
                Text('Use $used pts · saves ${saves.toCurrency}',
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 12, color: const Color(0xFFC9B7A3))),
              ],
            ),
          ),
          _AnimatedToggle(value: on, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _AnimatedToggle extends StatelessWidget {
  const _AnimatedToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: 46,
        height: 27,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.success : const Color(0x33F7F1EA),
          borderRadius: BorderRadius.circular(100),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 21,
            height: 21,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

// ── Tip ──────────────────────────────────────────────────────────────────────
class _TipSelector extends StatelessWidget {
  const _TipSelector({required this.tip, required this.onTip});
  final int tip;
  final ValueChanged<int> onTip;

  static const _options = [10, 15, 20];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final index = _options.indexOf(tip);
    return LayoutBuilder(builder: (context, constraints) {
      final segW = (constraints.maxWidth - 10) / _options.length;
      return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceGlowDark : const Color(0xFFEDE3D5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              left: index < 0 ? 0 : segW * index,
              top: 0,
              bottom: 0,
              width: segW,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primaryDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: isDark ? null : AppColors.cardShadow,
                ),
              ),
            ),
            Row(
              children: [
                for (final o in _options)
                  Expanded(
                    child: Pressable(
                      onTap: () => onTip(o),
                      scale: 0.96,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        alignment: Alignment.center,
                        child: Text('$o%',
                            style: GoogleFonts.hankenGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: o == tip
                                    ? (isDark
                                        ? AppColors.onPrimaryDark
                                        : AppColors.onBackground)
                                    : AppColors.textSecondary)),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ── Summary ──────────────────────────────────────────────────────────────────
class _SummaryRows extends StatelessWidget {
  const _SummaryRows(
      {required this.subtotal,
      required this.delivery,
      required this.tip,
      required this.discount});
  final double subtotal;
  final double delivery;
  final double tip;
  final double discount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row(context, 'Subtotal', subtotal.toCurrency),
        const SizedBox(height: 9),
        _row(context, 'Delivery', delivery == 0 ? 'FREE' : delivery.toCurrency,
            valueColor: delivery == 0 ? AppColors.success : null),
        if (tip > 0) ...[
          const SizedBox(height: 9),
          _row(context, 'Tip', tip.toCurrency),
        ],
        if (discount > 0) ...[
          const SizedBox(height: 9),
          _row(context, 'Rewards', '−${discount.toCurrency}',
              valueColor: AppColors.success),
        ],
      ],
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {Color? valueColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary)),
        Text(value,
            style: GoogleFonts.hankenGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
}

// ── Glass checkout bar ───────────────────────────────────────────────────────
class _CheckoutBar extends ConsumerWidget {
  const _CheckoutBar({required this.total, required this.tip});
  final double total;
  final double tip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, kGlassNavClearance - 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 72,
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total',
                        style: AppTextStyles.captionText
                            .copyWith(color: AppColors.textSecondary)),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: total, end: total),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, _) => Text(
                        value.toCurrency,
                        style: GoogleFonts.fraunces(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            height: 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Pressable(
                    onTap: () async {
                      if (!await requireAccount(context, ref,
                          action: 'check out')) {
                        return;
                      }
                      if (!context.mounted) return;
                      context.pushNamed(RouteNames.checkout, extra: tip);
                    },
                    scale: 0.97,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.primaryDark : AppColors.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Checkout',
                              style: GoogleFonts.hankenGrotesk(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.onPrimaryDark
                                      : AppColors.onPrimary)),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded,
                              size: 18,
                              color: isDark
                                  ? AppColors.onPrimaryDark
                                  : const Color(0xFFF0C888)),
                        ],
                      ),
                    ),
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

// ── Empty state ──────────────────────────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Entrance(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, kGlassNavClearance),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CoffeeCup(
                  fill: 0,
                  width: 120,
                  height: 150,
                  steam: true,
                  onLightBackground:
                      Theme.of(context).brightness == Brightness.light),
              const SizedBox(height: 20),
              Text("Your cup's empty",
                  style: GoogleFonts.fraunces(
                      fontSize: 23, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Text(
                "Nothing brewing yet. Add a drink or a pastry and it'll show up here.",
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
                      Text('Browse the menu',
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onPrimary)),
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
    );
  }
}

// ── Loading skeleton ─────────────────────────────────────────────────────────
class _CartSkeleton extends StatelessWidget {
  const _CartSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase;
    return ListView(
      padding: EdgeInsets.fromLTRB(
          22, MediaQuery.of(context).padding.top + 12, 22, 210),
      children: [
        Container(width: 160, height: 28, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(8))),
        const SizedBox(height: 20),
        for (var i = 0; i < 3; i++)
          Container(
            height: 82,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
                color: base, borderRadius: BorderRadius.circular(20)),
          ),
      ],
    );
  }
}
