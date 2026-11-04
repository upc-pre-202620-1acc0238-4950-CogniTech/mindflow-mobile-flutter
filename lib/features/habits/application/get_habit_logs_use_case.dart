import '../domain/habit_log.dart';
import '../domain/habits_repository.dart';

class GetHabitLogsUseCase {
  final HabitsRepository repository;
  GetHabitLogsUseCase({required this.repository});

  Future<List<HabitLog>> execute() => repository.getLogs();
}
