import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brewphoria/core/constants/app_colors.dart';
import 'package:brewphoria/core/constants/app_text_styles.dart';
import 'package:brewphoria/core/router/route_names.dart';
import 'package:brewphoria/core/storage/hive_service.dart';
import 'package:brewphoria/core/widgets/product_cutout.dart';
import 'package:brewphoria/core/widgets/pressable.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    try {
      HiveService.userPrefsBox.put(HiveKeys.onboardingDone, true);
    } catch (_) {}
    if (mounted) context.go(RoutePaths.login);
  }

  void _next() {
    if (_page == 0) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic);
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            children: [
              _BrandPage(onNext: _next),
              _ValuePage(onStart: _finish),
            ],
          ),
          // Skip
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: Pressable(
              onTap: _finish,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: _page == 0
                      ? const Color(0x1AF7F1EA)
                      : const Color(0x0F3B2417),
                  borderRadius: BorderRadius.circular(100),
                  border: _page == 0
                      ? Border.all(color: const Color(0x29F7F1EA))
                      : null,
                ),
                child: Text('Skip',
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _page == 0
                            ? const Color(0xFFEADFD0)
                            : AppColors.textSecondary)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.index, this.onDark = false});
  final int index;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    Color inactive =
        onDark ? const Color(0x47F7F1EA) : const Color(0x383B2417);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 2; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: i == index ? 26 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == index ? AppColors.secondary : inactive,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Page 1 · brand moment ────────────────────────────────────────────────────
class _BrandPage extends StatelessWidget {
  const _BrandPage({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.4),
          radius: 1.1,
          colors: [Color(0xFF33241A), Color(0xFF241811), Color(0xFF160F0A)],
          stops: [0, 0.55, 1],
        ),
      ),
      child: Stack(
        children: [
          // amber glow — multi-stop for a smooth (band-free) falloff on dark
          Positioned(
            top: 90,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 340,
                height: 340,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x45D98E32),
                      Color(0x28D98E32),
                      Color(0x0DD98E32),
                      Color(0x00D98E32),
                    ],
                    stops: [0.0, 0.42, 0.7, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // floating product
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.rotate(
                angle: -0.07,
                child: const SizedBox(
                  width: 290,
                  height: 320,
                  child: ProductCutout(
                    url: 'assets/img/beans-box.png',
                    shadowColor: Color(0x8C000000),
                    shadowOffset: Offset(0, 34),
                    shadowBlur: 30,
                  ),
                ),
              ),
            ),
          ),
          // bottom brand block
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(30, 40, 30, bottom + 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00160F0A), Color(0xB8160F0A), Color(0xFF160F0A)],
                  stops: [0, 0.42, 1],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('SPECIALTY COFFEE · ON DEMAND',
                      style: GoogleFonts.hankenGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.4,
                          color: AppColors.secondary)),
                  const SizedBox(height: 14),
                  Text('BrewPhoria',
                      style: AppTextStyles.wordmark(58,
                          color: AppColors.onBackgroundDark)),
                  const SizedBox(height: 16),
                  Text('Analog warmth, measured to the gram.',
                      style: GoogleFonts.fraunces(
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          height: 1.35,
                          color: const Color(0xFFC9B7A3))),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _Dots(index: 0, onDark: true),
                      Pressable(
                        onTap: onNext,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.secondary
                                      .withValues(alpha: 0.4),
                                  blurRadius: 28,
                                  offset: const Offset(0, 12)),
                            ],
                          ),
                          child: const Icon(Icons.arrow_forward_rounded,
                              color: Color(0xFF241812), size: 24),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 2 · value prop ──────────────────────────────────────────────────────
class _ValuePage extends StatelessWidget {
  const _ValuePage({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      color: const Color(0xFFF3EBE0),
      child: Column(
        children: [
          SizedBox(height: top + 64),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI BREW ASSISTANT',
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: const Color(0xFFB87423))),
                const SizedBox(height: 8),
                Text('Not sure what you\nwant? Just ask.',
                    style: GoogleFonts.fraunces(
                        fontSize: 29,
                        fontWeight: FontWeight.w500,
                        height: 1.08,
                        letterSpacing: -0.3,
                        color: AppColors.onBackground)),
                const SizedBox(height: 8),
                Text('Tell the barista your mood — it builds the order.',
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 13.5,
                        height: 1.55,
                        color: const Color(0xFF6E5B49))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _assistant('Morning, Maya. Something warm, iced, or a little sweet today?'),
                  const SizedBox(height: 12),
                  const _UserBubble('Warm, low sugar please'),
                  const SizedBox(height: 12),
                  _assistant("Then you'll love this — espresso-forward, a whisper of caramel.",
                      card: true),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(26, 16, 26, bottom + 30),
            child: Column(
              children: [
                const _Dots(index: 1),
                const SizedBox(height: 16),
                Pressable(
                  onTap: onStart,
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x473B2417),
                            blurRadius: 28,
                            offset: Offset(0, 12)),
                      ],
                    ),
                    child: Text('Get started',
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onPrimary)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _assistant(String text, {bool card = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const _MiniMark(),
        const SizedBox(width: 9),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 250),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 12,
                        offset: Offset(0, 3)),
                  ],
                ),
                child: Text(text,
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.onBackground)),
              ),
              if (card) ...[
                const SizedBox(height: 8),
                _miniProductCard(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniProductCard() {
    return SizedBox(
      width: 236,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 74),
            padding: const EdgeInsets.fromLTRB(66, 12, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x1A3B2417),
                    blurRadius: 16,
                    offset: Offset(0, 6)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Caramel Macchiato',
                    style: GoogleFonts.fraunces(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onBackground)),
                const SizedBox(height: 2),
                Text('Oat · light caramel',
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 12, color: const Color(0xFF9A8A78))),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r'$6.50',
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFB87423))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(100)),
                      child: Text('Add +',
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onPrimary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Positioned(
            left: -6,
            top: 0,
            bottom: 0,
            child: Center(
              child: SizedBox(
                width: 68,
                height: 68,
                child: ProductCutout(
                    url: 'assets/img/macchiato.png',
                    shadowOffset: Offset(0, 8),
                    shadowBlur: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(6),
          ),
        ),
        child: Text(text,
            style: GoogleFonts.hankenGrotesk(
                fontSize: 14, height: 1.5, color: AppColors.onPrimary)),
      ),
    );
  }
}

class _MiniMark extends StatelessWidget {
  const _MiniMark();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFE7C173), Color(0xFFB8863C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.local_cafe_rounded, size: 15, color: Colors.white),
    );
  }
}
