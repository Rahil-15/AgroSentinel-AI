/// Mirrors the POST /predict response documented in the API contract.
/// Every field name matches the JSON key exactly so fromJson stays trivial
/// once Poorvita's real API is ready.
class PredictionResult {
  final String crop;
  final String disease;
  final double confidence; // 0.0 - 1.0
  final bool isHealthy;
  final String gradcamImage; // base64 string
  final String severity; // Mild / Moderate / Severe
  final double infectedPct;
  final int estimatedLossInr;
  final int yieldLossPct;
  final String lossSummary;
  final Treatment treatment;
  final OutbreakAlert outbreakAlert;
  final List<TopPrediction> top3;

  PredictionResult({
    required this.crop,
    required this.disease,
    required this.confidence,
    required this.isHealthy,
    required this.gradcamImage,
    required this.severity,
    required this.infectedPct,
    required this.estimatedLossInr,
    required this.yieldLossPct,
    required this.lossSummary,
    required this.treatment,
    required this.outbreakAlert,
    required this.top3,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      crop: json['crop'] ?? '',
      disease: json['disease'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      isHealthy: json['is_healthy'] ?? false,
      gradcamImage: json['gradcam_image'] ?? '',
      severity: json['severity'] ?? '',
      infectedPct: (json['infected_pct'] ?? 0).toDouble(),
      estimatedLossInr: (json['estimated_loss_inr'] ?? 0).toInt(),
      yieldLossPct: (json['yield_loss_pct'] ?? 0).toInt(),
      lossSummary: json['loss_summary'] ?? '',
      treatment: Treatment.fromJson(json['treatment'] ?? {}),
      outbreakAlert: OutbreakAlert.fromJson(json['outbreak_alert'] ?? {}),
      top3: ((json['top3'] ?? []) as List)
          .map((e) => TopPrediction.fromJson(e))
          .toList(),
    );
  }
}

class Treatment {
  final List<String> steps;
  final List<String> medication;
  final List<String> prevention;

  Treatment({
    required this.steps,
    required this.medication,
    required this.prevention,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      steps: List<String>.from(json['steps'] ?? []),
      medication: List<String>.from(json['medication'] ?? []),
      prevention: List<String>.from(json['prevention'] ?? []),
    );
  }
}

class OutbreakAlert {
  final bool outbreak;
  final String message;

  OutbreakAlert({required this.outbreak, required this.message});

  factory OutbreakAlert.fromJson(Map<String, dynamic> json) {
    return OutbreakAlert(
      outbreak: json['outbreak'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class TopPrediction {
  final String label;
  final double confidence;

  TopPrediction({required this.label, required this.confidence});

  factory TopPrediction.fromJson(Map<String, dynamic> json) {
    return TopPrediction(
      label: json['label'] ?? json['disease'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
    );
  }
}

/// One row in scan history, used by GET /history and the Analytics screen.
class HistoryEntry {
  final String id;
  final String crop;
  final String disease;
  final double confidence;
  final bool isHealthy;
  final int estimatedLossInr;
  final DateTime date;

  HistoryEntry({
    required this.id,
    required this.crop,
    required this.disease,
    required this.confidence,
    required this.isHealthy,
    required this.estimatedLossInr,
    required this.date,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id']?.toString() ?? '',
      crop: json['crop'] ?? '',
      disease: json['disease'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      isHealthy: json['is_healthy'] ?? false,
      estimatedLossInr: (json['estimated_loss_inr'] ?? 0).toInt(),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }
}
