import 'package:flutter/foundation.dart';
import '../models/prediction_result.dart';
import '../dummy_data.dart';

/// Backs Screen 5 (Analytics/History) and the Home dashboard summary cards.
///
/// DAY 3-4 (now): fetchHistory() just loads DummyData.history.
/// DAY 6: swap the body to call ApiService.getHistory().
class HistoryProvider extends ChangeNotifier {
  List<HistoryEntry> _all = [];
  bool isLoading = false;
  String? selectedCropFilter; // null = all crops

  List<HistoryEntry> get entries {
    if (selectedCropFilter == null) return _all;
    return _all.where((e) => e.crop == selectedCropFilter).toList();
  }

  int get totalScansToday {
    final now = DateTime.now();
    return _all
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .length;
  }

  int get totalFinancialLoss =>
      entries.fold(0, (sum, e) => sum + e.estimatedLossInr);

  HistoryEntry? get latest => _all.isEmpty ? null : _all.first;

  Map<String, int> get diseaseFrequency {
    final map = <String, int>{};
    for (final e in entries) {
      if (e.isHealthy) continue;
      map[e.disease] = (map[e.disease] ?? 0) + 1;
    }
    return map;
  }

  Future<void> fetchHistory() async {
    isLoading = true;
    notifyListeners();

    // --- DUMMY MODE (Day 3-4) ---
    await Future.delayed(const Duration(milliseconds: 600));
    _all = DummyData.history;

    // --- REAL MODE (Day 6) will instead be:
    // _all = await ApiService.getHistory();

    isLoading = false;
    notifyListeners();
  }

  void setCropFilter(String? crop) {
    selectedCropFilter = crop;
    notifyListeners();
  }
}
