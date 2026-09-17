import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import 'home_screen.dart';
import 'scan_screen.dart';
import 'analytics_screen.dart';
import 'alerts_screen.dart';

class MainNavShell extends StatefulWidget {
  const MainNavShell({super.key});

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<SettingsProvider>().load();
    });
  }

  void _goToTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onQuickScan: () => _goToTab(1)),
      const ScanScreen(),
      const AnalyticsScreen(),
      const AlertsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: _AgroBottomNav(
        currentIndex: _index,
        onTap: _goToTab,
      ),
    );
  }
}

/// Styled bottom nav — active tab in healthy green with a soft green
/// chip background behind the icon.
class _AgroBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AgroBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().language;

    final items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: AppStrings.get('nav_home', lang),
      ),
      _NavItem(
        icon: Icons.camera_alt_outlined,
        activeIcon: Icons.camera_alt,
        label: AppStrings.get('nav_scan', lang),
      ),
      _NavItem(
        icon: Icons.bar_chart_rounded,
        activeIcon: Icons.bar_chart_rounded,
        label: AppStrings.get('nav_analytics', lang),
      ),
      _NavItem(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications_rounded,
        label: AppStrings.get('nav_alerts', lang),
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = i == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.healthyBg
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: isActive
                              ? AppColors.healthy
                              : AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: AppTheme.ui(
                          size: 10.5,
                          weight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isActive
                              ? AppColors.healthy
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}