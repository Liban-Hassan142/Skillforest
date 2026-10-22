import 'package:flutter/material.dart';

class SkillFormScreen extends StatelessWidget {
  const SkillFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Skill")),
      body: const Center(child: Text("Skill Form Screen")),
    );
  }
}
