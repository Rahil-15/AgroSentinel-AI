import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Renders a beautiful crossfading ambient background using the 3D assets,
/// a low-opacity scanning grid overlay, and a glassmorphism blur layer.
class AmbientBackground extends StatelessWidget {
  final int activeIndex;
  final Widget child;

  const AmbientBackground({
    super.key,
    required this.activeIndex,
    required this.child,
  });

  static const List<String> _bgAssets = [
    'assets/images/hero_3d_scan.jpg',
    'assets/images/leaf_3d_disease.jpg',
    'assets/images/radar_3d_alert.jpg',
    'assets/images/radar_3d_alert.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    // Map index to specific background asset safely
    final bgAsset = _bgAssets[activeIndex.clamp(0, _bgAssets.length - 1)];

    return Stack(
      children: [
        // ── 1. Image Background with Animated Switcher ─────────────────
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.05, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: SizedBox(
              key: ValueKey<String>(bgAsset),
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                bgAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.background,
                ),
              ),
            ),
          ),
        ),

        // ── 2. Grid Line Overlay ──────────────────────────────────────
        const Positioned.fill(
          child: _GridOverlay(),
        ),

        // ── 3. Glassmorphism Blur & Light Scrim ────────────────────────
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
            child: Container(
              color: AppColors.background.withValues(alpha: 0.82),
            ),
          ),
        ),

        // ── 4. Main Screen Content ────────────────────────────────────
        Positioned.fill(child: child),
      ],
    );
  }
}

class _GridOverlay extends StatelessWidget {
  const _GridOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.healthy.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    const double step = 60.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
