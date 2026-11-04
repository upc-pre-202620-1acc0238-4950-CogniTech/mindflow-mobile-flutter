import '../domain/habit.dart';
import '../domain/habit_log.dart';
import '../domain/habits_repository.dart';

class ToggleHabitTodayUseCase {
  final HabitsRepository repository;
  ToggleHabitTodayUseCase({required this.repository});

  Future<void> execute(Habit habit, {HabitLog? existingTodayLog}) =>
      repository.toggleToday(habit, existingTodayLog: existingTodayLog);
}
