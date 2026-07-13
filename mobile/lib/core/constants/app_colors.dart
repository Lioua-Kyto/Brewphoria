import 'package:flutter/material.dart';

/// Design tokens pulled from `BrewPhoria System.dc.html`.
/// "Analog warmth, digital precision." — warm neutral base, one amber accent.
abstract final class AppColors {
  // ── Light theme ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF3B2417); // espresso ink
  static const Color secondary = Color(0xFFD98E32); // amber accent
  static const Color background = Color(0xFFF7F1EA); // cream base
  static const Color surface = Color(0xFFFFFFFF); // elevated product cards
  static const Color surfacePanel = Color(0xFFFBF6EF); // section panels / sheets
  static const Color error = Color(0xFFA5473B); // muted brick red
  static const Color success = Color(0xFF5A7A52); // muted forest green
  static const Color disabled = Color(0xFFB8AC9C); // warm gray
  static const Color onPrimary = Color(0xFFF7F1EA);
  static const Color onSecondary = Color(0xFF241812);
  static const Color onBackground = Color(0xFF3B2417);
  static const Color onSurface = Color(0xFF3B2417);
  static const Color onError = Color(0xFFF7F1EA);
  static const Color outline = Color(0xFFE3D8CA);
  static const Color surfaceVariant = Color(0xFFF1E7D9); // photo wells / input fill
  static const Color textSecondary = Color(0xFF7A6551);
  static const Color textMuted = Color(0xFF9A8A78);
  static const Color shimmerBase = Color(0xFFE8DDD4);
  static const Color shimmerHighlight = Color(0xFFF5F0EB);

  // ── Dark theme (purpose-built, deep browns — not inverted) ────────────────
  static const Color primaryDark = Color(0xFFD98E32); // amber does the work
  static const Color backgroundDark = Color(0xFF1C130D); // deep espresso
  static const Color surfaceDark = Color(0xFF2A1D13);
  static const Color surfaceGlowDark = Color(0xFF241812); // amber-glow cards
  static const Color onPrimaryDark = Color(0xFF241812);
  static const Color onBackgroundDark = Color(0xFFF7F1EA); // cream
  static const Color onSurfaceDark = Color(0xFFEADFD0);
  static const Color outlineDark = Color(0xFF3D2A1C);
  static const Color amberBorderDark = Color(0x24D98E32); // rgba(217,142,50,.14)
  static const Color surfaceVariantDark = Color(0xFF3A2A1E);
  static const Color textSecondaryDark = Color(0xFFB0A08D);
  static const Color shimmerBaseDark = Color(0xFF2A1D13);
  static const Color shimmerHighlightDark = Color(0xFF3A2A1E);

  // ── Warm elevation shadow (never gray) ────────────────────────────────────
  static const Color shadowWarm = Color(0x1F3B2417); // rgba(59,36,23,.12)
  static const Color shadowWarmSoft = Color(0x1A3B2417); // rgba(59,36,23,.10)

  /// Card shadow — `0 8px 24px rgba(59,36,23,.12)`.
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: shadowWarm, blurRadius: 24, offset: Offset(0, 8)),
  ];

  /// Section-panel shadow — `0 10px 30px rgba(59,36,23,.10)`.
  static const List<BoxShadow> panelShadow = [
    BoxShadow(color: shadowWarmSoft, blurRadius: 30, offset: Offset(0, 10)),
  ];

  /// Floating product image well — tighter, warmer `0 16px 26px rgba(59,36,23,.18)`.
  static const List<BoxShadow> floatingImageShadow = [
    BoxShadow(color: Color(0x2E3B2417), blurRadius: 26, offset: Offset(0, 16)),
  ];

  // ── Loyalty tier colors ───────────────────────────────────────────────────
  static const Color tierBronze = Color(0xFFCD7F32);
  static const Color tierSilver = Color(0xFFC0C0C0);
  static const Color tierGold = Color(0xFFC79A4B);
  static const Color tierPlatinum = Color(0xFFE5E4E2);

  // ── Order status colors (warm-tuned) ──────────────────────────────────────
  static const Color statusPending = Color(0xFFD98E32);
  static const Color statusConfirmed = Color(0xFF3B82F6);
  static const Color statusPreparing = Color(0xFF8B5CF6);
  static const Color statusOutForDelivery = Color(0xFF06B6D4);
  static const Color statusDelivered = Color(0xFF5A7A52);
  static const Color statusCancelled = Color(0xFFA5473B);
  static const Color statusRefunded = Color(0xFF7A6551);
}
