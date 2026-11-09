import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Nature & Gold Frosted Glass Surface.
///
/// Features deep organic tinting, 1px gold/emerald edge highlights,
/// and smooth hardware-accelerated BackdropFilter.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double blurRadius;
  final double tileOpacity;
  final Color tintColor;
  final Color? glowColor;
  final BoxBorder? border;
  final bool hasGoldAccent;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppColors.radiusGlass),
    ),
    this.blurRadius = AppColors.kGlassBlur,
    this.tileOpacity = AppColors.kGlassTileOpacity,
    this.tintColor = AppColors.forestCard,
    this.glowColor,
    this.border,
    this.hasGoldAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = hasGoldAccent
        ? AppColors.gold.withValues(alpha: 0.45)
        : (glowColor != null
            ? glowColor!.withValues(alpha: 0.40)
            : AppColors.glassWhiteBorder);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (tintColor == AppColors.forestCard ? const Color(0xFF142F21) : tintColor)
                    .withValues(alpha: 0.55),
                (tintColor == AppColors.forestCard ? const Color(0xFF09160E) : tintColor)
                    .withValues(alpha: 0.75),
              ],
            ),
            border: border ??
                Border.all(
                  color: borderColor,
                  width: 1.0,
                ),
            boxShadow: [
              BoxShadow(
                color: (glowColor ?? Colors.black).withValues(alpha: glowColor != null ? 0.20 : 0.40),
                blurRadius: glowColor != null ? 24 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
