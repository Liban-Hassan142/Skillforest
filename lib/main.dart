import 'package:flutter/material.dart';
import 'package:skillforest/screens/splash_screen.dart';


void main() {
  runApp(const SkillForestApp());
}

class SkillForestApp extends StatelessWidget {
  const SkillForestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SkillForest",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}
