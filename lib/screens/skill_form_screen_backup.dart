import 'package:flutter/material.dart';

class SkillFormScreen extends StatelessWidget {
  const SkillFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Skill")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Skill Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: const Text("Save Skill")),
          ],
        ),
      ),
    );
  }
}
