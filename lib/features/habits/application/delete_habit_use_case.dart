import '../domain/habits_repository.dart';

class DeleteHabitUseCase {
  final HabitsRepository repository;
  DeleteHabitUseCase({required this.repository});

  Future<void> execute(int id) => repository.deleteHabit(id);
}
