import '../domain/habit.dart';
import '../domain/habits_repository.dart';

class GetHabitsUseCase {
  final HabitsRepository repository;
  GetHabitsUseCase({required this.repository});

  Future<List<Habit>> execute() => repository.getHabits();
}
