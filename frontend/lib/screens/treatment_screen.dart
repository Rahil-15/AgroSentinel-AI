import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../models/prediction_result.dart';
import '../providers/settings_provider.dart';
import '../utils/app_localizations.dart';
import '../widgets/outbreak_banner.dart';
import '../widgets/fl_status_card.dart';

class TreatmentScreen extends StatelessWidget {
  final PredictionResult result;
  const TreatmentScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final t = result.treatment;
    final hasOutbreak = result.outbreakAlert.outbreak;
    final lang = context.watch<SettingsProvider>().language;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.get('treatment_plan', lang))),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Outbreak banner ──────────────────────────────────────
          if (hasOutbreak)
            OutbreakBanner(message: result.outbreakAlert.message),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Disease context line
                Text(
                  AppStrings.crop(result.crop, lang),
                  style: AppTheme.ui(
                    size: 12,
                    weight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.disease(result.disease, lang),
                  style: AppTheme.display(
                    size: 22,
                    weight: FontWeight.w600,
                    color: AppColors.disease,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Step-by-step treatment ─────────────────────────
                Text(
                  AppStrings.get('step_by_step_treatment', lang),
                  style: AppTheme.ui(size: 15, weight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                ...t.steps.asMap().entries.map(
                      (e) => _TreatmentStep(
                        number: e.key + 1,
                        text: AppStrings.phrase(e.value, lang),
                      ),
                    ),
                const SizedBox(height: 24),

                // ── Medication ─────────────────────────────────────
                if (t.medication.isNotEmpty) ...[
                  Text(
                    AppStrings.get('medication', lang),
                    style: AppTheme.ui(size: 15, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(AppColors.radiusCard),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: t.medication.asMap().entries.map((e) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.medication_outlined,
                                    color: AppColors.disease,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      AppStrings.phrase(e.value, lang),
                                      style: AppTheme.mono(size: 13, color: AppColors.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (e.key < t.medication.length - 1)
                              const Divider(height: 1, indent: 16, endIndent: 16),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Prevention tips ────────────────────────────────
                if (t.prevention.isNotEmpty) ...[
                  Text(
                    AppStrings.get('prevention_tips', lang),
                    style: AppTheme.ui(size: 15, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(AppColors.radiusCard),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: t.prevention.asMap().entries.map((e) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.shield_outlined,
                                    color: AppColors.healthy,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      AppStrings.phrase(e.value, lang),
                                      style: AppTheme.ui(
                                        size: 13,
                                        color: AppColors.textPrimary,
                                      ).copyWith(height: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (e.key < t.prevention.length - 1)
                              const Divider(height: 1, indent: 16, endIndent: 16),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── FL panel ───────────────────────────────────────
                const FlStatusCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TreatmentStep extends StatelessWidget {
  final int number;
  final String text;
  const _TreatmentStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: AppColors.healthy,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: AppTheme.mono(
                  size: 12,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                text,
                style: AppTheme.ui(
                  size: 14,
                  color: AppColors.textPrimary,
                ).copyWith(height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
