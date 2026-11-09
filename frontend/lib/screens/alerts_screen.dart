import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_localizations.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HistoryProvider>().fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final lang = context.watch<SettingsProvider>().language;
    final alerts = history.entries.where((e) => !e.isHealthy).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.outbreak, size: 20),
            const SizedBox(width: 8),
            Text(AppStrings.get('outbreak_alerts', lang)),
          ],
        ),
      ),
      body: history.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.healthy))
          : alerts.isEmpty
              ? _EmptyState(language: lang)
              : RefreshIndicator(
                  color: AppColors.healthy,
                  onRefresh: () => context.read<HistoryProvider>().fetchHistory(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    itemCount: alerts.length,
                    itemBuilder: (context, i) {
                      final a = alerts[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.outbreakBg,
                            borderRadius: BorderRadius.circular(AppColors.radiusCard),
                            border: Border.all(
                              color: AppColors.outbreak.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.outbreak.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppColors.outbreak,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${a.crop} — ${a.disease}',
                                      style: AppTheme.ui(
                                        size: 14,
                                        weight: FontWeight.w700,
                                        color: AppColors.outbreak,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppStrings.get('detected_in_area', lang),
                                      style: AppTheme.ui(
                                        size: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '₹${_fmtInr(a.estimatedLossInr)} impact',
                                          style: AppTheme.mono(
                                            size: 12,
                                            weight: FontWeight.w600,
                                            color: AppColors.outbreak,
                                          ),
                                        ),
                                        Text(
                                          '  ·  ${DateFormat('MMM d').format(a.date)}',
                                          style: AppTheme.ui(
                                            size: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _fmtInr(int n) {
    if (n == 0) return '0';
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

class _EmptyState extends StatelessWidget {
  final String language;
  const _EmptyState({required this.language});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/radar_3d_alert.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.check_circle_outline,
                  size: 56,
                  color: AppColors.healthy,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.get('no_alerts', language),
              style: AppTheme.display(
                size: 20,
                weight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.get('radar_desc', language),
              style: AppTheme.ui(size: 13, color: AppColors.textSecondary).copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
