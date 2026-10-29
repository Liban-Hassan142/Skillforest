import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await openDatabase(
      join(await getDatabasesPath(), 'skillforest.db'),
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE skills (
            skillId INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            difficulty INTEGER NOT NULL,
            targetHours INTEGER NOT NULL,
            treeLevel INTEGER NOT NULL DEFAULT 1,
            dateCreated TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE practice_sessions (
            sessionId INTEGER PRIMARY KEY AUTOINCREMENT,
            skillId INTEGER NOT NULL,
            durationMinutes INTEGER NOT NULL,
            notes TEXT NOT NULL DEFAULT '',
            sessionDate TEXT NOT NULL,
            completed INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY(skillId) REFERENCES skills(skillId)
              ON DELETE CASCADE
          )
        ''');
      },
    );

    return _database!;
  }

  Future<int> insertSkill({
    required String name,
    required String category,
    required int difficulty,
    required int targetHours,
  }) async {
    final db = await database;

    return db.insert('skills', {
      'name': name.trim(),
      'category': category,
      'difficulty': difficulty,
      'targetHours': targetHours,
      'treeLevel': 1,
      'dateCreated': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, Object?>>> getSkills() async {
    final db = await database;
    return db.query('skills', orderBy: 'skillId DESC');
  }

  Future<int> insertPracticeSession({
    required int skillId,
    required int durationMinutes,
    required String notes,
  }) async {
    if (durationMinutes <= 0) {
      throw ArgumentError('Practice time must be greater than zero.');
    }

    final db = await database;
    return db.insert('practice_sessions', {
      'skillId': skillId,
      'durationMinutes': durationMinutes,
      'notes': notes.trim(),
      'sessionDate': DateTime.now().toIso8601String(),
      'completed': 1,
    });
  }

  Future<List<Map<String, Object?>>> getPracticeSessions(int skillId) async {
    final db = await database;
    return db.query(
      'practice_sessions',
      where: 'skillId = ?',
      whereArgs: [skillId],
      orderBy: 'sessionDate DESC',
    );
  }

  Future<int> getTotalPracticeMinutes(int skillId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(durationMinutes), 0) AS total '
      'FROM practice_sessions WHERE skillId = ? AND completed = 1',
      [skillId],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> updateTreeLevel(int skillId) async {
    final totalMinutes = await getTotalPracticeMinutes(skillId);
    final newLevel = (1 + totalMinutes ~/ 60).clamp(1, 10);

    final db = await database;
    await db.update(
      'skills',
      {'treeLevel': newLevel},
      where: 'skillId = ?',
      whereArgs: [skillId],
    );

    return newLevel;
  }

  Future<int> editSkill({
    required int skillId,
    required String name,
    required String category,
    required int difficulty,
    required int targetHours,
  }) async {
    final db = await database;
    return db.update(
      'skills',
      {
        'name': name.trim(),
        'category': category.trim(),
        'difficulty': difficulty,
        'targetHours': targetHours,
      },
      where: 'skillId = ?',
      whereArgs: [skillId],
    );
  }

  Future<int> deleteSkill(int skillId) async {
    final db = await database;
    return db.transaction((txn) async {
      await txn.delete(
        'practice_sessions',
        where: 'skillId = ?',
        whereArgs: [skillId],
      );
      return txn.delete('skills', where: 'skillId = ?', whereArgs: [skillId]);
    });
  }

  Future<List<Map<String, Object?>>> getAllPracticeSessions() async {
    final db = await database;
    return db.rawQuery('''
      SELECT
        p.sessionId,
        p.skillId,
        p.durationMinutes,
        p.notes,
        p.sessionDate,
        p.completed,
        s.name AS skillName,
        s.category AS skillCategory
      FROM practice_sessions p
      INNER JOIN skills s ON s.skillId = p.skillId
      ORDER BY p.sessionDate DESC, p.sessionId DESC
    ''');
  }

  Future<void> close() async {
    final db = _database;
    _database = null;
    if (db != null && db.isOpen) {
      await db.close();
    }
  }
}
