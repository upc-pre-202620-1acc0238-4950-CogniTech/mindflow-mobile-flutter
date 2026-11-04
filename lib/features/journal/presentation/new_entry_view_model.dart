import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../application/create_journal_entry_use_case.dart';
import '../domain/journal_entry.dart';

class NewEntryViewModel extends ChangeNotifier {
  final CreateJournalEntryUseCase createEntry;
  NewEntryViewModel({required this.createEntry});

  static const categories = ['Work', 'Family', 'Personal reflection', 'Health', 'Learning'];

  int selectedCategory = 0;
  bool isLoading = false;
  String? errorMessage;
  JournalEntry? savedEntry;

  void selectCategory(int index) {
    selectedCategory = index;
    notifyListeners();
  }

  Future<void> save(String content) async {
    if (content.trim().isEmpty) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      savedEntry = await createEntry.execute(
        content: content.trim(),
        category: categories[selectedCategory],
        sentiment: 'auto',
      );
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
