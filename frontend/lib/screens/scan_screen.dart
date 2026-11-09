import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/scan_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_localizations.dart';
import '../dummy_data.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _picker = ImagePicker();
  final _areaController = TextEditingController();
  bool _prefilled = false;
  Uint8List? _imageBytes;
  String? _selectedPresetName;

  final List<double> _quickAreaPresets = [0.5, 1.0, 2.0, 2.5, 5.0, 10.0];

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1280,
      );
      if (picked != null && mounted) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _selectedPresetName = null;
        });
        if (kIsWeb) {
          context.read<ScanProvider>().setWebImage(picked);
        } else {
          context.read<ScanProvider>().setImage(File(picked.path));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open camera or gallery. Check app permissions.'),
          ),
        );
      }
    }
  }

  Future<void> _analyse() async {
    final scan = context.read<ScanProvider>();
    final area = double.tryParse(_areaController.text.trim()) ?? 1.0;
    scan.setFieldArea(area);
    await scan.analyze();

    if (!mounted) return;
    if (scan.result != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(result: scan.result!)),
      );
    } else if (scan.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(scan.error!)),
      );
    }
  }

  void _usePresetSample(String sampleType) {
    setState(() {
      _selectedPresetName = sampleType;
      _imageBytes = null;
    });
    // Load sample result into provider
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          result: sampleType == 'tomato'
              ? DummyData.sampleHealthyResult
              : DummyData.sampleResult,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();
    final settings = context.watch<SettingsProvider>();
    final lang = settings.language;

    // Pre-fill field area once settings are loaded
    if (!_prefilled && settings.isLoaded) {
      _areaController.text = settings.defaultFieldArea.toString();
      _prefilled = true;
    }

    final hasImage = scan.hasImage || _imageBytes != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            const Icon(Icons.qr_code_scanner_rounded, color: AppColors.healthy, size: 22),
            const SizedBox(width: 8),
            Text(AppStrings.get('scan_title', lang)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
        children: [
          // ── 1. Main Leaf Photo Capture & Preview Panel ───────────────────
          _ImagePreviewBox(
            imageBytes: _imageBytes,
            selectedPreset: _selectedPresetName,
            language: lang,
          ),
          const SizedBox(height: 16),

          // ── 2. Camera & Gallery Pick Action Buttons ──────────────────────
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: scan.isLoading ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_rounded, size: 20, color: Colors.white),
                  label: Text(
                    AppStrings.get('camera', lang),
                    style: AppTheme.ui(size: 14, weight: FontWeight.w700, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.healthy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 52),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: scan.isLoading ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded, size: 20, color: Colors.white),
                  label: Text(
                    AppStrings.get('gallery', lang),
                    style: AppTheme.ui(size: 14, weight: FontWeight.w700, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardSurfaceAlt,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 52),
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── 3. Quick Leaf Pathology Presets (One-Tap Test) ───────────────
          Text(
            AppStrings.get('quick_demo', lang),
            style: AppTheme.ui(size: 13, weight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _PresetLeafCard(
                  imagePath: 'assets/images/leaf_3d_disease.jpg',
                  title: '${AppStrings.crop("Rice", lang)} - ${AppStrings.disease("Brown Spot", lang)}',
                  subtitle: '${AppStrings.disease("Diseased", lang)} (97%)',
                  badgeColor: AppColors.disease,
                  icon: Icons.bug_report,
                  onTap: () => _usePresetSample('rice'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PresetLeafCard(
                  imagePath: 'assets/images/hero_3d_scan.jpg',
                  title: '${AppStrings.crop("Tomato", lang)}',
                  subtitle: '${AppStrings.disease("Healthy", lang)} (99%)',
                  badgeColor: AppColors.healthy,
                  icon: Icons.eco,
                  onTap: () => _usePresetSample('tomato'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── 4. Field Area Configuration ──────────────────────────────────
          Text(
            AppStrings.get('field_area_label', lang),
            style: AppTheme.ui(size: 13, weight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _areaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTheme.mono(size: 15, weight: FontWeight.w600, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. 2.5',
              suffixText: 'acres',
              prefixIcon: const Icon(Icons.crop_landscape_rounded, color: AppColors.healthy, size: 20),
            ),
          ),
          const SizedBox(height: 10),
          // Quick preset acreage chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickAreaPresets.map((area) {
              final isSelected = double.tryParse(_areaController.text.trim()) == area;
              return InkWell(
                onTap: () {
                  setState(() {
                    _areaController.text = area == area.roundToDouble()
                        ? area.toInt().toString()
                        : area.toString();
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.healthy : AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.healthy : AppColors.border,
                    ),
                  ),
                  child: Text(
                    '$area ${area == 1 ? "acre" : "acres"}',
                    style: AppTheme.mono(
                      size: 11,
                      weight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // ── 5. Primary Giant Analyse Button ──────────────────────────────
          ElevatedButton.icon(
            onPressed: scan.isLoading ? null : (hasImage ? _analyse : () => _usePresetSample('rice')),
            icon: scan.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : const Icon(Icons.biotech_rounded, size: 24, color: Colors.white),
            label: Text(
              scan.isLoading
                  ? AppStrings.get('analysing', lang)
                  : AppStrings.get('analyse', lang),
              style: AppTheme.ui(size: 16, weight: FontWeight.w800, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.healthy,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              elevation: 4,
              shadowColor: AppColors.healthy.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radiusButton)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              AppStrings.get('take_photo_hint', lang),
              style: AppTheme.ui(size: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Image Preview Viewport ───────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _ImagePreviewBox extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? selectedPreset;
  final String language;

  const _ImagePreviewBox({
    required this.imageBytes,
    required this.selectedPreset,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppColors.radiusLargeCard),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.healthy.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (imageBytes != null) {
      return Image.memory(
        imageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/leaf_3d_disease.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: AppColors.cardSurface),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.healthy.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.healthy.withValues(alpha: 0.6),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.center_focus_strong_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                AppStrings.get('camera_ready', language),
                style: AppTheme.display(
                  size: 18,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.get('camera_sub', language),
                style: AppTheme.ui(
                  size: 12.5,
                  color: const Color(0xFFE0F2E9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Preset Leaf Card Widget ──────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _PresetLeafCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final Color badgeColor;
  final IconData icon;
  final VoidCallback onTap;

  const _PresetLeafCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.badgeColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: badgeColor.withValues(alpha: 0.45), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: badgeColor.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.cardSurface),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.cardSurface.withValues(alpha: 0.65),
                      AppColors.cardSurface.withValues(alpha: 0.95),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(icon, color: Colors.white, size: 15),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTheme.ui(size: 11.5, weight: FontWeight.w700, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: AppTheme.mono(size: 10, weight: FontWeight.w700, color: badgeColor),
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
  }
}
