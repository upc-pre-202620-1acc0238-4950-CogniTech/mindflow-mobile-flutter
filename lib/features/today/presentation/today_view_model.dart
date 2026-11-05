import 'package:flutter/material.dart';

import '../../journal/application/create_journal_entry_use_case.dart';
import '../../journal/domain/journal_entry.dart';
import '../../wellness/domain/wellness_exercise.dart';
import '../application/load_today_use_case.dart';

class MoodOption {
  final String word;
  final String sentiment;
  const MoodOption(this.word, this.sentiment);
}

class TodayViewModel extends ChangeNotifier {
  final LoadTodayUseCase loadToday;
  final CreateJournalEntryUseCase createEntry;

  TodayViewModel({required this.loadToday, required this.createEntry}) {
    refresh();
  }

  static const moods = [
    MoodOption('Genial', 'positive'),
    MoodOption('Bien', 'positive'),
    MoodOption('Normal', 'neutral'),
    MoodOption('Estresado', 'negative'),
    MoodOption('Bajo', 'negative'),
  ];

  bool isLoading = true;
  String? errorMessage;
  TodaySnapshot? snapshot;

  int? selectedMood;
  bool isCheckingIn = false;
  JournalEntry? checkInResult;

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      snapshot = await loadToday.execute();
    } catch (e) {
      errorMessage = 'No se pudo cargar Hoy. Desliza hacia abajo para reintentar.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void pickMood(int index) {
    selectedMood = index;
    notifyListeners();
  }

  Future<void> saveCheckIn() async {
    if (selectedMood == null) return;
    isCheckingIn = true;
    notifyListeners();
    try {
      final mood = moods[selectedMood!];
      checkInResult = await createEntry.execute(
        content: 'Check-in: me siento ${mood.word.toLowerCase()}.',
        category: 'Reflexión personal',
        sentiment: mood.sentiment,
      );
      await refresh();
    } catch (_) {
      errorMessage = 'No se pudo guardar tu check-in. Intenta de nuevo.';
    } finally {
      isCheckingIn = false;
      notifyListeners();
    }
  }

  int get activeHabits => snapshot?.habits.where((h) => !h.pausedByAi).length ?? 0;
  int get pausedHabits => snapshot?.habits.where((h) => h.pausedByAi).length ?? 0;
  int get totalHabits => snapshot?.habits.length ?? 0;

  WellnessExercise? get featuredBreathing {
    final list = snapshot?.exercises.where((e) => e.type == WellnessExercise.typeBreathing).toList();
    return (list == null || list.isEmpty) ? null : list.first;
  }

  WellnessExercise? get featuredMeditation {
    final list = snapshot?.exercises.where((e) => e.type == WellnessExercise.typeMeditation).toList();
    return (list == null || list.isEmpty) ? null : list.first;
  }
}
