import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A transparent product PNG rendered as a free-floating cutout with a soft,
/// silhouette-following drop shadow (design 3.1 — `filter: drop-shadow(...)`).
/// No background/well; the shadow follows the image's alpha, not a box.
class ProductCutout extends StatelessWidget {
  const ProductCutout({
    required this.url,
    this.fit = BoxFit.contain,
    this.shadowColor = const Color(0x4D3B2417), // warm, rgba(59,36,23,.30)
    this.shadowBlur = 16,
    this.shadowOffset = const Offset(0, 14),
    this.decodeWidth,
    super.key,
  });

  final String url;
  final BoxFit fit;
  final Color shadowColor;
  final double shadowBlur;
  final Offset shadowOffset;

  /// Target decode width in physical pixels. Leave null for the full-res hero;
  /// pass a card-sized value (e.g. 320) in lists so the ~928 px catalog PNGs
  /// aren't decoded twice (image + shadow) at full resolution per tile.
  final int? decodeWidth;

  ImageProvider get _provider {
    final ImageProvider base =
        url.startsWith('assets/') ? AssetImage(url) : CachedNetworkImageProvider(url);
    return ResizeImage.resizeIfNeeded(decodeWidth, null, base);
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const SizedBox.shrink();
    final image = Image(image: _provider, fit: fit);
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: Transform.translate(
              offset: shadowOffset,
              child: ImageFiltered(
                imageFilter:
                    ImageFilter.blur(sigmaX: shadowBlur, sigmaY: shadowBlur),
                child: Image(
                  image: _provider,
                  fit: fit,
                  color: shadowColor,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
          ),
          image,
        ],
      ),
    );
  }
}
