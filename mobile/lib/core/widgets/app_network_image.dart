import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:brewphoria/core/constants/app_colors.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    super.key,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  /// Target decode size in physical pixels (largest logical side × DPR), so a
  /// 928 px catalog image isn't decoded at full resolution into a small card.
  /// A single dimension keeps the aspect ratio intact.
  int? _decodeSize(BuildContext context) {
    final sides = <double>[
      if (width != null && width!.isFinite) width!,
      if (height != null && height!.isFinite) height!,
    ];
    if (sides.isEmpty) return null;
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.5;
    return (sides.reduce(math.max) * dpr).round();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final decode = _decodeSize(context);
    // Bundled asset fallback (used for placeholder art / offline preview).
    if (url.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(url,
            width: width, height: height, fit: fit, cacheWidth: decode),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: decode,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
          child: const Center(
            child: Icon(Icons.coffee, color: AppColors.textSecondary, size: 32),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
          child: const Center(
            child: Icon(Icons.broken_image_outlined, color: AppColors.textSecondary, size: 32),
          ),
        ),
      ),
    );
  }
}
