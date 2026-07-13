import 'package:flutter/material.dart';

/// Fades + slides its child in on first mount, with an optional [delay] for
/// staggered list entrances. Reduced-motion → appears instantly. A small
/// building block for the app-wide entrance choreography.
///
/// Pass a stable [playOnceId] for items in a lazily-built list (e.g. a scrolling
/// grid): the entrance then plays only the FIRST time that id appears and shows
/// instantly on every later remount — so scrolling a card off-screen and back
/// doesn't replay the fade.
class Entrance extends StatefulWidget {
  const Entrance({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 460),
    this.offset = const Offset(0, 0.10),
    this.playOnceId,
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final String? playOnceId;

  /// Ids whose entrance has already played this session.
  static final Set<String> _played = {};

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: widget.offset,
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    final id = widget.playOnceId;
    if (id != null && Entrance._played.contains(id)) {
      _c.value = 1; // already animated once — appear instantly
      return;
    }
    if (id != null) Entrance._played.add(id);

    if (MediaQuery.of(context).disableAnimations) {
      _c.value = 1;
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
