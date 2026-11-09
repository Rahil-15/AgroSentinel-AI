import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const GlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Floating Nature & Gold Pill Navigation Dock.
///
/// Features an elevated central Golden Scan Hub button and smooth sliding tab indicators.
class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;

  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SizedBox(
          height: 72,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // ── Floating Frosted Dock Pill ──────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: AppColors.kGlassBlur,
                    sigmaY: AppColors.kGlassBlur,
                  ),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF09160E).withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(0, items[0]),
                        _buildNavItem(1, items[1]),
                        const SizedBox(width: 58), // Space for center hub
                        _buildNavItem(2, items[2]),
                        _buildNavItem(3, items[3]),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Central Elevated Golden Scan Hub ────────────────────
              Positioned(
                top: -6,
                child: GestureDetector(
                  onTap: () => onTap(1), // Scan index
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFDE8B3),
                          Color(0xFFD4A853),
                          Color(0xFF9E772E),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFFFFF2D1),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.50),
                          blurRadius: 18,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Color(0xFF160E02),
                          size: 24,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'SCAN',
                          style: AppTheme.mono(
                            size: 9,
                            weight: FontWeight.w800,
                            color: const Color(0xFF160E02),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, GlassNavItem item) {
    final isActive = index == currentIndex;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.gold.withValues(alpha: 0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                color: isActive ? AppColors.gold : AppColors.textSecondary,
                size: 21,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.gold : AppColors.textSecondary,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const kNavItems = [
  GlassNavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Home',
  ),
  GlassNavItem(
    icon: Icons.grass_outlined,
    activeIcon: Icons.grass_rounded,
    label: 'Fields',
  ),
  GlassNavItem(
    icon: Icons.insights_outlined,
    activeIcon: Icons.insights_rounded,
    label: 'Analysis',
  ),
  GlassNavItem(
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    label: 'Profile',
  ),
];
