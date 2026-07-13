import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coffee_card/core/constants/app_colors.dart';
import 'package:coffee_card/core/constants/app_spacing.dart';
import 'package:coffee_card/core/constants/app_text_styles.dart';

/// Central app theme built from the design tokens in [AppColors] /
/// [AppTextStyles]. Fraunces display · Hanken Grotesk UI.
abstract final class AppTheme {
  static ThemeData build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? AppColors.primaryDark : AppColors.primary,
      onPrimary: isDark ? AppColors.onPrimaryDark : AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      error: AppColors.error,
      onError: AppColors.onError,
      surface: isDark ? AppColors.surfaceDark : AppColors.surface,
      onSurface: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
      outline: isDark ? AppColors.outlineDark : AppColors.outline,
    );

    final baseText = GoogleFonts.hankenGroteskTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ).apply(
      bodyColor: isDark ? AppColors.onBackgroundDark : AppColors.onBackground,
      displayColor: isDark ? AppColors.onBackgroundDark : AppColors.onBackground,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      textTheme: baseText,
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.background,
        foregroundColor:
            isDark ? AppColors.onBackgroundDark : AppColors.onBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        indicatorColor: isDark
            ? AppColors.primaryDark.withValues(alpha: 0.15)
            : AppColors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.shadowWarm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        hintStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          borderSide: BorderSide(
            color: isDark ? AppColors.primaryDark : AppColors.primary,
            width: 1.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
          foregroundColor:
              isDark ? AppColors.onPrimaryDark : AppColors.onPrimary,
          disabledBackgroundColor: AppColors.disabled,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
          elevation: 0,
          textStyle: AppTextStyles.buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
          side: BorderSide(
              color: isDark ? AppColors.primaryDark : AppColors.primary),
          textStyle: AppTextStyles.buttonText.copyWith(
              color: isDark ? AppColors.primaryDark : AppColors.primary),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        selectedColor: isDark ? AppColors.primaryDark : AppColors.primary,
        side:
            BorderSide(color: isDark ? AppColors.outlineDark : AppColors.outline),
        labelStyle: AppTextStyles.labelSmall,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.outlineDark : AppColors.outline,
        thickness: 1,
      ),
    );
  }
}
