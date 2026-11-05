import 'package:flutter/material.dart';

import '../../ai_feedback/application/submit_ai_feedback_use_case.dart';
import '../application/create_habit_use_case.dart';
import '../application/delete_habit_use_case.dart';
import '../application/get_habit_logs_use_case.dart';
import '../application/get_habits_use_case.dart';
import '../application/toggle_habit_today_use_case.dart';
import '../domain/habit.dart';
import '../domain/habit_log.dart';

class HabitsViewModel extends ChangeNotifier {
  final GetHabitsUseCase getHabits;
  final GetHabitLogsUseCase getLogs;
  final CreateHabitUseCase createHabit;
  final DeleteHabitUseCase deleteHabit;
  final ToggleHabitTodayUseCase toggleToday;
  final SubmitAiFeedbackUseCase submitAiFeedback;

  HabitsViewModel({
    required this.getHabits,
    required this.getLogs,
    required this.createHabit,
    required this.deleteHabit,
    required this.toggleToday,
    required this.submitAiFeedback,
  }) {
    refresh();
  }

  static const statuses = ['Todos', 'Hechos', 'Pendientes', 'Pausados'];
  static const categories = ['Salud física', 'Salud mental', 'Sueño', 'Aprendizaje'];
  static const frequencies = ['Diario', 'Semanal'];

  bool isLoading = true;
  bool isMutating = false;
  String? errorMessage;
  List<Habit> habits = [];
  List<HabitLog> logs = [];

  int statusFilterIndex = 0;
  String filterText = '';
  int? togglingHabitId;

  final Map<int, int> aiPauseRatings = {};
  int? submittingRatingForHabitId;

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _reload();
    } catch (_) {
      errorMessage = 'No se pudieron cargar tus hábitos. Desliza hacia abajo para reintentar.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Re-fetches habits/logs without the `isLoading` flag, so a single
  /// toggle/add/delete doesn't blank out the whole list with the
  /// full-screen spinner that `refresh()` shows on first load.
  Future<void> _reload() async {
    final results = await Future.wait([getHabits.execute(), getLogs.execute()]);
    habits = results[0] as List<Habit>;
    logs = results[1] as List<HabitLog>;
  }

  void setFilterText(String value) {
    filterText = value;
    notifyListeners();
  }

  void selectStatus(int index) {
    statusFilterIndex = index;
    notifyListeners();
  }

  HabitLog? todayLogFor(Habit habit) {
    final now = DateTime.now();
    for (final log in logs) {
      if (log.habitId == habit.id &&
          log.date.year == now.year &&
          log.date.month == now.month &&
          log.date.day == now.day) {
        return log;
      }
    }
    return null;
  }

  int _statusOf(Habit habit) {
    if (habit.pausedByAi) return 3;
    return todayLogFor(habit) != null ? 1 : 2;
  }

  List<Habit> get activeHabits => habits.where((h) => !h.pausedByAi).toList();

  int get doneTodayCount =>
      activeHabits.where((h) => todayLogFor(h) != null).length;

  List<Habit> get filteredHabits {
    return habits.where((h) {
      final matchesStatus = statusFilterIndex == 0 || _statusOf(h) == statusFilterIndex;
      final matchesText =
          filterText.trim().isEmpty || h.name.toLowerCase().contains(filterText.toLowerCase());
      return matchesStatus && matchesText;
    }).toList();
  }

  Future<void> toggleHabit(Habit habit) async {
    if (habit.pausedByAi || togglingHabitId != null) return;
    togglingHabitId = habit.id;
    notifyListeners();
    try {
      await toggleToday.execute(habit, existingTodayLog: todayLogFor(habit));
      await _reload();
    } catch (_) {
      errorMessage = 'No se pudo actualizar ese hábito. Intenta de nuevo.';
    } finally {
      togglingHabitId = null;
      notifyListeners();
    }
  }

  Future<bool> addHabit({required String name, required String category, required String frequency}) async {
    if (name.trim().isEmpty) return false;
    isMutating = true;
    notifyListeners();
    try {
      await createHabit.execute(name: name.trim(), category: category, frequency: frequency);
      await _reload();
      return true;
    } catch (_) {
      errorMessage = 'No se pudo agregar ese hábito. Intenta de nuevo.';
      return false;
    } finally {
      isMutating = false;
      notifyListeners();
    }
  }

  Future<void> removeHabit(int id) async {
    isMutating = true;
    notifyListeners();
    try {
      await deleteHabit.execute(id);
      await _reload();
    } catch (_) {
      errorMessage = 'No se pudo eliminar ese hábito. Intenta de nuevo.';
    } finally {
      isMutating = false;
      notifyListeners();
    }
  }

  Future<void> rateAiPause(Habit habit, int rating) async {
    submittingRatingForHabitId = habit.id;
    notifyListeners();
    try {
      await submitAiFeedback.execute(contentId: habit.id, contentType: 'habit', rating: rating);
      aiPauseRatings[habit.id] = rating;
    } catch (_) {
      errorMessage = 'No se pudo guardar tu calificación.';
    } finally {
      submittingRatingForHabitId = null;
      notifyListeners();
    }
  }
}
