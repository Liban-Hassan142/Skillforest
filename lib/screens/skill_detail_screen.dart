import 'package:flutter/material.dart';

class SkillDetailScreen extends StatelessWidget {
  const SkillDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Skill Details")),
      body: const Center(child: Text("Skill Detail Screen")),
    );
  }
}
