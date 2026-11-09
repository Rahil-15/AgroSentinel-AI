import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated leaf-shaped gauge that fills over ~1.1s on first render.
/// Renders a glowing background behind the leaf for depth/lift.
class AnimatedLeafGauge extends StatefulWidget {
  final double percent;      // 0.0 – 1.0
  final Color? gaugeColor;   // defaults based on percent
  final String? label;
  final double size;

  const AnimatedLeafGauge({
    super.key,
    required this.percent,
    this.gaugeColor,
    this.label,
    this.size = 120,
  });

  @override
  State<AnimatedLeafGauge> createState() => _AnimatedLeafGaugeState();
}

class _AnimatedLeafGaugeState extends State<AnimatedLeafGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fill;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fill = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _resolveColor() {
    if (widget.gaugeColor != null) return widget.gaugeColor!;
    if (widget.percent >= 0.7) return AppColors.disease;
    if (widget.percent >= 0.35) return AppColors.amber;
    return AppColors.healthy;
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor();

    return AnimatedBuilder(
      animation: _fill,
      builder: (_, __) {
        final animatedPercent = widget.percent * _fill.value;
        return SizedBox(
          width: widget.size,
          height: widget.size * 1.25,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Soft glow background for lift/depth
              Container(
                width: widget.size * 0.75,
                height: widget.size * 0.75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.30),
                      blurRadius: 32,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
              // Leaf silhouette painter
              CustomPaint(
                size: Size(widget.size, widget.size * 1.25),
                painter: _LeafGaugePainter(
                  fillPercent: animatedPercent,
                  gaugeColor: color,
                ),
              ),
              // Percentage label
              Positioned(
                bottom: widget.size * 0.18,
                child: Text(
                  '${(animatedPercent * 100).round()}%',
                  style: AppTheme.mono(
                    size: widget.size * 0.14,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              if (widget.label != null)
                Positioned(
                  bottom: 0,
                  child: Text(
                    widget.label!,
                    style: AppTheme.ui(
                      size: 10,
                      weight: FontWeight.w500,
                      color: AppColors.glassTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LeafGaugePainter extends CustomPainter {
  final double fillPercent;
  final Color gaugeColor;

  const _LeafGaugePainter({
    required this.fillPercent,
    required this.gaugeColor,
  });

  Path _buildLeafPath(Size size) {
    final w = size.width;
    final h = size.height * 0.88; // leaf occupies top 88% of canvas
    final cx = w / 2;
    final path = Path();
    path.moveTo(cx, h * 0.96);
    path.cubicTo(cx - w * 0.44, h * 0.78, cx - w * 0.52, h * 0.42, cx, h * 0.04);
    path.cubicTo(cx + w * 0.52, h * 0.42, cx + w * 0.44, h * 0.78, cx, h * 0.96);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final leafPath = _buildLeafPath(size);
    final bounds = leafPath.getBounds();

    // --- Track (empty) ---
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawPath(leafPath, trackPaint);

    // --- Fill (clipped upward from bottom) ---
    final fillTop = bounds.bottom - (bounds.height * fillPercent);
    final fillRect = Rect.fromLTRB(
      bounds.left - 2,
      fillTop,
      bounds.right + 2,
      bounds.bottom + 2,
    );
    canvas.save();
    canvas.clipPath(leafPath);
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          gaugeColor,
          gaugeColor.withValues(alpha: 0.65),
        ],
      ).createShader(fillRect);
    canvas.drawRect(fillRect, fillPaint);
    canvas.restore();

    // --- Outline ---
    final outlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(leafPath, outlinePaint);

    // --- Center vein ---
    final cx = size.width / 2;
    final veinPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final leafH = size.height * 0.88;
    canvas.drawLine(Offset(cx, leafH * 0.94), Offset(cx, leafH * 0.08), veinPaint);
  }

  @override
  bool shouldRepaint(_LeafGaugePainter old) =>
      old.fillPercent != fillPercent || old.gaugeColor != gaugeColor;
}
