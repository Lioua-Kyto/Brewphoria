import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brewphoria/core/constants/app_colors.dart';

/// The one kinetic-type moment (design §6): the brand logo scales in, then the
/// Fraunces "BrewPhoria" wordmark reveals letter-by-letter and an underline
/// sweeps, before handing off to the app. Plays once on cold start.
class BrandSplash extends StatefulWidget {
  const BrandSplash({required this.onComplete, super.key});

  final VoidCallback onComplete;

  @override
  State<BrandSplash> createState() => _BrandSplashState();
}

class _BrandSplashState extends State<BrandSplash>
    with SingleTickerProviderStateMixin {
  static const _word = 'BrewPhoria';
  late final AnimationController _c;
  late final Animation<double> _logo;
  late final Animation<double> _underline;
  late final Animation<double> _tagline;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();

    _logo = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    );
    _underline = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.62, 0.82, curve: Curves.easeOutCubic),
    );
    _tagline = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.72, 0.95, curve: Curves.easeOut),
    );

    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _letterT(int i) {
    // Each letter reveals across a short window, staggered left-to-right,
    // sitting between the cup fill and the underline sweep.
    const start = 0.34;
    const span = 0.30;
    final step = span / _word.length;
    final begin = start + i * step;
    return Curves.easeOutCubic.transform(
      ((_c.value - begin) / 0.16).clamp(0.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C130D), Color(0xFF2A1D13)],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: _logo.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.7 + 0.3 * _logo.value.clamp(0.0, 1.0),
                      child: Image.asset(
                        'assets/icon/logo_amber.png',
                        width: 116,
                        height: 116,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < _word.length; i++)
                        Opacity(
                          opacity: _letterT(i),
                          child: Transform.translate(
                            offset: Offset(0, 16 * (1 - _letterT(i))),
                            child: Text(
                              _word[i],
                              style: GoogleFonts.fraunces(
                                fontSize: 40,
                                height: 1,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onBackgroundDark,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 2,
                    width: 120 * _underline.value,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        colors: [Color(0x00D98E32), AppColors.secondary, Color(0x00D98E32)],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Opacity(
                    opacity: _tagline.value,
                    child: Text(
                      'Crafted, not rushed',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 13,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
