import 'package:flutter_test/flutter_test.dart';
import 'package:skillforest/services/practice_advisor.dart';

void main() {
  test('beginner uses 30 minute chunk', () {
    expect(
      PracticeAdvisor.suggest(
        dailyGoal: 60,
        difficulty: 1,
        completedMinutesToday: 0,
      )!.minutes,
      30,
    );
  });
  test('intermediate uses 20 minute chunk', () {
    expect(
      PracticeAdvisor.suggest(
        dailyGoal: 60,
        difficulty: 2,
        completedMinutesToday: 0,
      )!.minutes,
      20,
    );
  });
  test('advanced uses 15 minute chunk', () {
    expect(
      PracticeAdvisor.suggest(
        dailyGoal: 60,
        difficulty: 3,
        completedMinutesToday: 0,
      )!.minutes,
      15,
    );
  });
  test('remaining goal caps suggestion', () {
    expect(
      PracticeAdvisor.suggest(
        dailyGoal: 30,
        difficulty: 1,
        completedMinutesToday: 25,
      )!.minutes,
      5,
    );
  });
  test('completed goal suggests rest', () {
    expect(
      PracticeAdvisor.suggest(
        dailyGoal: 30,
        difficulty: 1,
        completedMinutesToday: 30,
      )!.minutes,
      0,
    );
  });
  test('invalid goal gets no recommendation', () {
    expect(
      PracticeAdvisor.suggest(
        dailyGoal: 0,
        difficulty: 1,
        completedMinutesToday: 0,
      ),
      isNull,
    );
  });
  test('invalid difficulty gets no recommendation', () {
    expect(
      PracticeAdvisor.suggest(
        dailyGoal: 30,
        difficulty: 4,
        completedMinutesToday: 0,
      ),
      isNull,
    );
  });
  test('negative practiced time gets no recommendation', () {
    expect(
      PracticeAdvisor.suggest(
        dailyGoal: 30,
        difficulty: 1,
        completedMinutesToday: -1,
      ),
      isNull,
    );
  });
  test('more than goal suggests rest', () {
    expect(
      PracticeAdvisor.suggest(
        dailyGoal: 30,
        difficulty: 2,
        completedMinutesToday: 50,
      )!.minutes,
      0,
    );
  });
  test('baseline is 30 minutes', () {
    expect(PracticeAdvisor.baseline, 30);
  });
}
