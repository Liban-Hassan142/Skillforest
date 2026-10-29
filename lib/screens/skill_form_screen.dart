import 'package:flutter/material.dart';

import '../models/skill.dart';
import '../services/database_helper.dart';

class SkillFormScreen extends StatefulWidget {
  final Skill? skill;

  const SkillFormScreen({super.key, this.skill});

  @override
  State<SkillFormScreen> createState() => _SkillFormScreenState();
}

class _SkillFormScreenState extends State<SkillFormScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _targetController = TextEditingController();
  int _difficulty = 1;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final skill = widget.skill;
    _nameController.text = skill?.name ?? '';
    _categoryController.text = skill?.category ?? 'General';
    _targetController.text = (skill?.targetHours ?? 10).toString();
    _difficulty = skill?.difficulty ?? 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    final hours = int.tryParse(_targetController.text.trim());

    if (name.isEmpty || category.isEmpty || hours == null || hours <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a name, category, and valid goal.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      if (widget.skill?.skillId != null) {
        await DatabaseHelper.instance.editSkill(
          skillId: widget.skill!.skillId!,
          name: name,
          category: category,
          difficulty: _difficulty,
          targetHours: hours,
        );
      } else {
        await DatabaseHelper.instance.insertSkill(
          name: name,
          category: category,
          difficulty: _difficulty,
          targetHours: hours,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save skill: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.skill == null ? 'Create Skill' : 'Edit Skill'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Skill Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _targetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Goal (hours)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: _difficulty,
            decoration: const InputDecoration(
              labelText: 'Difficulty',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Beginner')),
              DropdownMenuItem(value: 2, child: Text('Intermediate')),
              DropdownMenuItem(value: 3, child: Text('Advanced')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _difficulty = value);
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving...' : 'Save Skill'),
          ),
        ],
      ),
    );
  }
}
