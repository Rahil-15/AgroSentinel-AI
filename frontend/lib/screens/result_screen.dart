import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../models/prediction_result.dart';
import '../providers/settings_provider.dart';
import '../utils/app_localizations.dart';
import '../widgets/leaf_gauge.dart';
import 'treatment_screen.dart';

class ResultScreen extends StatelessWidget {
  final PredictionResult result;
  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isHealthy = result.isHealthy;
    final primaryColor = isHealthy ? AppColors.healthy : AppColors.disease;
    final settings = context.watch<SettingsProvider>();
    final lang = settings.language;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.get('detection_result', lang)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: [
          // ── Crop & disease headline ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(AppColors.radiusLargeCard),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.crop(result.crop, lang),
                  style: AppTheme.ui(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.disease(result.disease, lang),
                  style: AppTheme.display(
                    size: 26,
                    weight: FontWeight.w600,
                    color: isHealthy ? AppColors.healthy : AppColors.disease,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Signature Leaf Gauge ─────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(AppColors.radiusLargeCard),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: LeafGauge(
                      value: result.confidence,
                      label: AppStrings.get('confidence', lang),
                      color: primaryColor,
                    ),
                  ),
                ),
                if (!isHealthy)
                  Expanded(
                    child: Center(
                      child: LeafGauge(
                        value: result.infectedPct / 100.0,
                        label: AppStrings.get('infected_area', lang),
                        color: AppColors.amber,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Grad-CAM Heatmap Image ───────────────────────────────
          Text(
            AppStrings.get('gradcam_heatmap', lang),
            style: AppTheme.ui(size: 14, weight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(AppColors.radiusLargeCard),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: _GradCamImage(base64: result.gradcamImage, language: lang),
          ),
          const SizedBox(height: 20),

          // ── Financial loss ───────────────────────────────
          if (!isHealthy) ...[
            _FinancialCard(result: result, language: lang),
            const SizedBox(height: 20),
          ],

          // ── Top-3 predictions ────────────────────────────────────
          Text(
            AppStrings.get('top3_predictions', lang),
            style: AppTheme.ui(size: 14, weight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _Top3Card(predictions: result.top3, isHealthy: isHealthy, language: lang),
          const SizedBox(height: 24),

          // ── Treatment CTA ────────────────────────────────────────
          if (!isHealthy)
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TreatmentScreen(result: result)),
              ),
              icon: const Icon(Icons.health_and_safety_rounded, size: 20),
              label: Text(AppStrings.get('view_treatment_plan', lang)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.disease,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.healthyBg,
                borderRadius: BorderRadius.circular(AppColors.radiusCard),
                border: Border.all(color: AppColors.healthy.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.healthy, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.get('healthy_crop_msg', lang),
                      style: AppTheme.ui(
                        size: 13,
                        weight: FontWeight.w500,
                        color: AppColors.healthy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GradCamImage extends StatelessWidget {
  final String base64;
  final String language;

  const _GradCamImage({required this.base64, required this.language});

  @override
  Widget build(BuildContext context) {
    if (base64.isNotEmpty) {
      try {
        final bytes = base64Decode(base64);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {}
    }
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/leaf_3d_disease.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.withValues(alpha: 0.40),
                  Colors.amber.withValues(alpha: 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 12,
          right: 12,
          child: Text(
            AppStrings.get('gradcam_sub', language),
            style: AppTheme.ui(
              size: 12,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}

class _FinancialCard extends StatelessWidget {
  final PredictionResult result;
  final String language;

  const _FinancialCard({required this.result, required this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('financial_loss', language),
            style: AppTheme.ui(size: 13, weight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            '₹${_fmt(result.estimatedLossInr)}',
            style: AppTheme.mono(
              size: 30,
              weight: FontWeight.w700,
              color: AppColors.disease,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${result.yieldLossPct}% ${AppStrings.get("projected_yield_loss", language)}',
            style: AppTheme.mono(
              size: 12,
              weight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            result.lossSummary,
            style: AppTheme.ui(size: 13, color: AppColors.textSecondary).copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  String _fmt(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    final rev = s.split('').reversed.toList();
    final chunks = <String>[];
    for (var i = 0; i < rev.length; i++) {
      if (i == 3 || (i > 3 && (i - 3) % 2 == 0)) chunks.add(',');
      chunks.add(rev[i]);
    }
    return chunks.reversed.join();
  }
}

class _Top3Card extends StatelessWidget {
  final List<TopPrediction> predictions;
  final bool isHealthy;
  final String language;

  const _Top3Card({
    required this.predictions,
    required this.isHealthy,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: predictions.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          final confColor = i == 0
              ? (isHealthy ? AppColors.healthy : AppColors.disease)
              : AppColors.textSecondary;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: i == 0
                            ? (isHealthy ? AppColors.healthyBg : AppColors.diseaseBg)
                            : AppColors.border.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: AppTheme.mono(
                            size: 11,
                            weight: FontWeight.w700,
                            color: confColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.disease(p.label, language),
                        style: AppTheme.ui(
                          size: 13,
                          weight: i == 0 ? FontWeight.w600 : FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${(p.confidence * 100).toStringAsFixed(1)}%',
                      style: AppTheme.mono(
                        size: 13,
                        weight: FontWeight.w600,
                        color: confColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < predictions.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}
