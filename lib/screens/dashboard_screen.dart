import 'skill_detail_screen.dart';

import 'package:flutter/material.dart';

import '../models/skill.dart';
import '../services/database_helper.dart';
import '../widgets/skill_card.dart';
import 'skill_form_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Skill> _skills = [];
  bool _loading = true;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    try {
      final rows = await DatabaseHelper.instance.getSkills();

      final skills = rows.map((row) {
        return Skill(
          skillId: row['skillId'] as int,
          name: row['name'] as String,
          category: row['category'] as String,
          difficulty: row['difficulty'] as int,
          targetHours: row['targetHours'] as int,
          treeLevel: row['treeLevel'] as int,
          dateCreated: row['dateCreated'] as String,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _skills = skills;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not load skills: $error')));
    }
  }

  Future<void> _addSkill() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const SkillFormScreen()),
    );

    if (saved == true) {
      await _loadSkills();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All',
      ...{for (final skill in _skills) skill.category},
    ];

    final selected = categories.contains(_selectedCategory)
        ? _selectedCategory
        : 'All';

    final visibleSkills = selected == 'All'
        ? _skills
        : _skills.where((skill) => skill.category == selected).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SkillForest'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),

          IconButton(
            tooltip: 'History & Insights',
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _skills.isEmpty
          ? const Center(
              child: Text(
                'Your forest is empty!\nTap + to plant your first skill.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  '🌲 Your Forest',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text('Total Skills: ${_skills.length}'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selected,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                if (visibleSkills.isEmpty)
                  const Text('No skills in this category.'),
                ...visibleSkills.map(
                  (skill) => SkillCard(
                    skill: skill,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SkillDetailScreen(skill: skill),
                        ),
                      );
                      if (mounted) await _loadSkills();
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSkill,
        child: const Icon(Icons.add),
      ),
    );
  }
}
