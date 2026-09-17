import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';

/// Full-width outbreak alert banner.
/// Edge-to-edge on the Treatment screen.
class OutbreakBanner extends StatelessWidget {
  final String message;

  const OutbreakBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().language;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        color: AppColors.outbreak,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('outbreak_alert_title', lang),
                  style: AppTheme.ui(
                    size: 13,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ).copyWith(letterSpacing: 1.0),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.phrase(message, lang),
                  style: AppTheme.ui(size: 13, color: Colors.white).copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
