import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_localizations.dart';
import '../widgets/scan_history_tile.dart';
import '../dummy_data.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
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
    final freq = history.diseaseFrequency;
    final diseases = freq.keys.toList();
    final maxY = freq.isEmpty ? 1 : freq.values.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(AppStrings.get('analytics_title', lang)),
      ),
      body: history.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.healthy))
          : RefreshIndicator(
              color: AppColors.healthy,
              onRefresh: () => context.read<HistoryProvider>().fetchHistory(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                children: [
                  // ── Summary card ───────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(AppColors.radiusCard),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.get('total_loss', lang),
                              style: AppTheme.ui(size: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${_fmtInr(history.totalFinancialLoss)}',
                              style: AppTheme.mono(
                                size: 24,
                                weight: FontWeight.w600,
                                color: AppColors.disease,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              AppStrings.get('total_scans', lang),
                              style: AppTheme.ui(size: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${history.entries.length}',
                              style: AppTheme.mono(
                                size: 24,
                                weight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Crop filter ────────────────────────────────
                  Row(
                    children: [
                      Text(
                        AppStrings.get('filter_label', lang),
                        style: AppTheme.ui(size: 13, weight: FontWeight.w600),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: history.selectedCropFilter,
                            hint: Text(
                              AppStrings.get('all_crops', lang),
                              style: AppTheme.ui(size: 13),
                            ),
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(AppColors.radiusCard),
                            items: [
                              DropdownMenuItem(
                                value: null,
                                child: Text(
                                  AppStrings.get('all_crops', lang),
                                  style: AppTheme.ui(size: 13),
                                ),
                              ),
                              ...DummyData.cropFolders.map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c, style: AppTheme.ui(size: 13)),
                                ),
                              ),
                            ],
                            onChanged: (v) => context.read<HistoryProvider>().setCropFilter(v),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Bar chart ──────────────────────────────────
                  Text(
                    AppStrings.get('disease_frequency', lang),
                    style: AppTheme.ui(size: 15, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 220,
                    padding: const EdgeInsets.fromLTRB(4, 12, 12, 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(AppColors.radiusCard),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: diseases.isEmpty
                        ? Center(
                            child: Text(
                              'No disease detections yet',
                              style: AppTheme.ui(size: 13, color: AppColors.textSecondary),
                            ),
                          )
                        : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: (maxY + 1).toDouble(),
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor: (_) => AppColors.textPrimary,
                                  getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                                    '${rod.toY.toInt()} scan${rod.toY == 1 ? '' : 's'}',
                                    AppTheme.mono(size: 11, weight: FontWeight.w500, color: Colors.white),
                                  ),
                                ),
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 24,
                                    interval: 1,
                                    getTitlesWidget: (v, _) => Text(
                                      '${v.toInt()}',
                                      style: AppTheme.mono(size: 10, color: AppColors.textSecondary),
                                    ),
                                  ),
                                ),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      final i = value.toInt();
                                      if (i < 0 || i >= diseases.length) {
                                        return const SizedBox.shrink();
                                      }
                                      final label = diseases[i];
                                      final parts = label.split(' ');
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          parts.length > 1
                                              ? '${parts[0]}\n${parts.sublist(1).join(' ')}'
                                              : label,
                                          style: AppTheme.ui(size: 9, color: AppColors.textSecondary),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(
                                show: true,
                                horizontalInterval: 1,
                                getDrawingHorizontalLine: (_) => FlLine(
                                  color: AppColors.border,
                                  strokeWidth: 1,
                                ),
                              ),
                              barGroups: List.generate(diseases.length, (i) {
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: freq[diseases[i]]!.toDouble(),
                                      color: AppColors.disease,
                                      width: 28,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        topRight: Radius.circular(6),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                  ),
                  const SizedBox(height: 28),

                  // ── Past scans list ────────────────────────────
                  Text(
                    AppStrings.get('past_scans', lang),
                    style: AppTheme.ui(size: 15, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  if (history.entries.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'No scans yet — tap Analyse to get started.',
                          style: AppTheme.ui(size: 13, color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...history.entries.map((e) => ScanHistoryTile(entry: e)),
                ],
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
