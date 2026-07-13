import 'package:flutter/material.dart';

/// Tactile press feedback — scales the child down on press (design uses
/// `transform:scale(.9)` on buttons and quantity controls). Respects
/// reduced-motion by falling back to no scale.
class Pressable extends StatefulWidget {
  const Pressable({
    required this.child,
    this.onTap,
    this.scale = 0.92,
    this.duration = const Duration(milliseconds: 120),
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final Duration duration;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down && !reduceMotion ? widget.scale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
