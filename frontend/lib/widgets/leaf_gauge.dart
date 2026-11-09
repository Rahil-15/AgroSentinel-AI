import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The signature AgroSentinel component.
///
/// An organic leaf silhouette (custom path, teardrop/leaf-shaped, ~74×92
/// internal coordinate space) that fills from the stem upward with the
/// state colour (green / amber / red by value). A subtle centre vein line
/// runs through the middle. The percentage is centred in IBM Plex Mono.
///
/// Usage:
/// ```dart
/// LeafGauge(
///   value: result.confidence,         // 0.0 – 1.0
///   label: 'Confidence',
///   color: result.isHealthy ? AppColors.healthy : AppColors.disease,
/// )
/// ```
class LeafGauge extends StatefulWidget {
  final double value;   // 0.0 – 1.0
  final String label;
  final Color color;
  final double size;    // diameter of the bounding square

  const LeafGauge({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    this.size = 110,
  });

  @override
  State<LeafGauge> createState() => _LeafGaugeState();
}

class _LeafGaugeState extends State<LeafGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(LeafGauge old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = (widget.value * 100).clamp(0, 100);
    final pctStr =
        pct == pct.roundToDouble() ? '${pct.toInt()}%' : '${pct.toStringAsFixed(1)}%';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _anim,
          builder: (_, __) {
            final fillValue = widget.value * _anim.value;
            return CustomPaint(
              size: Size(widget.size, widget.size * 92 / 74),
              painter: _LeafPainter(
                fillValue: fillValue.clamp(0.0, 1.0),
                color: widget.color,
              ),
              child: SizedBox(
                width: widget.size,
                height: widget.size * 92 / 74,
                child: Center(
                  child: Padding(
                    // nudge text slightly toward the leaf centre
                    padding: EdgeInsets.only(top: widget.size * 0.12),
                    child: Text(
                      pctStr,
                      style: AppTheme.mono(
                        size: widget.size * 0.185,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ).copyWith(
                        shadows: const [
                          Shadow(
                            color: Color(0x99000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: AppTheme.ui(
            size: 12,
            weight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Draws the leaf outline + fill + centre vein line.
class _LeafPainter extends CustomPainter {
  final double fillValue; // 0.0 – 1.0, how full the leaf is
  final Color color;

  const _LeafPainter({required this.fillValue, required this.color});

  Path _buildLeafPath(double w, double h) {
    final scaleX = w / 74;
    final scaleY = h / 92;

    final p = Path();
    // Start at tip (top centre)
    p.moveTo(37 * scaleX, 0);
    // Right side — cubic curves sweeping outward then in to stem
    p.cubicTo(
      60 * scaleX, 10 * scaleY, // cp1
      74 * scaleX, 30 * scaleY, // cp2
      65 * scaleX, 55 * scaleY, // end of first right curve
    );
    p.cubicTo(
      58 * scaleX, 72 * scaleY,
      48 * scaleX, 80 * scaleY,
      37 * scaleX, 88 * scaleY, // bottom of leaf body
    );
    // Left side — mirror
    p.cubicTo(
      26 * scaleX, 80 * scaleY,
      16 * scaleX, 72 * scaleY,
      9 * scaleX, 55 * scaleY,
    );
    p.cubicTo(
      0 * scaleX, 30 * scaleY,
      14 * scaleX, 10 * scaleY,
      37 * scaleX, 0,
    );
    p.close();

    // Stem nub
    p.moveTo(33 * scaleX, 88 * scaleY);
    p.quadraticBezierTo(
      37 * scaleX, 94 * scaleY,
      41 * scaleX, 88 * scaleY,
    );
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final scaleX = w / 74;
    final scaleY = h / 92;

    final leafPath = _buildLeafPath(w, h);

    // ── Track clip (clip canvas to leaf shape) ───────────────────────
    canvas.save();
    canvas.clipPath(leafPath);

    // Background (empty fill — 15% opacity of colour)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = color.withValues(alpha: 0.15),
    );

    // Fill from stem (bottom) upward
    final fillHeight = h * (1 - fillValue);
    canvas.drawRect(
      Rect.fromLTWH(0, fillHeight, w, h - fillHeight),
      Paint()..color = color,
    );

    canvas.restore();

    // ── Leaf outline ─────────────────────────────────────────────────
    canvas.drawPath(
      leafPath,
      Paint()
        ..color = color.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // ── Centre vein line ─────────────────────────────────────────────
    // Runs from tip to ~80% down, drawn on top of everything
    final veinPath = Path()
      ..moveTo(37 * scaleX, 4 * scaleY)
      ..quadraticBezierTo(
        38 * scaleX, 45 * scaleY,
        37 * scaleX, 78 * scaleY,
      );

    canvas.drawPath(
      veinPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );

    // ── Subtle branching veins ───────────────────────────────────────
    for (final (startFrac, endFrac, side) in [
      (0.25, 0.18, 1.0),
      (0.4, 0.30, 1.0),
      (0.55, 0.42, 1.0),
      (0.25, 0.18, -1.0),
      (0.4, 0.30, -1.0),
      (0.55, 0.42, -1.0),
    ]) {
      final startY = h * startFrac;
      final endY = h * endFrac;
      final startX = 37 * scaleX;
      final endX = startX + side * w * 0.22;
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.2)
          ..strokeWidth = 0.8
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_LeafPainter old) =>
      old.fillValue != fillValue || old.color != color;
}

/// Horizontal row of two LeafGauges, used on the Result screen.
class LeafGaugePair extends StatelessWidget {
  final double confidence;
  final double infectedPct; // 0–100
  final bool isHealthy;
  final String severity;

  const LeafGaugePair({
    super.key,
    required this.confidence,
    required this.infectedPct,
    required this.isHealthy,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final confColor = isHealthy ? AppColors.healthy : AppColors.disease;
    Color infColor;
    if (infectedPct < 10) {
      infColor = AppColors.healthy;
    } else if (infectedPct < 35) {
      infColor = AppColors.amber;
    } else {
      infColor = AppColors.disease;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        LeafGauge(
          value: confidence,
          label: 'Confidence',
          color: confColor,
          size: 92,
        ),
        if (!isHealthy)
          LeafGauge(
            value: (infectedPct / 100).clamp(0.0, 1.0),
            label: 'Infected area',
            color: infColor,
            size: 92,
          ),
      ],
    );
  }
}
