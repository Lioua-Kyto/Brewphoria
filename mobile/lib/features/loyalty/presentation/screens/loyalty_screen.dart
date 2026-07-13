import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coffee_card/core/constants/app_colors.dart';
import 'package:coffee_card/core/constants/app_spacing.dart';
import 'package:coffee_card/core/constants/app_text_styles.dart';
import 'package:coffee_card/core/router/route_names.dart';
import 'package:coffee_card/core/errors/app_exception.dart';
import 'package:coffee_card/core/widgets/app_error_widget.dart';
import 'package:coffee_card/core/widgets/entrance.dart';
import 'package:coffee_card/core/widgets/coffee_cup.dart';
import 'package:coffee_card/core/widgets/brew_snack.dart';
import 'package:coffee_card/features/cart/presentation/providers/cart_provider.dart';
import 'package:coffee_card/core/widgets/product_cutout.dart';
import 'package:coffee_card/core/widgets/pressable.dart';
import 'package:coffee_card/core/router/app_router.dart';
import 'package:coffee_card/core/utils/extensions.dart';
import 'package:coffee_card/features/loyalty/presentation/providers/loyalty_provider.dart';
import 'package:coffee_card/features/loyalty/domain/loyalty_model.dart';

const _tiers = ['BRONZE', 'SILVER', 'GOLD', 'PLATINUM'];

int _tierFloor(String tier) => switch (tier) {
      'SILVER' => 500,
      'GOLD' => 1500,
      'PLATINUM' => 3000,
      _ => 0,
    };

/// (nextThreshold, nextTierName) — null for top tier.
(int?, String?) _nextTier(String tier) => switch (tier) {
      'BRONZE' => (500, 'Silver'),
      'SILVER' => (1500, 'Gold'),
      'GOLD' => (3000, 'Platinum'),
      _ => (null, null),
    };

// Static rewards catalogue — NOTE: no rewards-catalog model exists in the
// backend; redemption happens as a points→discount at checkout. Flagged.
// Rewards are order credits redeemed against points (100 pts = $1), applied at
// checkout — so the economics line up with the checkout redemption slider.
const _rewards = [
  (label: 'Drink credit', cost: 500, img: 'cappuccino.png'),
  (label: 'Pastry credit', cost: 300, img: 'croissant.png'),
  (label: 'Beans credit', cost: 900, img: 'beans-box.png'),
];

class LoyaltyScreen extends ConsumerWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loyaltyAsync = ref.watch(loyaltyAccountProvider);
    final historyAsync = ref.watch(loyaltyHistoryProvider());

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(loyaltyAccountProvider);
          ref.invalidate(loyaltyHistoryProvider());
        },
        child: loyaltyAsync.when(
          data: (loyalty) => ListView(
            padding: EdgeInsets.only(bottom: kGlassNavClearance),
            children: [
              _LoyaltyHero(loyalty: loyalty),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Tier ladder'),
                    const SizedBox(height: 12),
                    _TierLadder(tier: loyalty.tier),
                    const SizedBox(height: 26),
                    _sectionTitle('Ready to redeem'),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              _RewardsRow(currentPoints: loyalty.currentPoints),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Recent activity'),
                    const SizedBox(height: 8),
                    historyAsync.when(
                      data: (result) => result.transactions.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text('No activity yet',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary)),
                            )
                          : Column(
                              children: [
                                for (final (i, t)
                                    in result.transactions.indexed)
                                  Entrance(
                                    delay: Duration(
                                        milliseconds: (i.clamp(0, 6)) * 55),
                                    child: _ActivityTile(transaction: t),
                                  ),
                              ],
                            ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Text(friendlyError(e)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(
            message: friendlyError(e),
            onRetry: () => ref.invalidate(loyaltyAccountProvider),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: GoogleFonts.fraunces(fontSize: 17, fontWeight: FontWeight.w600));
}

// ── Hero ─────────────────────────────────────────────────────────────────────
class _LoyaltyHero extends StatelessWidget {
  const _LoyaltyHero({required this.loyalty});
  final LoyaltyModel loyalty;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final floor = _tierFloor(loyalty.tier);
    final (next, nextName) = _nextTier(loyalty.tier);
    final fill = next == null
        ? 1.0
        : ((loyalty.lifetimePoints - floor) / (next - floor)).clamp(0.0, 1.0);
    final remaining = next == null ? 0 : (next - loyalty.lifetimePoints);

    return Container(
      padding: EdgeInsets.fromLTRB(24, topInset + 24, 24, 34),
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -1),
          radius: 1.1,
          colors: [Color(0xFF4A2E1B), Color(0xFF3B2417)],
          stops: [0, 0.7],
        ),
      ),
      child: Column(
        children: [
          Text('BREWPHORIA REWARDS',
              style: GoogleFonts.hankenGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: const Color(0xFFC9B7A3))),
          const SizedBox(height: 4),
          ShaderMask(
            shaderCallback: (r) => const LinearGradient(
              colors: [Color(0xFFB8863C), Color(0xFFF5D89B), Color(0xFFC9963F)],
            ).createShader(r),
            child: Text(loyalty.tier,
                style: GoogleFonts.fraunces(
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: Colors.white)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 150,
            height: 210,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CoffeeCup(
                    fill: fill,
                    width: 150,
                    height: 210,
                    steam: true,
                    glow: true),
                Positioned(
                  bottom: 26,
                  child: Column(
                    children: [
                      Text(loyalty.currentPoints.toPoints,
                          style: GoogleFonts.fraunces(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                    color: Color(0x66000000), blurRadius: 8)
                              ])),
                      Text('POINTS',
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 10,
                              letterSpacing: 1.4,
                              color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0x1AF7F1EA),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(color: const Color(0x24F7F1EA)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    size: 16, color: Color(0xFFF0C888)),
                const SizedBox(width: 8),
                Text(
                  next == null
                      ? 'Top tier — enjoy every perk'
                      : '$remaining points until $nextName',
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 13, color: const Color(0xFFEADFD0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tier ladder ──────────────────────────────────────────────────────────────
class _TierLadder extends StatelessWidget {
  const _TierLadder({required this.tier});
  final String tier;

  @override
  Widget build(BuildContext context) {
    final currentIndex = _tiers.indexOf(tier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < _tiers.length; i++)
          Column(
            children: [
              _node(i, currentIndex),
              const SizedBox(height: 6),
              Text(_tiers[i][0] + _tiers[i].substring(1).toLowerCase(),
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 11,
                      fontWeight:
                          i == currentIndex ? FontWeight.w700 : FontWeight.w500,
                      color: i == currentIndex
                          ? const Color(0xFFB87423)
                          : AppColors.textSecondary)),
            ],
          ),
      ],
    );
  }

  Widget _node(int i, int currentIndex) {
    if (i < currentIndex) {
      return Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
            shape: BoxShape.circle, color: Color(0xFFC9A063)),
        child: const Icon(Icons.check_rounded, size: 15, color: Colors.white),
      );
    }
    if (i == currentIndex) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
              colors: [Color(0xFFE7C173), Color(0xFFB8863C)]),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: const Icon(Icons.star_rounded, size: 16, color: Colors.white),
      );
    }
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceVariant,
        border: Border.all(
            color: AppColors.onBackground.withValues(alpha: 0.2),
            width: 1.5),
      ),
      child: Icon(Icons.lock_outline_rounded,
          size: 14, color: AppColors.textMuted),
    );
  }
}

