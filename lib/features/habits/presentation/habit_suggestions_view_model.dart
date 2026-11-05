import 'package:flutter/material.dart';

import '../application/create_habit_use_case.dart';
import '../application/get_habit_suggestions_use_case.dart';
import '../domain/habit_suggestion.dart';

class HabitSuggestionsViewModel extends ChangeNotifier {
  final GetHabitSuggestionsUseCase getSuggestions;
  final CreateHabitUseCase createHabit;

  /// Called after a suggestion is successfully turned into a habit, so the
  /// Routines tab's list can be kept in sync without the user having to
  /// manually pull-to-refresh it.
  VoidCallback? onHabitAdded;

  HabitSuggestionsViewModel({required this.getSuggestions, required this.createHabit}) {
    refresh();
  }

  bool isLoading = true;
  String? errorMessage;
  List<HabitSuggestion> suggestions = [];
  final Set<int> addedIndexes = {};
  int? _addingIndex;
  int? get addingIndex => _addingIndex;

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    addedIndexes.clear();
    notifyListeners();
    try {
      suggestions = await getSuggestions.execute();
    } catch (_) {
      errorMessage = 'No se pudieron cargar sugerencias por ahora.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool get allAdded => suggestions.isNotEmpty && addedIndexes.length == suggestions.length;

  Future<void> add(int index) async {
    if (addedIndexes.contains(index)) return;
    final s = suggestions[index];
    _addingIndex = index;
    notifyListeners();
    try {
      await createHabit.execute(name: s.name, category: s.category, frequency: s.frequency);
      addedIndexes.add(index);
      onHabitAdded?.call();
    } catch (_) {
      errorMessage = 'No se pudo agregar ese hábito. Intenta de nuevo.';
    } finally {
      _addingIndex = null;
      notifyListeners();
    }
  }
}
