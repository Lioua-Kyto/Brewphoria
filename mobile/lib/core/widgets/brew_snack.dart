import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brewphoria/core/constants/app_colors.dart';

enum BrewSnackKind { success, info, error }

/// Frosted-glass toast in the brand language (design §6 — glass toast, not the
/// platform default), with matching haptics. Use for add-to-cart, undo, and
/// friendly errors instead of a raw [SnackBar].
void showBrewSnack(
  BuildContext context,
  String message, {
  IconData? icon,
  BrewSnackKind kind = BrewSnackKind.success,
}) {
  switch (kind) {
    case BrewSnackKind.success:
      HapticFeedback.mediumImpact();
    case BrewSnackKind.info:
      HapticFeedback.selectionClick();
    case BrewSnackKind.error:
      HapticFeedback.heavyImpact();
  }

  final isDark = Theme.of(context).brightness == Brightness.dark;
  final accent = kind == BrewSnackKind.error ? AppColors.error : AppColors.secondary;
  final resolvedIcon = icon ??
      switch (kind) {
        BrewSnackKind.success => Icons.check_rounded,
        BrewSnackKind.info => Icons.info_outline_rounded,
        BrewSnackKind.error => Icons.error_outline_rounded,
      };

  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: Duration(milliseconds: kind == BrewSnackKind.error ? 3200 : 2200),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.surfaceDark : Colors.white)
                    .withValues(alpha: isDark ? 0.72 : 0.78),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.55)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(resolvedIcon, size: 18, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      message,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.onBackgroundDark
                            : AppColors.onBackground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
}
