import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Luxury Gold & Emerald 3D Action Button.
///
/// Features physical spring press feedback, golden bloom shadows,
/// and smooth organic gradient fills.
class Glass3DButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color accentColor;
  final Color? textColor;
  final double height;
  final bool isGoldGradient;

  const Glass3DButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.accentColor = AppColors.gold,
    this.textColor,
    this.height = 54,
    this.isGoldGradient = true,
  });

  @override
  State<Glass3DButton> createState() => _Glass3DButtonState();
}

class _Glass3DButtonState extends State<Glass3DButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 400),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _glow = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    HapticFeedback.lightImpact();
    _ctrl.forward();
  }

  void _onTapUp(TapUpDetails _) => _ctrl.reverse();
  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = widget.textColor ??
        (widget.isGoldGradient ? const Color(0xFF130D02) : Colors.white);

    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppColors.radiusButton),
                gradient: widget.isGoldGradient
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF7DE9E),
                          Color(0xFFD4A853),
                          Color(0xFF9E772E),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.accentColor,
                          widget.accentColor.withValues(alpha: 0.75),
                        ],
                      ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isGoldGradient ? AppColors.gold : widget.accentColor)
                        .withValues(alpha: 0.40 * _glow.value),
                    blurRadius: 20 * _glow.value,
                    spreadRadius: 1 * _glow.value,
                    offset: Offset(0, 6 * _glow.value),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: effectiveTextColor, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: AppTheme.ui(
                        size: 15,
                        weight: FontWeight.w700,
                        color: effectiveTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
