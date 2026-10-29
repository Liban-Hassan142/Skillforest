import 'package:flutter/material.dart';

import '../models/skill.dart';

class SkillCard extends StatelessWidget {
  final Skill skill;
  final VoidCallback onTap;

  const SkillCard({super.key, required this.skill, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(_treeEmoji(skill.treeLevel)),
        title: Text(skill.name),
        subtitle: Text("Level ${skill.treeLevel}\n${skill.category}"),
        onTap: onTap,
      ),
    );
  }

  String _treeEmoji(int level) {
    if (level <= 3) return "🌱";
    if (level <= 6) return "🌿";
    return "🌳";
  }
}
