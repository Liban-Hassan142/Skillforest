import 'package:flutter/material.dart';

import '../services/database_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, Object?>> _sessions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final sessions = await DatabaseHelper.instance.getAllPracticeSessions();
      if (!mounted) return;
      setState(() {
        _sessions = sessions;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final completed = _sessions
        .where((session) => session['completed'] == 1)
        .toList();

    final totalMinutes = completed.fold<int>(
      0,
      (total, session) => total + (session['durationMinutes'] as int? ?? 0),
    );

    final average = completed.isEmpty
        ? 0
        : (totalMinutes / completed.length).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History & Insights'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _loading = true);
              _loadHistory();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Could not load history: $_error'))
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Your Practice Summary',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Practice: ${totalMinutes ~/ 60}h ${totalMinutes % 60}m',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Completed Sessions: ${completed.length}'),
                          const SizedBox(height: 8),
                          Text('Average Session: $average minutes'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'All Practice Sessions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_sessions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No practice sessions yet. Start practicing to see your history!',
                      ),
                    ),
                  ..._sessions.map((session) {
                    final minutes = session['durationMinutes'] as int? ?? 0;
                    final name = session['skillName']?.toString() ?? 'Skill';
                    final notes = session['notes']?.toString() ?? '';
                    final date = _formatDate(
                      session['sessionDate']?.toString() ?? '',
                    );

                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        title: Text('$name — $minutes minutes'),
                        subtitle: Text(notes.isEmpty ? date : '$date\n$notes'),
                        isThreeLine: notes.isNotEmpty,
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
