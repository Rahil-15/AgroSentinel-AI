import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Staggered fade + slide-up entrance animation.
///
/// Wrap any child to give it a smooth entrance without boilerplate.
///
/// ```dart
/// FadeSlideIn(delay: Duration(milliseconds: 150), child: MyCard());
/// ```
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double slideOffset;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 560),
    this.slideOffset = 28.0,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);

    _opacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _slide = Tween<double>(begin: widget.slideOffset, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _slide.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Convenience extension so you can write:
/// ```dart
/// MyWidget().fadeSlideIn(delay: Duration(milliseconds: 200))
/// ```
extension FadeSlideInExtension on Widget {
  Widget fadeSlideIn({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 560),
    double slideOffset = 28.0,
  }) =>
      FadeSlideIn(
        delay: delay,
        duration: duration,
        slideOffset: slideOffset,
        child: this,
      );
}

/// Convenience that wraps text in a glass-themed style.
TextStyle glassLabel({
  double size = 13,
  FontWeight weight = FontWeight.w500,
  Color color = AppColors.glassTextSecondary,
}) =>
    TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontFamily: 'Poppins',
    );
