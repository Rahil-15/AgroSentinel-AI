import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../providers/history_provider.dart';
import '../utils/app_localizations.dart';
import '../dummy_data.dart';
import '../widgets/scan_history_tile.dart';
import '../widgets/custom_vector_icons.dart';
import 'settings_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onQuickScan;
  const HomeScreen({super.key, required this.onQuickScan});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HistoryProvider>().fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final history = context.watch<HistoryProvider>();
    final activeAlerts = history.entries.where((e) => !e.isHealthy).length;
    final lang = settings.language;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardSurface,
        elevation: 0,
        title: Row(
          children: [
            const AgroVectorBadge(
              type: AgroVectorType.leaf,
              backgroundColor: AppColors.healthy,
              size: 36,
              iconSize: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'AgroSentinel',
              style: AppTheme.ui(
                size: 18,
                weight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.healthy,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'AI',
                style: AppTheme.mono(
                  size: 10,
                  weight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Notification Bell with Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22, color: AppColors.textPrimary),
                onPressed: () {},
                tooltip: AppStrings.get('nav_alerts', lang),
              ),
              if (activeAlerts > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.disease,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          // Settings Gear Button on top right
          Padding(
            padding: const EdgeInsets.only(right: 14, left: 4),
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              borderRadius: BorderRadius.circular(20),
              child: const AgroVectorBadge(
                type: AgroVectorType.settings,
                backgroundColor: AppColors.cardSurfaceAlt,
                iconColor: AppColors.healthy,
                size: 36,
                iconSize: 20,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.healthy,
        onRefresh: () => context.read<HistoryProvider>().fetchHistory(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          children: [
                // ── 1. Comprehensive Hero Banner with Farmer Portrait ─────────
                _ModernHeroBanner(
                  farmerName: settings.farmerName,
                  language: lang,
                  onScanTap: widget.onQuickScan,
                ),
                const SizedBox(height: 20),

                // ── 2. 7-Day Field Health Segmented Bar ────────────────────────
                _SevenDayHealthBar(language: lang),
                const SizedBox(height: 20),

                // ── 3. Modern 4-Card Stats Grid (2x2) ──────────────────────────
                _FourStatCardsGrid(
                  scansToday: history.totalScansToday > 0 ? history.totalScansToday : 3,
                  activeAlerts: activeAlerts > 0 ? activeAlerts : 2,
                  diseasesDetected: history.entries.where((e) => !e.isHealthy).length,
                  treatmentsCount: 4,
                  language: lang,
                ),
                const SizedBox(height: 22),

                // ── 4. AI Automated Leaf Pathology Feature Card ────────────────
                _AiFeatureCard(
                  language: lang,
                  onScanTap: widget.onQuickScan,
                ),
                const SizedBox(height: 24),

                // ── 5. Quick Sample Demos ──────────────────────────────────────
                Text(
                  AppStrings.get('quick_demo', lang),
                  style: AppTheme.ui(
                    size: 14,
                    weight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _SampleChip(
                        title: '${AppStrings.crop("Rice", lang)} - ${AppStrings.disease("Brown Spot", lang)}',
                        subtitle: '${AppStrings.disease("Diseased", lang)} (97%)',
                        isHealthy: false,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResultScreen(result: DummyData.sampleResult),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SampleChip(
                        title: '${AppStrings.crop("Tomato", lang)}',
                        subtitle: '${AppStrings.disease("Healthy", lang)} (99%)',
                        isHealthy: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResultScreen(result: DummyData.sampleHealthyResult),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── 6. Primary Action CTA ──────────────────────────────────────
                ElevatedButton.icon(
                  onPressed: widget.onQuickScan,
                  icon: const Icon(Icons.camera_alt, size: 22, color: Colors.white),
                  label: Text(AppStrings.get('analyse_leaf', lang)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.healthy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    elevation: 3,
                    shadowColor: AppColors.healthy.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppColors.radiusButton),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── 7. Recent Scans Feed ───────────────────────────────────────
                if (history.entries.isNotEmpty) ...[
                  Text(
                    AppStrings.get('recent_scans', lang),
                    style: AppTheme.ui(
                      size: 14,
                      weight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...history.entries.take(4).map((e) => ScanHistoryTile(entry: e)),
                ],
              ],
            ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── 1. Modern Hero Banner with Farmer Visual & Weather Telemetry ──────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _ModernHeroBanner extends StatelessWidget {
  final String farmerName;
  final String language;
  final VoidCallback onScanTap;

  const _ModernHeroBanner({
    required this.farmerName,
    required this.language,
    required this.onScanTap,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.get('good_morning', language);
    if (hour < 17) return AppStrings.get('good_afternoon', language);
    return AppStrings.get('good_evening', language);
  }

  @override
  Widget build(BuildContext context) {
    final displayName = farmerName.isEmpty ? 'Farmer' : farmerName;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.healthy.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Image with Gradient Overlay
          Positioned.fill(
            child: Image.asset(
              'assets/images/farmer_hero_field.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/hero_3d_scan.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF091F12).withValues(alpha: 0.95),
                    const Color(0xFF0D2D1B).withValues(alpha: 0.85),
                    const Color(0xFF133F27).withValues(alpha: 0.40),
                  ],
                ),
              ),
            ),
          ),

          // Banner Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Badge: Leaf Health Gauge
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.healthy.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.eco, color: Color(0xFF69F0AE), size: 15),
                        const SizedBox(width: 5),
                        Text(
                          '89% ${AppStrings.get("field_health", language)}',
                          style: AppTheme.mono(
                            size: 11,
                            weight: FontWeight.w700,
                            color: const Color(0xFF69F0AE),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Greeting & Headline
                Text(
                  '$_greeting $displayName',
                  style: AppTheme.display(
                    size: 24,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.get('hero_subtitle', language),
                  style: AppTheme.ui(
                    size: 13,
                    color: const Color(0xFFE0F2E9),
                  ),
                ),
                const SizedBox(height: 18),

                // Live Sensor & Weather Glass Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _weatherItem(Icons.wb_sunny_rounded, '26°C', AppStrings.get('sunny', language), AppColors.amber),
                      _divider(),
                      _weatherItem(Icons.water_drop_rounded, '68%', AppStrings.get('humidity', language), const Color(0xFF64B5F6)),
                      _divider(),
                      _weatherItem(Icons.air_rounded, '12 km/h', AppStrings.get('wind', language), const Color(0xFF81C784)),
                      _divider(),
                      _weatherItem(Icons.grass_rounded, '42%', AppStrings.get('moisture', language), const Color(0xFFAED581)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.2));

  Widget _weatherItem(IconData icon, String val, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              val,
              style: AppTheme.mono(size: 12, weight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: AppTheme.ui(size: 9.5, color: Colors.white.withValues(alpha: 0.75)),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── 2. 7-Day Field Health Segmented Bar ──────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _SevenDayHealthBar extends StatelessWidget {
  final String language;
  const _SevenDayHealthBar({required this.language});

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final values = [0.92, 0.88, 0.95, 0.84, 0.90, 0.76, 0.89];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics_outlined, size: 16, color: AppColors.healthy),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.get('seven_day_health', language),
                    style: AppTheme.ui(size: 13, weight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.healthyBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'avg 89%',
                  style: AppTheme.mono(size: 11, weight: FontWeight.w700, color: AppColors.healthy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(days.length, (i) {
              final isWarning = i == 5; // Saturday warning
              final isToday = i == 6;
              final barColor = isWarning ? AppColors.amber : AppColors.healthy;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == days.length - 1 ? 0 : 6),
                  child: Column(
                    children: [
                      Container(
                        height: 28,
                        decoration: BoxDecoration(
                          color: barColor.withValues(alpha: isToday ? 1.0 : (isWarning ? 0.8 : 0.45)),
                          borderRadius: BorderRadius.circular(6),
                          border: isToday ? Border.all(color: AppColors.healthy, width: 1.5) : null,
                        ),
                        child: Center(
                          child: Text(
                            '${(values[i] * 100).round()}%',
                            style: AppTheme.mono(
                              size: 8.5,
                              weight: FontWeight.w700,
                              color: isToday ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        days[i],
                        style: AppTheme.mono(
                          size: 10,
                          weight: isToday ? FontWeight.w800 : FontWeight.w500,
                          color: isToday ? AppColors.healthy : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── 3. Modern 4-Card Stats Grid (2x2) with Mini Graph Lines ──────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _FourStatCardsGrid extends StatelessWidget {
  final int scansToday;
  final int activeAlerts;
  final int diseasesDetected;
  final int treatmentsCount;
  final String language;

  const _FourStatCardsGrid({
    required this.scansToday,
    required this.activeAlerts,
    required this.diseasesDetected,
    required this.treatmentsCount,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: AppStrings.get('scans_today', language),
                value: '$scansToday',
                badgeType: AgroVectorType.camera,
                color: AppColors.healthy,
                bg: AppColors.healthy,
                sparklineColor: AppColors.healthy,
                imagePath: 'assets/images/hero_3d_scan.jpg',
                liveLabel: AppStrings.get('live_badge', language),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: AppStrings.get('active_alerts', language),
                value: '$activeAlerts',
                badgeType: AgroVectorType.warning,
                color: AppColors.disease,
                bg: AppColors.disease,
                sparklineColor: AppColors.disease,
                imagePath: 'assets/images/radar_3d_alert.jpg',
                liveLabel: AppStrings.get('live_badge', language),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: AppStrings.get('diseases_detected', language),
                value: '$diseasesDetected',
                badgeType: AgroVectorType.bug,
                color: AppColors.amber,
                bg: AppColors.amber,
                sparklineColor: AppColors.amber,
                imagePath: 'assets/images/leaf_3d_disease.jpg',
                liveLabel: AppStrings.get('live_badge', language),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: AppStrings.get('treatments_active', language),
                value: '$treatmentsCount',
                badgeType: AgroVectorType.medical,
                color: AppColors.fl,
                bg: AppColors.fl,
                sparklineColor: AppColors.fl,
                imagePath: 'assets/images/shield_3d_fl.jpg',
                liveLabel: AppStrings.get('live_badge', language),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final AgroVectorType badgeType;
  final Color color;
  final Color bg;
  final Color sparklineColor;
  final String imagePath;
  final String liveLabel;

  const _StatCard({
    required this.label,
    required this.value,
    required this.badgeType,
    required this.color,
    required this.bg,
    required this.sparklineColor,
    required this.imagePath,
    required this.liveLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background illustration image
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (_, __, ___) => Container(color: AppColors.cardSurface),
            ),
          ),
          // High-contrast dark glass gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.cardSurface.withValues(alpha: 0.94),
                    AppColors.cardSurface.withValues(alpha: 0.88),
                    AppColors.cardSurface.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
          ),
          // Card content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Canvas-painted Vector Logo Badge
                    AgroVectorBadge(
                      type: badgeType,
                      backgroundColor: color,
                      size: 40,
                      iconSize: 22,
                    ),
                    // Mini live badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            liveLabel,
                            style: AppTheme.mono(size: 9.5, weight: FontWeight.w700, color: color),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: AppTheme.mono(
                    size: 26,
                    weight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTheme.ui(
                    size: 13,
                    color: AppColors.textSecondary,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                // Micro sparkline visual
                Container(
                  height: 3.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.15)],
                    ),
                    borderRadius: BorderRadius.circular(2),
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

// ═══════════════════════════════════════════════════════════════════════════════
// ── 4. AI Feature Card: Automated Leaf Pathology ─────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _AiFeatureCard extends StatelessWidget {
  final String language;
  final VoidCallback onScanTap;

  const _AiFeatureCard({
    required this.language,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          SizedBox(
            height: 170,
            width: double.infinity,
            child: Image.asset(
              'assets/images/hero_3d_scan.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.20),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.healthy,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.psychology_rounded, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'EDGE AI ACTIVE',
                              style: AppTheme.mono(size: 9.5, weight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.get('auto_pathology', language),
                        style: AppTheme.display(size: 17, weight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.get('auto_pathology_sub', language),
                        style: AppTheme.ui(size: 11.5, color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onScanTap,
                  icon: const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
                  label: Text(
                    AppStrings.get('try_demo', language),
                    style: AppTheme.ui(size: 13, weight: FontWeight.w700, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.healthy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(110, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 3,
                    shadowColor: AppColors.healthy.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

// ═══════════════════════════════════════════════════════════════════════════════
// ── 5. Demo Chip Widget ───────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _SampleChip extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isHealthy;
  final VoidCallback onTap;

  const _SampleChip({
    required this.title,
    required this.subtitle,
    required this.isHealthy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isHealthy ? AppColors.healthy : AppColors.disease;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppColors.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(AppColors.radiusCard),
          border: Border.all(color: color.withValues(alpha: 0.45), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AgroVectorBadge(
              type: isHealthy ? AgroVectorType.leaf : AgroVectorType.bug,
              backgroundColor: color,
              size: 34,
              iconSize: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.ui(size: 12, weight: FontWeight.w600, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.mono(size: 10.5, weight: FontWeight.w700, color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
