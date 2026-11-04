import 'package:flutter/material.dart';

import '../application/create_habit_use_case.dart';
import '../application/get_habit_suggestions_use_case.dart';
import '../domain/habit_suggestion.dart';

class HabitSuggestionsViewModel extends ChangeNotifier {
  final GetHabitSuggestionsUseCase getSuggestions;
  final CreateHabitUseCase createHabit;

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
      errorMessage = 'Could not load suggestions right now.';
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
    } catch (_) {
      errorMessage = 'Could not add that habit. Try again.';
    } finally {
      _addingIndex = null;
      notifyListeners();
    }
  }
}
