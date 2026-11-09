import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Nature-themed atmospheric gradient background mesh.
///
/// Features deep organic emerald aura, warm sunrise gold, and earthy amber
/// blooms behind frosted glass panels.
class GradientMesh extends StatelessWidget {
  const GradientMesh({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: _MeshPainterWidget(),
    );
  }
}

class _MeshPainterWidget extends StatelessWidget {
  const _MeshPainterWidget();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MeshPainter());
  }
}

class _MeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // ── Deep Forest Vignette Base ─────────────────────────────────────
    final baseRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.4),
        radius: 1.4,
        colors: [
          Color(0xFF0F2618), // Deep emerald core
          Color(0xFF0A1810), // Forest mid
          Color(0xFF040A06), // Root deep border
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(baseRect);
    canvas.drawRect(baseRect, bgPaint);

    // ── 1. Top Radiant Emerald Aurora ─────────────────────────────────
    _blob(
      canvas,
      center: Offset(size.width * 0.45, size.height * 0.18),
      radius: size.width * 0.75,
      color: AppColors.emerald.withValues(alpha: 0.18),
    );

    // ── 2. Upper-Right Warm Gold Bloom ────────────────────────────────
    _blob(
      canvas,
      center: Offset(size.width * 1.05, size.height * 0.35),
      radius: size.width * 0.65,
      color: AppColors.gold.withValues(alpha: 0.15),
    );

    // ── 3. Lower-Left Earthy Amber Glow ───────────────────────────────
    _blob(
      canvas,
      center: Offset(size.width * -0.15, size.height * 0.75),
      radius: size.width * 0.70,
      color: AppColors.amber.withValues(alpha: 0.12),
    );

    // ── 4. Bottom Center Organic Harvest Pulse ────────────────────────
    _blob(
      canvas,
      center: Offset(size.width * 0.5, size.height * 1.02),
      radius: size.width * 0.55,
      color: AppColors.emerald.withValues(alpha: 0.14),
    );
  }

  void _blob(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
