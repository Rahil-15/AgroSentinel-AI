import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/scan_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/history_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_nav_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: const AgroSentinelApp(),
    ),
  );
}

class AgroSentinelApp extends StatelessWidget {
  const AgroSentinelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgroSentinel AI',
      theme: AppTheme.theme,
      home: const MainNavShell(),
    );
  }
}