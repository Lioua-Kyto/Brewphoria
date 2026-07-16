import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brewphoria/core/constants/app_colors.dart';
import 'package:brewphoria/core/constants/app_spacing.dart';
import 'package:brewphoria/core/constants/app_text_styles.dart';
import 'package:brewphoria/core/router/route_names.dart';
import 'package:brewphoria/core/errors/app_exception.dart';
import 'package:brewphoria/core/widgets/app_error_widget.dart';
import 'package:brewphoria/core/widgets/app_network_image.dart';
import 'package:brewphoria/core/widgets/entrance.dart';
import 'package:brewphoria/core/widgets/pressable.dart';
import 'package:brewphoria/core/utils/extensions.dart';
import 'package:brewphoria/features/shop/presentation/providers/product_detail_provider.dart';
import 'package:brewphoria/features/reviews/domain/review_model.dart';

enum _Filter { all, withPhotos, fiveStars }

class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({
    required this.productId,
    required this.productName,
    required this.avgRating,
    required this.reviewCount,
    super.key,
  });

  final String productId;
  final String productName;
  final double avgRating;
  final int reviewCount;

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(productReviewsProvider(widget.productId));
    final summary =
        ref.watch(productReviewSummaryProvider(widget.productId)).valueOrNull;
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : const Color(0xFFF3EBE0),
      body: Stack(
        children: [
          Positioned.fill(
            child: reviewsAsync.when(
              data: (reviews) => reviews.isEmpty
                  ? _EmptyReviews(topInset: topInset)
                  : _buildList(reviews, topInset, summary),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Padding(
                padding: EdgeInsets.only(top: topInset + 104),
                child: AppErrorWidget(
                  message: friendlyError(e),
                  onRetry: () =>
                      ref.invalidate(productReviewsProvider(widget.productId)),
                ),
              ),
            ),
          ),
          _Header(topInset: topInset, productName: widget.productName),
          _WriteBar(),
        ],
      ),
    );
  }

  Widget _buildList(
      List<ReviewModel> reviews, double topInset, ReviewSummary? summary) {
    final counts = List<int>.filled(6, 0);
    if (summary != null) {
      for (var star = 1; star <= 5; star++) {
        counts[star] = summary.distribution[star] ?? 0;
      }
    } else {
      for (final r in reviews) {
        if (r.rating >= 1 && r.rating <= 5) counts[r.rating]++;
      }
    }
    final avg = summary?.average ?? widget.avgRating;
    final total = summary?.count ?? widget.reviewCount;
    final filtered = switch (_filter) {
      _Filter.all => reviews,
      _Filter.withPhotos => reviews.where((r) => r.images.isNotEmpty).toList(),
      _Filter.fiveStars => reviews.where((r) => r.rating == 5).toList(),
    };

    return ListView(
      padding: EdgeInsets.fromLTRB(18, topInset + 116, 18, 108),
      children: [
        _SummaryCard(
          avg: avg,
          total: total,
          counts: counts,
        ),
        const SizedBox(height: 14),
        _FilterChips(
          selected: _filter,
          total: total,
          onSelect: (f) => setState(() => _filter = f),
        ),
        const SizedBox(height: 14),
        for (final (i, r) in filtered.indexed) ...[
          Entrance(
            delay: Duration(milliseconds: (i.clamp(0, 6)) * 55),
            child: _ReviewCard(review: r),
          ),
          const SizedBox(height: 12),
        ],
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text('No reviews match this filter',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ),
      ],
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.topInset, required this.productName});
  final double topInset;
  final String productName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: EdgeInsets.fromLTRB(18, topInset + 8, 18, 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xCC1C130D) : const Color(0xCCF3EBE0),
              border: Border(
                  bottom: BorderSide(
                      color: isDark
                          ? AppColors.secondary.withValues(alpha: 0.12)
                          : AppColors.onBackground.withValues(alpha: 0.08))),
            ),
            child: Row(
              children: [
                Pressable(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surface,
                      borderRadius: BorderRadius.circular(13),
                      border: isDark
                          ? Border.all(color: AppColors.amberBorderDark)
                          : null,
                      boxShadow: isDark ? null : AppColors.cardShadow,
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurface),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reviews',
                        style: GoogleFonts.fraunces(
                            fontSize: 19, fontWeight: FontWeight.w600)),
                    Text(productName,
                        style: AppTextStyles.captionText
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard(
      {required this.avg, required this.total, required this.counts});
  final double avg;
  final int total;
  final List<int> counts;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxCount =
        counts.skip(1).fold<int>(1, (m, c) => c > m ? c : m).toDouble();
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceGlowDark : AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: isDark ? Border.all(color: AppColors.amberBorderDark) : null,
        boxShadow: isDark ? null : AppColors.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(avg.toStringAsFixed(1),
                  style: GoogleFonts.fraunces(
                      fontSize: 52, fontWeight: FontWeight.w500, height: 0.9)),
              const SizedBox(height: 8),
              _Stars(rating: avg.round(), size: 14),
              const SizedBox(height: 7),
              Text('$total reviews',
                  style: AppTextStyles.captionText
                      .copyWith(color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              children: [
                for (var star = 5; star >= 1; star--)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Row(
                      children: [
                        Text('$star',
                            style: GoogleFonts.hankenGrotesk(
                                fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(width: 9),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(
                                  begin: 0, end: counts[star] / maxCount),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutCubic,
                              builder: (context, v, _) => LinearProgressIndicator(
                                value: v,
                                minHeight: 7,
                                backgroundColor: isDark
                                    ? AppColors.backgroundDark
                                    : const Color(0xFFEDE3D5),
                                valueColor: const AlwaysStoppedAnimation(
                                    AppColors.secondary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        SizedBox(
                          width: 24,
                          child: Text('${counts[star]}',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.hankenGrotesk(
                                  fontSize: 11, color: AppColors.textMuted)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips(
      {required this.selected, required this.total, required this.onSelect});
  final _Filter selected;
  final int total;
  final ValueChanged<_Filter> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = [
      (_Filter.all, 'All $total'),
      (_Filter.withPhotos, 'With photos'),
      (_Filter.fiveStars, '5 stars'),
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final sel = items[i].$1 == selected;
          return Pressable(
            onTap: () => onSelect(items[i].$1),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: sel
                    ? (isDark ? AppColors.primaryDark : AppColors.primary)
                    : (isDark ? AppColors.surfaceGlowDark : AppColors.surface),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: sel
                    ? null
                    : Border.all(
                        color: isDark
                            ? AppColors.outlineDark
                            : AppColors.outline),
              ),
              child: Text(items[i].$2,
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: sel
                          ? (isDark
                              ? AppColors.onPrimaryDark
                              : AppColors.onPrimary)
                          : (isDark
                              ? const Color(0xFFC9B7A3)
                              : const Color(0xFF5C4A3A)))),
            ),
          );
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final ReviewModel review;

  static const _avatarGradients = [
    [Color(0xFFE7C173), Color(0xFFB8863C)],
    [Color(0xFF8FA383), Color(0xFF5A7A52)],
    [Color(0xFFC99A6A), Color(0xFF8A5A34)],
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = review.user?.displayName ?? 'Guest';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final grad = _avatarGradients[name.hashCode.abs() % _avatarGradients.length];

    return Container(
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceGlowDark : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: AppColors.amberBorderDark) : null,
        boxShadow: isDark ? null : AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: grad,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(initial,
                    style: GoogleFonts.fraunces(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name,
                            style: GoogleFonts.hankenGrotesk(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 6),
                        Icon(Icons.verified_rounded,
                            size: 13, color: AppColors.success),
                        const SizedBox(width: 3),
                        Text('Verified',
                            style: GoogleFonts.hankenGrotesk(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    _Stars(rating: review.rating, size: 12),
                  ],
                ),
              ),
              Text(review.createdAt.toRelative,
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 11.5, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 11),
          Text(review.comment,
              style: GoogleFonts.hankenGrotesk(
                  fontSize: 14,
                  height: 1.55,
                  color: isDark
                      ? AppColors.onSurfaceDark
                      : const Color(0xFF4A3A2C))),
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                for (final img in review.images.take(3))
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 82,
                        height: 82,
                        child: AppNetworkImage(url: img, fit: BoxFit.cover),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating, required this.size});
  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(i <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: i <= rating
                  ? AppColors.secondary
                  : const Color(0xFFD2C4B2)),
      ],
    );
  }
}

class _WriteBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      left: 16,
      right: 16,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color:
                      isDark ? const Color(0xD11C130D) : const Color(0xD1F7F1EA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isDark
                          ? AppColors.secondary.withValues(alpha: 0.22)
                          : const Color(0xB3FFFFFF)),
                ),
                child: Pressable(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                            'Review a delivered item from your orders to add yours'),
                      ),
                    );
                    context.goNamed(RouteNames.orders);
                  },
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 17,
                            color: isDark
                                ? AppColors.onPrimaryDark
                                : const Color(0xFFF0C888)),
                        const SizedBox(width: 9),
                        Text('Write a review',
                            style: GoogleFonts.hankenGrotesk(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.onPrimaryDark
                                    : AppColors.onPrimary)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty ────────────────────────────────────────────────────────────────────
class _EmptyReviews extends StatelessWidget {
  const _EmptyReviews({required this.topInset});
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, topInset + 116, 18, 108),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceGlowDark : AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border:
                  isDark ? Border.all(color: AppColors.amberBorderDark) : null,
              boxShadow: isDark ? null : AppColors.cardShadow,
            ),
            child: Row(
              children: [
                Text('—',
                    style: GoogleFonts.fraunces(
                        fontSize: 44,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted)),
                const SizedBox(width: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Stars(rating: 0, size: 15),
                    const SizedBox(height: 6),
                    Text('Not rated yet',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 34),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceGlowDark
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                      color: (isDark
                              ? AppColors.onBackgroundDark
                              : AppColors.onBackground)
                          .withValues(alpha: 0.22)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: isDark ? null : AppColors.cardShadow,
                      ),
                      child: const Icon(Icons.star_rounded,
                          size: 27, color: Color(0xFFB87423)),
                    ),
                    const SizedBox(height: 16),
                    Text('No reviews yet',
                        style: GoogleFonts.fraunces(
                            fontSize: 21, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 9),
                    Text(
                      "You've tried it — tell the next person how it tastes. Be the first to review this brew.",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    Pressable(
                      onTap: () => context.goNamed(RouteNames.orders),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 13),
                        decoration: BoxDecoration(
                          color:
                              isDark ? AppColors.primaryDark : AppColors.primary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 17,
                                color: isDark
                                    ? AppColors.onPrimaryDark
                                    : const Color(0xFFF0C888)),
                            const SizedBox(width: 9),
                            Text('Write the first review',
                                style: GoogleFonts.hankenGrotesk(
                                    fontSize: 14.5,
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
            ),
          ),
        ],
      ),
    );
  }
}
