import '../domain/habit.dart';
import '../domain/habit_log.dart';
import '../domain/habit_suggestion.dart';
import '../domain/habits_repository.dart';
import 'habits_api.dart';

class HabitsRepositoryImpl implements HabitsRepository {
  final HabitsApi api;
  HabitsRepositoryImpl({required this.api});

  @override
  Future<List<Habit>> getHabits() => api.getHabits();

  @override
  Future<Habit> createHabit({required String name, required String category, required String frequency}) =>
      api.createHabit(name: name, category: category, frequency: frequency);

  @override
  Future<void> deleteHabit(int id) => api.deleteHabit(id);

  @override
  Future<List<HabitLog>> getLogs() => api.getLogs();

  @override
  Future<void> toggleToday(Habit habit, {HabitLog? existingTodayLog}) async {
    if (existingTodayLog != null) {
      await api.deleteLog(existingTodayLog.id);
    } else {
      await api.createLog(
        habitId: habit.id,
        habitName: habit.name,
        category: habit.category,
        date: DateTime.now(),
      );
    }
  }

  @override
  Future<List<HabitSuggestion>> getSuggestions() => api.getSuggestions();
}
