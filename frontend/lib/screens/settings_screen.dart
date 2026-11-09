import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../utils/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _areaCtrl;
  String _language = 'English';
  bool _saving = false;

  final List<double> _quickAreaPresets = [0.5, 1.0, 2.0, 2.5, 5.0, 10.0];

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>();
    _nameCtrl = TextEditingController(text: s.farmerName);
    _areaCtrl = TextEditingController(text: s.defaultFieldArea.toString());
    _language = s.language;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final s = context.read<SettingsProvider>();
    await s.save(
      farmerName: _nameCtrl.text.trim().isEmpty ? 'Farmer' : _nameCtrl.text.trim(),
      defaultFieldArea: double.tryParse(_areaCtrl.text.trim()) ?? 1.0,
      apiBaseUrl: s.apiBaseUrl,
      nodeId: s.nodeId,
      language: _language,
    );
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                AppStrings.get('settings_saved', _language),
                style: AppTheme.ui(size: 13, weight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
          backgroundColor: AppColors.healthy,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.get('settings_title', _language)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
              // ── 1. Farmer Profile ───────────────────────────────────────
              _SectionLabel(AppStrings.get('farmer_profile', _language)),
              _Field(
                label: AppStrings.get('farmer_name', _language),
                controller: _nameCtrl,
                hint: 'e.g. Ramesh Kumar',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 24),

              // ── 2. Field Area Configuration ──────────────────────────────
              _SectionLabel(AppStrings.get('field_area_section', _language)),
              Text(
                AppStrings.get('field_area_desc', _language),
                style: AppTheme.ui(size: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              _Field(
                label: AppStrings.get('total_field_area', _language),
                controller: _areaCtrl,
                hint: 'e.g. 2.5',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                suffixText: 'acres',
                icon: Icons.crop_landscape_rounded,
                useMono: true,
              ),
              const SizedBox(height: 10),
              // Quick preset chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickAreaPresets.map((area) {
                  final isSelected = double.tryParse(_areaCtrl.text.trim()) == area;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _areaCtrl.text = area == area.roundToDouble()
                            ? area.toInt().toString()
                            : area.toString();
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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

              // ── 3. Regional Language Selection ───────────────────────────
              _SectionLabel(AppStrings.get('preferred_language', _language)),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(AppColors.radiusCard),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _language,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(AppColors.radiusCard),
                    style: AppTheme.ui(size: 14, color: AppColors.textPrimary),
                    items: const [
                      DropdownMenuItem(
                        value: 'English',
                        child: Row(
                          children: [
                            Icon(Icons.language_rounded, size: 20, color: AppColors.healthy),
                            SizedBox(width: 12),
                            Text('English'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Hindi',
                        child: Row(
                          children: [
                            Icon(Icons.language_rounded, size: 20, color: AppColors.healthy),
                            SizedBox(width: 12),
                            Text('हिंदी (Hindi)'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Marathi',
                        child: Row(
                          children: [
                            Icon(Icons.language_rounded, size: 20, color: AppColors.healthy),
                            SizedBox(width: 12),
                            Text('मराठी (Marathi)'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Kannada',
                        child: Row(
                          children: [
                            Icon(Icons.language_rounded, size: 20, color: AppColors.healthy),
                            SizedBox(width: 12),
                            Text('ಕನ್ನಡ (Kannada)'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _language = v ?? 'English'),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // ── 4. Save Action Button ────────────────────────────────────
              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.healthy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  elevation: 2,
                  shadowColor: AppColors.healthy.withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppColors.radiusButton),
                  ),
                ),
                icon: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_rounded, size: 22),
                label: Text(
                  _saving ? 'Saving...' : AppStrings.get('save_settings', _language),
                  style: AppTheme.ui(size: 15, weight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: AppTheme.ui(
          size: 11,
          weight: FontWeight.w800,
          color: AppColors.healthy,
        ).copyWith(letterSpacing: 1.1),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? helper;
  final String? suffixText;
  final IconData? icon;
  final bool useMono;

  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.helper,
    this.suffixText,
    this.icon,
    this.useMono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.ui(size: 13, weight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: useMono
              ? AppTheme.mono(size: 15, weight: FontWeight.w600)
              : AppTheme.ui(size: 14),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffixText,
            prefixIcon: icon != null ? Icon(icon, size: 20, color: AppColors.textSecondary) : null,
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 5),
          Text(
            helper!,
            style: AppTheme.ui(size: 11.5, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}