// ── Rewards ──────────────────────────────────────────────────────────────────
class _RewardsRow extends ConsumerWidget {
  const _RewardsRow({required this.currentPoints});
  final int currentPoints;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        itemCount: _rewards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final r = _rewards[i];
          final unlocked = currentPoints >= r.cost;
          return Container(
            width: 158,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceGlowDark : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isDark ? null : AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 74,
                  child: Center(
                    child: Opacity(
                      opacity: unlocked ? 1 : 0.55,
                      child: SizedBox(
                        height: 84,
                        child: ProductCutout(url: 'assets/img/${r.img}', decodeWidth: 200),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('\$${(r.cost / 100).toStringAsFixed(0)} ${r.label}',
                    style: GoogleFonts.fraunces(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${r.cost} pts',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                if (unlocked)
                  Pressable(
                    onTap: () => _confirmRedeem(context, ref, r.cost),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            isDark ? AppColors.primaryDark : AppColors.primary,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text('Redeem',
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.onPrimaryDark
                                  : AppColors.onPrimary)),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                          color: isDark
                              ? AppColors.outlineDark
                              : AppColors.outline),
                    ),
                    child: Text('${r.cost - currentPoints} pts away',
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmRedeem(BuildContext context, WidgetRef ref, int cost) {
    final credit = (cost / 100).toStringAsFixed(0);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CoffeeCup(fill: 0.9, width: 54, height: 76, glow: true),
              const SizedBox(height: 16),
              Text('Redeem \$$credit credit',
                  style: GoogleFonts.fraunces(
                      fontSize: 21, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                "We'll set aside $cost points as a \$$credit credit. Add anything "
                'to your cart and it applies automatically at checkout.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(checkoutRedeemProvider.notifier).set(cost);
                    Navigator.pop(ctx);
                    showBrewSnack(context,
                        '\$$credit credit ready — it applies at checkout',
                        icon: Icons.redeem_rounded);
                    context.go(RoutePaths.shop);
                  },
                  child: const Text('Set aside & shop'),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Not now',
                    style: GoogleFonts.hankenGrotesk(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Activity ─────────────────────────────────────────────────────────────────
class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.transaction});
  final LoyaltyTransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final positive =
        transaction.type == 'EARNED' || transaction.type == 'BONUS';
    final isBonus = transaction.type == 'BONUS';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: (isDark ? AppColors.outlineDark : AppColors.outline)
                    .withValues(alpha: 0.6))),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceGlowDark
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
                isBonus
                    ? Icons.star_rounded
                    : (positive
                        ? Icons.local_cafe_outlined
                        : Icons.redeem_outlined),
                size: 18,
                color: const Color(0xFFB87423)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Text(transaction.createdAt.toRelative,
                    style: AppTextStyles.captionText
                        .copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          Text('${positive ? '+' : ''}${transaction.points.toPoints}',
              style: GoogleFonts.hankenGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: positive ? AppColors.success : AppColors.error)),
        ],
      ),
    );
  }
}
