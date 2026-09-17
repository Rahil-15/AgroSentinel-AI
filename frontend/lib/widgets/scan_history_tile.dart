import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/prediction_result.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';

/// Reusable card for a single scan history entry.
/// Used on the Analytics screen and in the Home last-detection card area.
class ScanHistoryTile extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback? onTap;

  const ScanHistoryTile({super.key, required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isHealthy = entry.isHealthy;
    final iconColor = isHealthy ? AppColors.healthy : AppColors.disease;
    final iconBg = isHealthy ? AppColors.healthyBg : AppColors.diseaseBg;
    final lang = context.watch<SettingsProvider>().language;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Status circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isHealthy ? Icons.eco_outlined : Icons.pest_control_outlined,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Crop + disease + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.crop(entry.crop, lang),
                      style: AppTheme.ui(
                        size: 12,
                        weight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.disease(entry.disease, lang),
                      style: AppTheme.ui(
                        size: 14,
                        weight: FontWeight.w600,
                        color: isHealthy ? AppColors.healthy : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM d • h:mm a').format(entry.date),
                      style: AppTheme.ui(
                        size: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Financial loss or check
              if (!isHealthy) ...[
                const SizedBox(width: 8),
                Text(
                  '₹${NumberFormat('#,##,###').format(entry.estimatedLossInr)}',
                  style: AppTheme.mono(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.disease,
                  ),
                ),
              ] else ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle_outline,
                    color: AppColors.healthy, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
