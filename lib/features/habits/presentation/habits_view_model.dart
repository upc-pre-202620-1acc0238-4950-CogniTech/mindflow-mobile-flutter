import 'package:flutter/material.dart';

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

  HabitsViewModel({
    required this.getHabits,
    required this.getLogs,
    required this.createHabit,
    required this.deleteHabit,
    required this.toggleToday,
  }) {
    refresh();
  }

  static const statuses = ['All', 'Done', 'Pending', 'Paused'];
  static const categories = ['Physical health', 'Mental health', 'Sleep', 'Learning'];
  static const frequencies = ['Daily', 'Weekly'];

  bool isLoading = true;
  bool isMutating = false;
  String? errorMessage;
  List<Habit> habits = [];
  List<HabitLog> logs = [];

  int statusFilterIndex = 0;
  String filterText = '';

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([getHabits.execute(), getLogs.execute()]);
      habits = results[0] as List<Habit>;
      logs = results[1] as List<HabitLog>;
    } catch (_) {
      errorMessage = 'Could not load your habits. Pull down to try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
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
    if (habit.pausedByAi) return;
    isMutating = true;
    notifyListeners();
    try {
      await toggleToday.execute(habit, existingTodayLog: todayLogFor(habit));
      await refresh();
    } catch (_) {
      errorMessage = 'Could not update that habit. Try again.';
      isMutating = false;
      notifyListeners();
    }
  }

  Future<bool> addHabit({required String name, required String category, required String frequency}) async {
    if (name.trim().isEmpty) return false;
    isMutating = true;
    notifyListeners();
    try {
      await createHabit.execute(name: name.trim(), category: category, frequency: frequency);
      await refresh();
      return true;
    } catch (_) {
      errorMessage = 'Could not add that habit. Try again.';
      isMutating = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> removeHabit(int id) async {
    isMutating = true;
    notifyListeners();
    try {
      await deleteHabit.execute(id);
      await refresh();
    } catch (_) {
      errorMessage = 'Could not delete that habit. Try again.';
      isMutating = false;
      notifyListeners();
    }
  }
}
