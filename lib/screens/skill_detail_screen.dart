import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/practice_advisor.dart';

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
  int _dailyGoal = 30;

  @override
  void initState() {
    super.initState();
    _treeLevel = widget.skill.treeLevel;
    _loadSessions();
    _loadGoal();
  }

  Future<void> _loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _dailyGoal = prefs.getInt('dailyGoal') ?? 30);
  }

  Future<void> _editSession(Map<String, Object?> session) async {
    final id = widget.skill.skillId;
    if (id == null) return;
    final minutes = TextEditingController(
      text: '${session['durationMinutes']}',
    );
    final notes = TextEditingController(text: '${session['notes'] ?? ''}');
    final messenger = ScaffoldMessenger.of(context);
    try {
      final save = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Edit Practice Session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: minutes,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Minutes'),
              ),
              TextField(
                controller: notes,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (save != true || !mounted) return;
      final value = int.tryParse(minutes.text.trim());
      if (value == null || value <= 0) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Enter valid minutes greater than zero.'),
          ),
        );
        return;
      }
      await DatabaseHelper.instance.updatePracticeSession(
        sessionId: session['sessionId'] as int,
        skillId: id,
        durationMinutes: value,
        notes: notes.text,
      );
      await _loadSessions();
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Could not edit session: $error')),
        );
      }
    } finally {
      minutes.dispose();
      notes.dispose();
    }
  }

  Future<void> _deleteSession(Map<String, Object?> session) async {
    final id = widget.skill.skillId;
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Practice Session?'),
        content: const Text('This session will be removed from your history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await DatabaseHelper.instance.deletePracticeSession(
        sessionId: session['sessionId'] as int,
        skillId: id,
      );
      await _loadSessions();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete session: $error')),
        );
      }
    }
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

    final suggestion = PracticeAdvisor.suggest(
      dailyGoal: _dailyGoal,
      difficulty: widget.skill.difficulty,
      completedMinutesToday: _sessions
          .where((session) {
            final date = DateTime.tryParse('${session['sessionDate']}');
            final now = DateTime.now();
            return date != null &&
                date.year == now.year &&
                date.month == now.month &&
                date.day == now.day &&
                session['completed'] == 1;
          })
          .fold<int>(
            0,
            (sum, session) => sum + (session['durationMinutes'] as int? ?? 0),
          ),
    );
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart Practice Helper (local rules)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    suggestion == null
                        ? 'Invalid goal or difficulty.'
                        : suggestion.minutes == 0
                        ? 'Daily goal complete!'
                        : 'Suggested session: ${suggestion.minutes} minutes',
                  ),
                  const SizedBox(height: 6),
                  Text(suggestion?.explanation ?? 'Check your saved settings.'),
                  const SizedBox(height: 6),
                  Text(
                    'Baseline: ${PracticeAdvisor.baseline} minutes. '
                    'Suggestion uses your daily goal, skill difficulty, and today\'s practice.',
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: suggestion == null || suggestion.minutes == 0
                        ? null
                        : () {
                            _minutesController.text = suggestion.minutes
                                .toString();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Suggestion applied. You can edit minutes before saving.',
                                ),
                              ),
                            );
                          },
                    child: const Text('Use Suggestion (optional)'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                trailing: Wrap(
                  children: [
                    IconButton(
                      tooltip: 'Edit Session',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _editSession(session),
                    ),
                    IconButton(
                      tooltip: 'Delete Session',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteSession(session),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
