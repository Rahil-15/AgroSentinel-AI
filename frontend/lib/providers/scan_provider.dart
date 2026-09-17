import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/prediction_result.dart';
import '../dummy_data.dart';

/// Drives Screen 2 (Scan) → Screen 3 (Result) → Screen 4 (Treatment).
///
/// DUMMY MODE (now): analyze() waits 2 s and returns DummyData.sampleResult.
/// REAL MODE (Day 6): swap the body of analyze() to call ApiService.predict()
/// — nothing in the screens changes because they only read result/isLoading/error.
class ScanProvider extends ChangeNotifier {
  /// Mobile image file (null on web)
  File? selectedImage;

  /// Web XFile — holds the bytes on web where dart:io File isn't available
  XFile? webImageFile;

  double fieldArea = 1.0;
  bool isLoading = false;
  String? error;
  PredictionResult? result;

  bool get hasImage =>
      kIsWeb ? webImageFile != null : selectedImage != null;

  void setImage(File image) {
    selectedImage = image;
    webImageFile = null;
    error = null;
    notifyListeners();
  }

  /// Called from ScanScreen on web platform.
  void setWebImage(XFile file) {
    webImageFile = file;
    selectedImage = null;
    error = null;
    notifyListeners();
  }

  void setFieldArea(double acres) {
    fieldArea = acres;
    notifyListeners();
  }

  Future<void> analyze() async {
    if (!hasImage) {
      error = 'Please take or upload a leaf photo first.';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // ── DUMMY MODE ─────────────────────────────────────────────────
      await Future.delayed(const Duration(seconds: 2));
      result = DummyData.sampleResult;

      // ── REAL MODE (Day 6) ──────────────────────────────────────────
      // result = await ApiService.predictDisease(
      //   image: selectedImage,
      //   webImage: webImageFile,
      //   fieldAreaAcres: fieldArea,
      //   nodeId: settingsProvider.nodeId,
      //   apiBaseUrl: settingsProvider.apiBaseUrl,
      // );
    } catch (e) {
      error = 'Could not reach the server. '
          'Check the API URL in Settings and your Wi-Fi connection.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    selectedImage = null;
    webImageFile = null;
    result = null;
    error = null;
    notifyListeners();
  }
}
