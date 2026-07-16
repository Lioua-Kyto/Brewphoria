import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brewphoria/core/constants/app_colors.dart';

/// Type scale from `BrewPhoria System.dc.html`:
/// Fraunces (display / wordmark) · Hanken Grotesk (UI / body).
abstract final class AppTextStyles {
  // ── Display / headers — Fraunces ──────────────────────────────────────────
  // NOTE: no baked color — these inherit the ambient DefaultTextStyle so they
  // adapt to light/dark automatically. Pass a color via copyWith when needed.
  static TextStyle displayLarge = GoogleFonts.fraunces(
    fontSize: 32,
    fontWeight: FontWeight.w500,
    height: 1.1,
    letterSpacing: -0.3,
  );

  static TextStyle displayMedium = GoogleFonts.fraunces(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    height: 1.15,
    letterSpacing: -0.3,
  );

  static TextStyle headlineLarge = GoogleFonts.fraunces(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static TextStyle headlineMedium = GoogleFonts.fraunces(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  static TextStyle headlineSmall = GoogleFonts.fraunces(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  /// The approved wordmark: Fraunces Regular, display optical size, tight
  /// tracking (~-1.8%). Inherits theme color unless [color] is given.
  static TextStyle wordmark(double size, {Color? color}) => GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color,
        height: 0.94,
        letterSpacing: size * -0.018,
      );

  // ── Body / UI — Hanken Grotesk ────────────────────────────────────────────
  static TextStyle bodyLarge = GoogleFonts.hankenGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.hankenGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.hankenGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle labelLarge = GoogleFonts.hankenGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static TextStyle labelMedium = GoogleFonts.hankenGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = GoogleFonts.hankenGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.5,
  );

  /// Overline — uppercase, wide tracking, amber. Used above card/section titles.
  static TextStyle overline = GoogleFonts.hankenGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.secondary,
    height: 1.4,
    letterSpacing: 1.8,
  );

  static TextStyle titleLarge = GoogleFonts.hankenGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle titleMedium = GoogleFonts.hankenGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static TextStyle titleSmall = GoogleFonts.hankenGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static TextStyle priceText = GoogleFonts.hankenGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static TextStyle priceLarge = GoogleFonts.hankenGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static TextStyle captionText = GoogleFonts.hankenGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.4,
  );

  static TextStyle buttonText = GoogleFonts.hankenGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onPrimary,
    height: 1.2,
    letterSpacing: 0.3,
  );
}
