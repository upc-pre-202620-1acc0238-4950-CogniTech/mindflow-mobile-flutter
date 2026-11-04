import '../domain/habit.dart';
import '../domain/habits_repository.dart';

class CreateHabitUseCase {
  final HabitsRepository repository;
  CreateHabitUseCase({required this.repository});

  Future<Habit> execute({required String name, required String category, required String frequency}) =>
      repository.createHabit(name: name, category: category, frequency: frequency);
}
