import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:brewphoria/core/constants/app_colors.dart';
import 'package:brewphoria/core/constants/app_spacing.dart';
import 'package:brewphoria/core/widgets/fly_to_cart.dart';

/// Pattern 3.2 — floating frosted-glass pill nav with a sliding ink-pill
/// active indicator (Tab A, locked). Sits inset from the screen edges and
/// floats above scrolling content.
class GlassTabBar extends StatelessWidget {
  const GlassTabBar({
    required this.currentIndex,
    required this.onTap,
    required this.cartCount,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int cartCount;

  static const _tabs = <_TabSpec>[
    _TabSpec('Shop', Icons.home_outlined, Icons.home_rounded),
    _TabSpec('Cart', Icons.shopping_bag_outlined, Icons.shopping_bag_rounded),
    _TabSpec('Orders', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
    _TabSpec('Loyalty', Icons.local_cafe_outlined, Icons.local_cafe_rounded),
    _TabSpec('Profile', Icons.person_outline_rounded, Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pillColor = isDark ? AppColors.primaryDark : AppColors.primary;
    final activeColor = isDark ? AppColors.onPrimaryDark : AppColors.onPrimary;
    final inactiveColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textMuted;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.navBarInset + 6, 0, AppSpacing.navBarInset + 6, 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
          child: BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: AppSpacing.glassBlur, sigmaY: AppSpacing.glassBlur),
            child: Container(
              height: AppSpacing.navBarPillHeight + 2,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0x9E1C130D) // rgba(28,19,13,.62)
                    : const Color(0xB8F7F1EA), // rgba(247,241,234,.72)
                borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
                border: Border.all(
                  color: isDark
                      ? const Color(0x38D98E32)
                      : const Color(0xB3FFFFFF),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? const Color(0x73000000)
                        : const Color(0x333B2417),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tabWidth = constraints.maxWidth / _tabs.length;
                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeOutBack,
                        left: tabWidth * currentIndex + 4,
                        top: 0,
                        bottom: 0,
                        width: tabWidth - 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: pillColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: pillColor.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < _tabs.length; i++)
                            Expanded(
                              child: _TabItem(
                                spec: _tabs[i],
                                selected: i == currentIndex,
                                activeColor: activeColor,
                                inactiveColor: inactiveColor,
                                cartCount: i == 1 ? cartCount : 0,
                                onTap: () => onTap(i),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.spec,
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
    required this.cartCount,
    required this.onTap,
  });

  final _TabSpec spec;
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;
  final int cartCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : inactiveColor;
    final isCart = spec.label == 'Cart';
    Widget icon = Icon(selected ? spec.activeIcon : spec.icon, size: 21, color: color);

    if (isCart) {
      icon = Stack(
        clipBehavior: Clip.none,
        children: [
          KeyedSubtree(key: cartAnchorKey, child: icon),
          if (cartCount > 0)
            Positioned(
              top: -6,
              right: -8,
              child: AnimatedScale(
                scale: 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  constraints: const BoxConstraints(minWidth: 18),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                  child: Text(
                    '$cartCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF241812),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 3),
          Text(
            spec.label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec(this.label, this.icon, this.activeIcon);
  final String label;
  final IconData icon;
  final IconData activeIcon;
}
