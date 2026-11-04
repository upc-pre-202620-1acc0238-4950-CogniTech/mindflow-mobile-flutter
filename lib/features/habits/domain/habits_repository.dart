import 'habit.dart';
import 'habit_log.dart';
import 'habit_suggestion.dart';

abstract class HabitsRepository {
  Future<List<Habit>> getHabits();

  Future<Habit> createHabit({required String name, required String category, required String frequency});

  Future<void> deleteHabit(int id);

  Future<List<HabitLog>> getLogs();

  /// Marks [habit] done for today (creates a log) or undoes it (deletes
  /// the matching log for today), mirroring the Routines tab's toggle.
  Future<void> toggleToday(Habit habit, {HabitLog? existingTodayLog});

  Future<List<HabitSuggestion>> getSuggestions();
}
