import 'package:flutter/material.dart';
import 'ui/screens/match_setup_screen.dart';

void main() {
  runApp(const DartScorerApp());
}

class DartScorerApp extends StatelessWidget {
  const DartScorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dart Scorer & Checkout Engine',
      theme: ThemeData.dark(),
      home: const MatchSetupScreen(),
    );
  }
}
