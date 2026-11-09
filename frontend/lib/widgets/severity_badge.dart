import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Pill badge showing severity level.
/// Spec: 20px pill radius, colour-coded by severity meaning.
class SeverityBadge extends StatelessWidget {
  final String severity;

  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    if (severity.isEmpty || severity.toLowerCase() == 'none') {
      return const SizedBox.shrink();
    }
    final color = AppTheme.severityColor(severity);
    final bgColor = AppTheme.severityBgColor(severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppColors.radiusBadge),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        severity.toUpperCase(),
        style: AppTheme.ui(
          size: 11,
          weight: FontWeight.w700,
          color: color,
        ).copyWith(letterSpacing: 0.8),
      ),
    );
  }
}
