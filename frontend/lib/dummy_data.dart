import 'models/prediction_result.dart';

/// All fake data lives here. Once api_service.dart is wired up (Day 5-6),
/// screens stop importing this file and use live API responses instead.
/// Keeping every dummy object shaped exactly like the real JSON contract
/// means that swap is just changing the data source, not the UI code.
class DummyData {
  static PredictionResult get sampleResult => PredictionResult(
        crop: 'Rice',
        disease: 'Brown Spot',
        confidence: 0.97,
        isHealthy: false,
        gradcamImage: '', // empty in dummy mode; UI shows a placeholder
        severity: 'Moderate',
        infectedPct: 18.4,
        estimatedLossInr: 21830,
        yieldLossPct: 25,
        lossSummary:
            'Brown Spot has affected 18.4% of the crop area, projected to reduce yield by 25% if untreated.',
        treatment: Treatment(
          steps: [
            'Remove and destroy infected leaves immediately',
            'Improve field drainage to reduce moisture buildup',
            'Apply recommended fungicide within 48 hours',
            'Re-inspect the field after 7 days',
          ],
          medication: [
            'Mancozeb 75% WP - 2.5g/litre water',
            'Propiconazole 25% EC - 1ml/litre water',
          ],
          prevention: [
            'Use certified disease-free seeds',
            'Avoid excess nitrogen fertilizer',
            'Maintain proper plant spacing for airflow',
          ],
        ),
        outbreakAlert: OutbreakAlert(
          outbreak: true,
          message:
              'Brown Spot detected in 6 nearby fields this week. Regional outbreak risk is elevated.',
        ),
        top3: [
          TopPrediction(label: 'Brown Spot', confidence: 0.97),
          TopPrediction(label: 'Bacterial Leaf Blight', confidence: 0.02),
          TopPrediction(label: 'Healthy', confidence: 0.01),
        ],
      );

  static PredictionResult get sampleHealthyResult => PredictionResult(
        crop: 'Tomato',
        disease: 'Healthy',
        confidence: 0.99,
        isHealthy: true,
        gradcamImage: '',
        severity: 'None',
        infectedPct: 0,
        estimatedLossInr: 0,
        yieldLossPct: 0,
        lossSummary: 'No signs of disease detected. Crop looks healthy.',
        treatment: Treatment(steps: [], medication: [], prevention: [
          'Continue current watering schedule',
          'Monitor weekly for early signs of stress',
        ]),
        outbreakAlert: OutbreakAlert(outbreak: false, message: ''),
        top3: [
          TopPrediction(label: 'Healthy', confidence: 0.99),
          TopPrediction(label: 'Early Blight', confidence: 0.008),
          TopPrediction(label: 'Leaf Mold', confidence: 0.002),
        ],
      );

  static List<HistoryEntry> get history => [
        HistoryEntry(
          id: '1',
          crop: 'Rice',
          disease: 'Brown Spot',
          confidence: 0.97,
          isHealthy: false,
          estimatedLossInr: 21830,
          date: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        HistoryEntry(
          id: '2',
          crop: 'Tomato',
          disease: 'Healthy',
          confidence: 0.99,
          isHealthy: true,
          estimatedLossInr: 0,
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
        HistoryEntry(
          id: '3',
          crop: 'Potato',
          disease: 'Late Blight',
          confidence: 0.91,
          isHealthy: false,
          estimatedLossInr: 15400,
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
        HistoryEntry(
          id: '4',
          crop: 'Corn (Maize)',
          disease: 'Common Rust',
          confidence: 0.88,
          isHealthy: false,
          estimatedLossInr: 9200,
          date: DateTime.now().subtract(const Duration(days: 3)),
        ),
        HistoryEntry(
          id: '5',
          crop: 'Rice',
          disease: 'Healthy',
          confidence: 0.95,
          isHealthy: true,
          estimatedLossInr: 0,
          date: DateTime.now().subtract(const Duration(days: 4)),
        ),
      ];

  static const List<String> cropFolders = ['Corn (Maize)', 'Potato', 'Rice', 'Tomato'];
}
