import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Rock-solid canvas-drawn vector badges for AgroSentinel.
/// These painters render directly to the 2D canvas on all platforms (Web, Mobile, Desktop)
/// with 100% reliability, without depending on external font files.

enum AgroVectorType {
  leaf,
  camera,
  warning,
  bug,
  medical,
  settings,
}

class AgroVectorBadge extends StatelessWidget {
  final AgroVectorType type;
  final double size;
  final Color backgroundColor;
  final Color iconColor;
  final double iconSize;

  const AgroVectorBadge({
    super.key,
    required this.type,
    this.size = 40,
    required this.backgroundColor,
    this.iconColor = Colors.white,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.45),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: iconSize,
          height: iconSize,
          child: CustomPaint(
            painter: _AgroVectorPainter(type: type, color: iconColor),
          ),
        ),
      ),
    );
  }
}

class _AgroVectorPainter extends CustomPainter {
  final AgroVectorType type;
  final Color color;

  _AgroVectorPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    switch (type) {
      // ── 1. Camera / Scanner ──────────────────────────────────────────
      case AgroVectorType.camera:
        // Main camera body
        final rrect = RRect.fromRectAndRadius(
          Rect.fromLTWH(0, h * 0.22, w, h * 0.72),
          Radius.circular(w * 0.18),
        );
        canvas.drawRRect(rrect, strokePaint);

        // Top flash notch
        final topPath = Path()
          ..moveTo(w * 0.32, h * 0.22)
          ..lineTo(w * 0.38, h * 0.06)
          ..lineTo(w * 0.62, h * 0.06)
          ..lineTo(w * 0.68, h * 0.22)
          ..close();
        canvas.drawPath(topPath, fillPaint);

        // Center lens circle
        canvas.drawCircle(Offset(w * 0.5, h * 0.58), w * 0.22, strokePaint);
        // Inner lens pupil
        canvas.drawCircle(Offset(w * 0.5, h * 0.58), w * 0.08, fillPaint);
        break;

      // ── 2. Warning Exclamation ───────────────────────────────────────
      case AgroVectorType.warning:
        // Outer warning triangle
        final tri = Path()
          ..moveTo(w * 0.5, h * 0.06)
          ..lineTo(w * 0.96, h * 0.88)
          ..lineTo(w * 0.04, h * 0.88)
          ..close();
        canvas.drawPath(tri, strokePaint);

        // Exclamation vertical line
        canvas.drawLine(
          Offset(w * 0.5, h * 0.34),
          Offset(w * 0.5, h * 0.62),
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.14
            ..strokeCap = StrokeCap.round,
        );

        // Exclamation dot
        canvas.drawCircle(Offset(w * 0.5, h * 0.76), w * 0.07, fillPaint);
        break;

      // ── 3. Disease Bug / Microbe ─────────────────────────────────────
      case AgroVectorType.bug:
        // Bug body oval
        final bodyRect = Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.56),
          width: w * 0.48,
          height: h * 0.56,
        );
        canvas.drawOval(bodyRect, fillPaint);

        // Head semi-circle
        final headRect = Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.26),
          width: w * 0.36,
          height: h * 0.26,
        );
        canvas.drawOval(headRect, fillPaint);

        // Center division line
        canvas.drawLine(
          Offset(w * 0.5, h * 0.32),
          Offset(w * 0.5, h * 0.82),
          Paint()
            ..color = Colors.black.withValues(alpha: 0.35)
            ..strokeWidth = w * 0.07
            ..style = PaintingStyle.stroke,
        );

        // 6 Legs
        final legPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.09
          ..strokeCap = StrokeCap.round;

        // Top legs
        canvas.drawLine(Offset(w * 0.28, h * 0.42), Offset(w * 0.04, h * 0.34), legPaint);
        canvas.drawLine(Offset(w * 0.72, h * 0.42), Offset(w * 0.96, h * 0.34), legPaint);

        // Middle legs
        canvas.drawLine(Offset(w * 0.25, h * 0.58), Offset(w * 0.02, h * 0.58), legPaint);
        canvas.drawLine(Offset(w * 0.75, h * 0.58), Offset(w * 0.98, h * 0.58), legPaint);

        // Bottom legs
        canvas.drawLine(Offset(w * 0.28, h * 0.72), Offset(w * 0.06, h * 0.84), legPaint);
        canvas.drawLine(Offset(w * 0.72, h * 0.72), Offset(w * 0.94, h * 0.84), legPaint);
        break;

      // ── 4. Medical Cross / Healing ───────────────────────────────────
      case AgroVectorType.medical:
        // Medical cross
        final armW = w * 0.28;
        final cross = Path()
          ..moveTo(w * 0.5 - armW * 0.5, h * 0.08)
          ..lineTo(w * 0.5 + armW * 0.5, h * 0.08)
          ..lineTo(w * 0.5 + armW * 0.5, h * 0.5 - armW * 0.5)
          ..lineTo(w * 0.92, h * 0.5 - armW * 0.5)
          ..lineTo(w * 0.92, h * 0.5 + armW * 0.5)
          ..lineTo(w * 0.5 + armW * 0.5, h * 0.5 + armW * 0.5)
          ..lineTo(w * 0.5 + armW * 0.5, h * 0.92)
          ..lineTo(w * 0.5 - armW * 0.5, h * 0.92)
          ..lineTo(w * 0.5 - armW * 0.5, h * 0.5 + armW * 0.5)
          ..lineTo(w * 0.08, h * 0.5 + armW * 0.5)
          ..lineTo(w * 0.08, h * 0.5 - armW * 0.5)
          ..lineTo(w * 0.5 - armW * 0.5, h * 0.5 - armW * 0.5)
          ..close();
        canvas.drawPath(cross, fillPaint);
        break;

      // ── 5. Organic Leaf ──────────────────────────────────────────────
      case AgroVectorType.leaf:
        final leaf = Path()
          ..moveTo(w * 0.12, h * 0.88)
          ..quadraticBezierTo(w * 0.08, h * 0.38, w * 0.88, h * 0.12)
          ..quadraticBezierTo(w * 0.88, h * 0.68, w * 0.12, h * 0.88)
          ..close();
        canvas.drawPath(leaf, fillPaint);

        // Central vein
        canvas.drawLine(
          Offset(w * 0.12, h * 0.88),
          Offset(w * 0.72, h * 0.28),
          Paint()
            ..color = Colors.black.withValues(alpha: 0.25)
            ..strokeWidth = w * 0.08
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
        );
        break;

      // ── 6. Settings Cog Gear ─────────────────────────────────────────
      case AgroVectorType.settings:
        final center = Offset(w * 0.5, h * 0.5);
        final r = w * 0.32;
        // Outer cog teeth
        for (var i = 0; i < 6; i++) {
          final angle = i * (math.pi / 3);
          final toothOffset = Offset(
            center.dx + math.cos(angle) * (r + w * 0.10),
            center.dy + math.sin(angle) * (r + w * 0.10),
          );
          canvas.drawCircle(toothOffset, w * 0.09, fillPaint);
        }
        canvas.drawCircle(center, r, strokePaint);
        canvas.drawCircle(center, w * 0.12, fillPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _AgroVectorPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.color != color;
}
