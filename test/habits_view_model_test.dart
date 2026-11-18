import 'package:flutter_test/flutter_test.dart';
import 'package:mindflow_workday/features/habits/application/create_habit_use_case.dart';
import 'package:mindflow_workday/features/habits/application/delete_habit_use_case.dart';
import 'package:mindflow_workday/features/habits/application/get_habit_logs_use_case.dart';
import 'package:mindflow_workday/features/habits/application/get_habits_use_case.dart';
import 'package:mindflow_workday/features/habits/application/toggle_habit_today_use_case.dart';
import 'package:mindflow_workday/features/habits/domain/habit.dart';
import 'package:mindflow_workday/features/habits/domain/habit_log.dart';
import 'package:mindflow_workday/features/habits/domain/habit_suggestion.dart';
import 'package:mindflow_workday/features/habits/domain/habits_repository.dart';
import 'package:mindflow_workday/features/habits/presentation/habits_view_model.dart';
import 'package:mindflow_workday/features/ai_feedback/application/submit_ai_feedback_use_case.dart';
import 'package:mindflow_workday/features/wellness/application/run_stress_check_use_case.dart';

class FakeHabitsRepository implements HabitsRepository {
  int created = 0;
  int stressChecks = 0;
  final List<Habit> habits = [];

  @override
  Future<List<Habit>> getHabits() async => List.of(habits);

  @override
  Future<Habit> createHabit({required String name, required String category, required String frequency}) async {
    created++;
    await Future<void>.delayed(const Duration(milliseconds: 50)); // latencia del servidor
    final habit = Habit(id: created, name: name, category: category, frequency: frequency, streak: 0, status: 'pending', pausedByAi: false);
    habits.add(habit);
    return habit;
  }

  @override
  Future<List<HabitLog>> getLogs() async => [];
  @override
  Future<void> deleteHabit(int id) async {}
  @override
  Future<void> toggleToday(Habit habit, {HabitLog? existingTodayLog}) async {}
  @override
  Future<List<HabitSuggestion>> getSuggestions() async => [];
}

void main() {
  test('tocar "Agregar hábito" dos veces seguidas crea un solo hábito', () async {
    final repo = FakeHabitsRepository();
    final vm = HabitsViewModel(
      getHabits: GetHabitsUseCase(repository: repo),
      getLogs: GetHabitLogsUseCase(repository: repo),
      createHabit: CreateHabitUseCase(repository: repo),
      deleteHabit: DeleteHabitUseCase(repository: repo),
      toggleToday: ToggleHabitTodayUseCase(repository: repo),
      submitAiFeedback: _NoFeedback(),
      runStressCheck: _NoStress(),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final first = vm.addHabit(name: 'Leer', category: 'Aprendizaje', frequency: 'Diario');
    final second = vm.addHabit(name: 'Leer', category: 'Aprendizaje', frequency: 'Diario');

    expect(await first, isTrue);
    expect(await second, isFalse);
    expect(repo.created, 1);
  });
}

class _NoFeedback implements SubmitAiFeedbackUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoStress implements RunStressCheckUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) async => false;
}
