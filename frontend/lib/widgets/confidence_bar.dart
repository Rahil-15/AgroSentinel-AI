import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ConfidenceBar extends StatelessWidget {
  final double confidence; // 0.0 - 1.0
  final bool isHealthy;

  const ConfidenceBar({super.key, required this.confidence, this.isHealthy = false});

  @override
  Widget build(BuildContext context) {
    final pct = (confidence * 100).clamp(0, 100).toStringAsFixed(1);
    final color = isHealthy ? AppColors.healthy : AppColors.disease;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Confidence', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Text('$pct%', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: confidence.clamp(0, 1),
            minHeight: 10,
            backgroundColor: const Color(0xFFEEEEEE),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
