import 'package:flutter/material.dart';

import '../models/skill.dart';
import '../widgets/skill_card.dart';
import '../screens/skill_form_screen.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final List<Skill> skills = [
    Skill(
      skillId: 1,
      name: "Flutter",
      category: "Programming",
      difficulty: 8,
      targetHours: 100,
      treeLevel: 5,
      dateCreated: "2026-10-21",
    ),
    Skill(
      skillId: 2,
      name: "Guitar",
      category: "Music",
      difficulty: 6,
      targetHours: 75,
      treeLevel: 2,
      dateCreated: "2026-10-21",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SkillForest")),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              "🌲 Your Forest",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: skills.length,
              itemBuilder: (context, index) {
                return SkillCard(skill: skills[index], onTap: () {});
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SkillFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
