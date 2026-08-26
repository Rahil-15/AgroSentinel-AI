import 'package:flutter/material.dart';

void main() {
  runApp(const AgroApp());
}

class AgroApp extends StatelessWidget {
  const AgroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroSentinel',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AgroSentinel 🚀"),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text(
          "App is working 🚀",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}