import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coffee_card/core/constants/app_colors.dart';
import 'package:coffee_card/core/constants/app_spacing.dart';
import 'package:coffee_card/core/constants/app_text_styles.dart';
import 'package:coffee_card/core/widgets/product_cutout.dart';
import 'package:coffee_card/core/widgets/pressable.dart';

/// Signature Pattern 3.1 — the floating product card. The product photo lifts
/// out of a warm cream "photo well" that escapes the card's top edge with its
/// own tighter shadow, and Hero-animates into the product detail screen.
class FloatingProductCard extends StatelessWidget {
  const FloatingProductCard({
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.heroTag,
    this.categoryLabel,
    this.onTap,
    this.onAdd,
    this.imageKey,
    super.key,
  });

  final String imageUrl;
  final String name;
  final String price;
  final String heroTag;
  final String? categoryLabel;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final GlobalKey? imageKey;

  static const double _imageHeight = 116;
  static const double _cardTop = 48;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── White card body ──
          Padding(
            padding: const EdgeInsets.only(top: _cardTop),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 74, 14, 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceGlowDark : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: isDark
                    ? Border.all(color: AppColors.amberBorderDark)
                    : null,
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (categoryLabel != null)
                    Text(
                      categoryLabel!.toUpperCase(),
                      style: AppTextStyles.overline.copyWith(fontSize: 10),
                    ),
                  const SizedBox(height: 3),
                  // Reserve two lines' worth of height so one- and two-line
                  // names produce identically sized cards (keeps the grid rows
                  // aligned regardless of name length).
                  SizedBox(
                    height: 35,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.fraunces(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w500,
                          height: 1.12,
                          color: isDark
                              ? AppColors.onBackgroundDark
                              : AppColors.onBackground,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.onBackgroundDark
                              : AppColors.onBackground,
                        ),
                      ),
                      if (onAdd != null)
                        Pressable(
                          onTap: onAdd,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primary,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 20,
                              color: isDark
                                  ? AppColors.onPrimaryDark
                                  : AppColors.onPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Free-floating transparent cutout (escapes the card top) ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                key: imageKey,
                height: _imageHeight,
                width: 128,
                child: Hero(
                  tag: heroTag,
                  createRectTween: (a, b) =>
                      MaterialRectArcTween(begin: a, end: b),
                  child: ProductCutout(url: imageUrl, decodeWidth: 320),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
