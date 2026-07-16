import 'package:flutter/material.dart';
import 'package:brewphoria/core/constants/app_colors.dart';

/// Signature Pattern 3.3 — the takeaway coffee cup (Cup A) whose liquid fills
/// toward a target fraction with a smooth animation. Reused at three sizes:
/// the Loyalty hero, the Product-Detail points preview, and the Cart redeem
/// card. Optional rising steam + amber glow. Reduced-motion aware.
class CoffeeCup extends StatefulWidget {
  const CoffeeCup({
    required this.fill,
    this.width = 52,
    this.height = 74,
    this.steam = false,
    this.glow = false,
    this.onLightBackground = false,
    super.key,
  });

  final double fill; // 0..1
  final double width;
  final double height;
  final bool steam;
  final bool glow;

  /// Set when the cup sits on a light surface (e.g. the empty-cart scaffold) so
  /// the silhouette outline is drawn dark enough to be visible.
  final bool onLightBackground;

  @override
  State<CoffeeCup> createState() => _CoffeeCupState();
}

class _CoffeeCupState extends State<CoffeeCup>
    with TickerProviderStateMixin {
  late final AnimationController _fillCtrl;
  late Animation<double> _fill;
  AnimationController? _steamCtrl;

  @override
  void initState() {
    super.initState();
    _fillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fill = Tween<double>(begin: 0, end: widget.fill).animate(
      CurvedAnimation(parent: _fillCtrl, curve: Curves.easeOutCubic),
    );
    if (widget.steam) {
      _steamCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3000),
      )..repeat();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _fillCtrl.value = 1;
      _steamCtrl?.stop();
    } else if (_fillCtrl.status == AnimationStatus.dismissed) {
      _fillCtrl.forward();
    }
  }

  @override
  void didUpdateWidget(CoffeeCup old) {
    super.didUpdateWidget(old);
    if (old.fill != widget.fill) {
      _fill = Tween<double>(begin: _fill.value, end: widget.fill).animate(
        CurvedAnimation(parent: _fillCtrl, curve: Curves.easeOutCubic),
      );
      _fillCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _fillCtrl.dispose();
    _steamCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width;
    final h = widget.height;
    final lidH = h * 0.12;
    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (widget.steam && _steamCtrl != null) ...[
            _Steam(controller: _steamCtrl!, left: w * 0.34, delay: 0),
            _Steam(controller: _steamCtrl!, left: w * 0.54, delay: 0.35),
          ],
          // lid
          Positioned(
            top: h * 0.08,
            left: 0,
            right: 0,
            child: Container(
              height: lidH,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFEBDFCF), Color(0xFFD9C7B0)],
                ),
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(6), bottom: Radius.circular(3)),
              ),
            ),
          ),
          // cup body + liquid
          Positioned(
            top: h * 0.08 + lidH,
            left: w * 0.05,
            right: w * 0.05,
            bottom: 0,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipPath(
                    clipper: CupClipper(),
                    child: Container(
                      color: widget.onLightBackground
                          ? const Color(0xFFEADCC7)
                          : Colors.white.withValues(alpha: 0.14),
                      child: AnimatedBuilder(
                        animation: _fill,
                        builder: (context, _) => Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: _fill.value.clamp(0.0, 1.0),
                            widthFactor: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Color(0xFFD98E32), Color(0xFFA5682F)],
                                ),
                                boxShadow: widget.glow
                                    ? [
                                        BoxShadow(
                                          color: AppColors.secondary
                                              .withValues(alpha: 0.5),
                                          blurRadius: 16,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  height: 4,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CupStroke(
                      color: widget.onLightBackground
                          ? const Color(0x333B2417)
                          : const Color(0x40F7F1EA),
                    ),
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

class _Steam extends StatelessWidget {
  const _Steam(
      {required this.controller, required this.left, required this.delay});
  final AnimationController controller;
  final double left;
  final double delay;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = ((controller.value + delay) % 1.0);
        final opacity = (t < 0.3 ? t / 0.3 : (1 - t) / 0.7).clamp(0.0, 1.0) * 0.5;
        return Positioned(
          left: left,
          top: -6 - t * 12,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 3,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFD8C7B2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Strokes the cup silhouette so it stays visible even when empty.
class _CupStroke extends CustomPainter {
  const _CupStroke({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = CupClipper().getClip(size);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _CupStroke old) => old.color != color;
}

/// Tapered takeaway-cup silhouette (wider at the top).
class CupClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width, h = size.height;
    return Path()
      ..moveTo(w * 0.06, 0)
      ..lineTo(w * 0.94, 0)
      ..lineTo(w * 0.84, h)
      ..lineTo(w * 0.16, h)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
