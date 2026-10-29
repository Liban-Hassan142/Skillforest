import 'package:flutter/material.dart';

import '../models/skill.dart';
import '../services/database_helper.dart';
import 'skill_form_screen.dart';

class SkillDetailScreen extends StatefulWidget {
  final Skill skill;

  const SkillDetailScreen({super.key, required this.skill});

  @override
  State<SkillDetailScreen> createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends State<SkillDetailScreen> {
  final _minutesController = TextEditingController();
  final _notesController = TextEditingController();

  List<Map<String, Object?>> _sessions = [];
  int _totalMinutes = 0;
  int _treeLevel = 1;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _treeLevel = widget.skill.treeLevel;
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final id = widget.skill.skillId;
    if (id == null) return;

    final sessions = await DatabaseHelper.instance.getPracticeSessions(id);
    final total = await DatabaseHelper.instance.getTotalPracticeMinutes(id);
    final level = await DatabaseHelper.instance.updateTreeLevel(id);

    if (!mounted) return;

    setState(() {
      _sessions = sessions;
      _totalMinutes = total;
      _treeLevel = level;
    });
  }

  Future<void> _saveSession() async {
    final minutes = int.tryParse(_minutesController.text.trim());

    if (minutes == null || minutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid number of practice minutes.'),
        ),
      );
      return;
    }

    final id = widget.skill.skillId;
    if (id == null) return;

    setState(() => _saving = true);

    try {
      await DatabaseHelper.instance.insertPracticeSession(
        skillId: id,
        durationMinutes: minutes,
        notes: _notesController.text,
      );

      _minutesController.clear();
      _notesController.clear();

      await _loadSessions();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Practice session saved!')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save session: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _editSkill() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => SkillFormScreen(skill: widget.skill)),
    );
    if (changed == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteSkill() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Skill?'),
        content: const Text(
          'This will also delete all practice sessions for this skill.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final id = widget.skill.skillId;
    if (id == null) return;

    await DatabaseHelper.instance.deleteSkill(id);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetMinutes = widget.skill.targetHours * 60;
    final progress = targetMinutes > 0
        ? (_totalMinutes / targetMinutes).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.skill.name),
        actions: [
          IconButton(
            tooltip: 'Edit Skill',
            icon: const Icon(Icons.edit),
            onPressed: _editSkill,
          ),
          IconButton(
            tooltip: 'Delete Skill',
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteSkill,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Text(
              _treeLevel <= 3
                  ? '🌱'
                  : _treeLevel <= 6
                  ? '🌿'
                  : '🌳',
              style: const TextStyle(fontSize: 80),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              widget.skill.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 8),
          Center(child: Text(widget.skill.category)),
          const SizedBox(height: 24),
          Text(
            'Total Practice: $_totalMinutes minutes',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 8),
          Text('Goal: ${widget.skill.targetHours} hours'),
          const SizedBox(height: 28),
          Text(
            'Log Practice Session',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _minutesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Practice Minutes',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Practice Notes',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saving ? null : _saveSession,
            child: Text(_saving ? 'Saving...' : 'Save Session'),
          ),
          const SizedBox(height: 28),
          Text(
            'Practice History',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (_sessions.isEmpty) const Text('No practice sessions yet.'),
          ..._sessions.map((session) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text('${session['durationMinutes']} minutes'),
                subtitle: Text(
                  '${session['notes']}\n${session['sessionDate']}',
                ),
                isThreeLine: true,
              ),
            );
          }),
        ],
      ),
    );
  }
}
