import 'package:flutter/material.dart';

/// Signature "fly-to-cart" micro-interaction (design 3.1): a clone of the
/// product image arcs from the source card to the cart icon in the glass tab
/// bar, which then bounces its badge.
///
/// The glass tab bar registers its cart slot via [cartAnchorKey]; product
/// cards trigger [flyToCart] from their own image key.
final GlobalKey cartAnchorKey = GlobalKey();

Future<void> flyToCart({
  required BuildContext context,
  required GlobalKey sourceKey,
  required String imageUrl,
}) async {
  final overlay = Overlay.of(context);
  final targetCtx = cartAnchorKey.currentContext;
  final sourceCtx = sourceKey.currentContext;
  if (targetCtx == null || sourceCtx == null) return;

  final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  if (reduceMotion) return;

  final sourceBox = sourceCtx.findRenderObject() as RenderBox?;
  final targetBox = targetCtx.findRenderObject() as RenderBox?;
  if (sourceBox == null || targetBox == null) return;

  final start = sourceBox.localToGlobal(Offset.zero);
  final startSize = sourceBox.size;
  final end = targetBox.localToGlobal(
    targetBox.size.center(Offset.zero),
  );

  final controller = AnimationController(
    vsync: overlay,
    duration: const Duration(milliseconds: 640),
  );
  final curved = CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      return AnimatedBuilder(
        animation: curved,
        builder: (context, _) {
          final t = curved.value;
          // Arc: interpolate position, lift slightly then drop into cart.
          final dx = start.dx + (end.dx - start.dx) * t;
          final arc = -60.0 * (t < 0.5 ? t * 2 : (1 - t) * 2);
          final dy = start.dy + (end.dy - start.dy) * t + arc;
          final size = startSize.width * (1 - 0.82 * t);
          return Positioned(
            left: dx + (startSize.width - size) / 2,
            top: dy + (startSize.height - size) / 2,
            child: Opacity(
              opacity: (1 - t * 0.6).clamp(0.0, 1.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  imageUrl,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          );
        },
      );
    },
  );

  overlay.insert(entry);
  await controller.forward();
  entry.remove();
  controller.dispose();
}
