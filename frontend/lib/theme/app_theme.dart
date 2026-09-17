import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Exact colour tokens from the AgroSentinel design spec with Dark Nature aesthetic.
class AppColors {
  // ── Primary: Deep Green (#2E7D32) ──────────────────────────────────
  static const Color healthy = Color(0xFF43A047);      // Vivid emerald
  static const Color healthyBg = Color(0xFF1B3824);    // Dark green tint

  // ── Secondary: Amber (#FFA000) ──────────────────────────────────────
  static const Color amber = Color(0xFFFFB300);        // Vivid amber
  static const Color amberBg = Color(0xFF382D12);      // Dark amber tint

  // ── Danger: Red (#D32F2F) ───────────────────────────────────────────
  static const Color disease = Color(0xFFEF5350);      // Vivid coral red
  static const Color diseaseBg = Color(0xFF3B1818);    // Dark red tint

  // ── Outbreak Alert ──────────────────────────────────────────────────
  static const Color outbreak = Color(0xFFE53935);
  static const Color outbreakBg = Color(0xFF421515);

  // ── Accent: Purple (#7B1FA2) ────────────────────────────────────────
  static const Color fl = Color(0xFFAB47BC);            // Vivid purple
  static const Color flBg = Color(0xFF2E1936);         // Dark purple tint

  // ── App Chrome & Sleek Dark Nature Surfaces ─────────────────────────
  static const Color background = Color(0xFF0D1611);    // Deep obsidian forest dark ground
  static const Color cardSurface = Color(0xFF152219);   // Premium dark slate-green card
  static const Color cardSurfaceAlt = Color(0xFF1C2C22);// Elevated card surface
  static const Color textPrimary = Color(0xFFF1F8F4);   // Crisp luminous off-white
  static const Color textSecondary = Color(0xFF96B2A2); // Botanical soft sage
  static const Color border = Color(0xFF23362A);        // Subtle hairline border

  // Compatibility aliases
  static const Color glassTextPrimary = textPrimary;
  static const Color glassTextSecondary = textSecondary;
  static const Color glassBg = background;
  static const Color glassBorder = border;
  static const Color gold = amber;
  static const Color goldLight = amberBg;
  static const Color emerald = healthy;

  // ── Glass Tunables ────────────────────────────────────────────────────
  static const double kGlassBlur = 16.0;
  static const double kGlassTileOpacity = 0.10;
  static const double kGlassNavOpacity = 0.14;

  // ── Radius tokens ────────────────────────────────────────────────────
  static const double radiusLargeCard = 22;
  static const double radiusCard = 14;
  static const double radiusButton = 14;
  static const double radiusBadge = 20;
  static const double radiusGlass = 20;
}

class AppTheme {
  // ── Text styles ──────────────────────────────────────────────────────

  /// Display role: Fraunces — screen headers, disease names, hero numbers.
  static TextStyle display({
    double size = 28,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.textPrimary,
    bool italic = false,
  }) =>
      GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: weight,
        color: color,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      );

  /// UI/body role: Poppins — everything else (buttons, labels, lists).
  static TextStyle ui({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color);

  /// Data/mono role: IBM Plex Mono — ₹ amounts, %, confidence numbers,
  /// node IDs, API URLs. Makes numbers read like sensor readouts.
  static TextStyle mono({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.ibmPlexMono(fontSize: size, fontWeight: weight, color: color);

  // ── Full Material theme ───────────────────────────────────────────────
  static ThemeData get theme {
    final base = ThemeData.dark(
      useMaterial3: true,
    );

    final poppinsText = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: poppinsText,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cardSurface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusCard),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppColors.radiusButton)),
          textStyle: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppColors.radiusButton)),
          side: const BorderSide(color: AppColors.border),
          textStyle: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w500),
          foregroundColor: AppColors.textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusCard),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusCard),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusCard),
          borderSide: const BorderSide(color: AppColors.healthy, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        hintStyle: GoogleFonts.poppins(
            color: AppColors.textSecondary, fontSize: 14),
        labelStyle: GoogleFonts.poppins(
            color: AppColors.textSecondary, fontSize: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardSurface,
        selectedItemColor: AppColors.healthy,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardSurfaceAlt,
        contentTextStyle:
            GoogleFonts.poppins(color: Colors.white, fontSize: 13),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radiusCard)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Returns the spec-correct colour for a severity string from the API.
  static Color severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return AppColors.disease;
      case 'moderate':
        return AppColors.amber;
      case 'mild':
        return AppColors.healthy;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Returns the background colour paired with [severityColor].
  static Color severityBgColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return AppColors.diseaseBg;
      case 'moderate':
        return AppColors.amberBg;
      case 'mild':
        return AppColors.healthyBg;
      default:
        return AppColors.background;
    }
  }
}
