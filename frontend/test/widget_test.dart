import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:frontend/main.dart';
import 'package:frontend/dummy_data.dart';
import 'package:frontend/providers/scan_provider.dart';
import 'package:frontend/providers/settings_provider.dart';
import 'package:frontend/providers/history_provider.dart';
import 'package:frontend/widgets/leaf_gauge.dart';
import 'package:frontend/screens/result_screen.dart';
import 'package:frontend/theme/app_theme.dart';

Widget _createTestApp({Widget? child}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ChangeNotifierProvider(create: (_) => ScanProvider()),
      ChangeNotifierProvider(create: (_) => HistoryProvider()),
    ],
    child: MaterialApp(
      theme: AppTheme.theme,
      home: child ?? const AgroSentinelApp(),
    ),
  );
}

void main() {
  testWidgets('AgroSentinelApp smoke test & bottom navigation', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => ScanProvider()),
          ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ],
        child: const AgroSentinelApp(),
      ),
    );
    // Use pump() instead of pumpAndSettle() because the WelcomeBanner
    // has an infinitely repeating pulse animation that never settles.
    await tester.pump(const Duration(seconds: 1));

    // Verify app bar title
    expect(find.text('AgroSentinel'), findsOneWidget);

    // Verify 4 bottom navigation tabs are present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Scan'), findsWidgets);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);

    // Verify Home content — hero banner and 7-day health
    expect(find.text('7-Day Field Health'), findsOneWidget);
    expect(find.text('89% Field Health'), findsOneWidget);

    // Switch to Scan tab
    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();
    expect(find.text('Scan a Leaf'), findsWidgets);
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Field area (acres)'), findsOneWidget);

    // Switch to Analytics tab
    await tester.tap(find.text('Analytics'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Analytics & History'), findsOneWidget);
    expect(find.text('Total financial loss'), findsOneWidget);

    // Switch to Alerts tab
    await tester.tap(find.text('Alerts'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Outbreak Alerts'), findsOneWidget);
  });

  testWidgets('LeafGauge renders percentage and label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LeafGauge(
            value: 0.97,
            label: 'Confidence',
            color: AppColors.disease,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('97%'), findsOneWidget);
    expect(find.text('Confidence'), findsOneWidget);
  });

  testWidgets('ResultScreen and TreatmentScreen flow', (tester) async {
    final sample = DummyData.sampleResult;

    await tester.pumpWidget(
      _createTestApp(
        child: ResultScreen(result: sample),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Brown Spot'), findsWidgets);
    expect(find.text('Detection Result'), findsOneWidget);

    // Scroll down to reveal View Treatment Plan CTA
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    final treatmentBtn = find.text('View Treatment Plan');
    expect(treatmentBtn, findsOneWidget);
    await tester.tap(treatmentBtn);
    await tester.pumpAndSettle();

    expect(find.text('Treatment Plan'), findsOneWidget);
    expect(find.text('OUTBREAK ALERT'), findsOneWidget);
    expect(find.text('Step-by-step treatment'), findsOneWidget);
    expect(find.text('Federated Learning Network'), findsOneWidget);
  });
}
