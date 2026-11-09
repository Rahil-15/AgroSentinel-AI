import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';

/// Federated Learning status panel.
class FlStatusCard extends StatelessWidget {
  const FlStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().language;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.flBg,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        border: Border.all(color: AppColors.fl.withValues(alpha: 0.30), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.fl.withValues(alpha: 0.35)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/shield_3d_fl.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.hub_outlined, color: AppColors.fl, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('fl_network_title', lang),
                  style: AppTheme.ui(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.fl,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  AppStrings.get('fl_network_desc', lang),
                  style: AppTheme.ui(
                    size: 12,
                    color: AppColors.textSecondary,
                  ).copyWith(height: 1.5),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.healthy,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.get('node_synced', lang),
                      style: AppTheme.mono(
                        size: 11,
                        weight: FontWeight.w500,
                        color: AppColors.fl,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
