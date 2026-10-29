class PracticeSession {
  final int? sessionId;
  final int skillId;
  final int durationMinutes;
  final String notes;
  final String sessionDate;
  final bool completed;

  PracticeSession({
    this.sessionId,
    required this.skillId,
    required this.durationMinutes,
    required this.notes,
    required this.sessionDate,
    required this.completed,
  });
}
