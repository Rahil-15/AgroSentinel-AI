import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists all user-editable settings via shared_preferences.
/// Screens read from this provider; nothing holds settings in local state.
///
/// Default API URL is Poorvita's laptop on local Wi-Fi.
class SettingsProvider extends ChangeNotifier {
  // ── Fields ──────────────────────────────────────────────────────────
  String farmerName = 'Farmer';
  double defaultFieldArea = 1.0;
  String apiBaseUrl = 'http://192.168.1.5:8000';
  String nodeId = 'node-001';
  String language = 'English';
  bool isLoaded = false;

  // ── Keys ────────────────────────────────────────────────────────────
  static const _kName = 'farmerName';
  static const _kArea = 'defaultFieldArea';
  static const _kUrl = 'apiBaseUrl';
  static const _kNode = 'nodeId';
  static const _kLang = 'language';

  // ── Load ────────────────────────────────────────────────────────────
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      farmerName = prefs.getString(_kName) ?? 'Farmer';
      defaultFieldArea = prefs.getDouble(_kArea) ?? 1.0;
      apiBaseUrl =
          prefs.getString(_kUrl) ?? 'http://192.168.1.5:8000';
      nodeId = prefs.getString(_kNode) ?? 'node-001';
      language = prefs.getString(_kLang) ?? 'English';
      isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('SettingsProvider.load error: $e');
    }
  }

  // ── Save ────────────────────────────────────────────────────────────
  Future<void> save({
    required String farmerName,
    required double defaultFieldArea,
    required String apiBaseUrl,
    required String nodeId,
    required String language,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    this.farmerName = farmerName;
    this.defaultFieldArea = defaultFieldArea;
    this.apiBaseUrl = apiBaseUrl;
    this.nodeId = nodeId;
    this.language = language;

    await prefs.setString(_kName, farmerName);
    await prefs.setDouble(_kArea, defaultFieldArea);
    await prefs.setString(_kUrl, apiBaseUrl);
    await prefs.setString(_kNode, nodeId);
    await prefs.setString(_kLang, language);

    notifyListeners();
  }
}