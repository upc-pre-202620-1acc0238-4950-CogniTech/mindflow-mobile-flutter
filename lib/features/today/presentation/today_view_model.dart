import 'package:flutter/material.dart';

import '../../journal/application/create_journal_entry_use_case.dart';
import '../../journal/domain/journal_entry.dart';
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
    MoodOption('Great', 'positive'),
    MoodOption('Good', 'positive'),
    MoodOption('Okay', 'neutral'),
    MoodOption('Stressed', 'negative'),
    MoodOption('Low', 'negative'),
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
      errorMessage = 'Could not load Today. Pull down to try again.';
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
        content: 'Check-in: feeling ${mood.word.toLowerCase()}.',
        category: 'Personal reflection',
        sentiment: mood.sentiment,
      );
      await refresh();
    } catch (_) {
      errorMessage = 'Could not save your check-in. Try again.';
    } finally {
      isCheckingIn = false;
      notifyListeners();
    }
  }

  int get activeHabits => snapshot?.habits.where((h) => !h.pausedByAi).length ?? 0;
  int get pausedHabits => snapshot?.habits.where((h) => h.pausedByAi).length ?? 0;
  int get totalHabits => snapshot?.habits.length ?? 0;
}
