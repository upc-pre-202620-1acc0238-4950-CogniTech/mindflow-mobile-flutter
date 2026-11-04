import '../domain/habit.dart';
import '../infrastructure/habits_api.dart';

class GetHabitsUseCase {
  final HabitsApi api;
  GetHabitsUseCase({required this.api});

  Future<List<Habit>> execute() => api.getHabits();
}
