class PracticeSuggestion {
  final int minutes;
  final String explanation;
  final int baselineMinutes;
  const PracticeSuggestion(
    this.minutes,
    this.explanation,
    this.baselineMinutes,
  );
}

/// Deterministic, offline rules; not machine learning.
class PracticeAdvisor {
  static const int baseline = 30;

  static PracticeSuggestion? suggest({
    required int dailyGoal,
    required int difficulty,
    required int completedMinutesToday,
  }) {
    if (dailyGoal <= 0 ||
        difficulty < 1 ||
        difficulty > 3 ||
        completedMinutesToday < 0) {
      return null;
    }
    final remaining = dailyGoal - completedMinutesToday;
    if (remaining <= 0) {
      return const PracticeSuggestion(
        0,
        'Daily goal reached. You can rest or practice more if you choose.',
        baseline,
      );
    }
    final chunk = difficulty == 3
        ? 15
        : difficulty == 2
        ? 20
        : 30;
    final suggestion = remaining < chunk ? remaining : chunk;
    return PracticeSuggestion(
      suggestion,
      'You have $remaining minutes left toward your daily goal. '
      'For difficulty level $difficulty, the local rule suggests '
      'a session of up to $chunk minutes. You can change this amount.',
      baseline,
    );
  }
}
