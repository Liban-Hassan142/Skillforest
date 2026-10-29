import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _reminders = false;
  int _dailyGoal = 30;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _reminders = prefs.getBool('reminders') ?? false;
      _dailyGoal = prefs.getInt('dailyGoal') ?? 30;
      _loading = false;
    });
  }

  Future<void> _saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    if (mounted) setState(() => _darkMode = value);
  }

  Future<void> _saveReminders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminders', value);
    if (mounted) setState(() => _reminders = value);
  }

  Future<void> _saveDailyGoal(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyGoal', value);
    if (mounted) setState(() => _dailyGoal = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'App Preferences',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Dark Mode Preference'),
                  subtitle: const Text('Save your preferred appearance'),
                  value: _darkMode,
                  onChanged: _saveDarkMode,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Practice Reminder Preference'),
                  subtitle: const Text('Save your reminder preference'),
                  value: _reminders,
                  onChanged: _saveReminders,
                ),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Daily Practice Goal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _dailyGoal,
                  decoration: const InputDecoration(
                    labelText: 'Minutes per day',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 15, child: Text('15 minutes')),
                    DropdownMenuItem(value: 30, child: Text('30 minutes')),
                    DropdownMenuItem(value: 45, child: Text('45 minutes')),
                    DropdownMenuItem(value: 60, child: Text('60 minutes')),
                    DropdownMenuItem(value: 90, child: Text('90 minutes')),
                  ],
                  onChanged: (value) {
                    if (value != null) _saveDailyGoal(value);
                  },
                ),
                const SizedBox(height: 24),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('SkillForest'),
                    subtitle: Text(
                      'Grow your skills one practice session at a time.',
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
