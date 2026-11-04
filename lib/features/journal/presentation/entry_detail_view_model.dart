import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../application/delete_journal_entry_use_case.dart';
import '../application/get_journal_entry_use_case.dart';
import '../application/update_journal_entry_use_case.dart';
import '../domain/journal_entry.dart';

class EntryDetailViewModel extends ChangeNotifier {
  final GetJournalEntryUseCase getEntry;
  final UpdateJournalEntryUseCase updateEntry;
  final DeleteJournalEntryUseCase deleteEntry;

  EntryDetailViewModel({
    required this.getEntry,
    required this.updateEntry,
    required this.deleteEntry,
  });

  bool isLoading = true;
  bool isSaving = false;
  bool isDeleted = false;
  String? errorMessage;
  JournalEntry? entry;

  Future<void> load(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      entry = await getEntry.execute(id);
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> save({
    required String title,
    required String content,
    required String sentiment,
    required String category,
  }) async {
    if (entry == null) return false;
    isSaving = true;
    notifyListeners();
    try {
      entry = await updateEntry.execute(
        id: entry!.id,
        title: title,
        content: content,
        sentiment: sentiment,
        category: category,
      );
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> delete() async {
    if (entry == null) return false;
    isSaving = true;
    notifyListeners();
    try {
      await deleteEntry.execute(entry!.id);
      isDeleted = true;
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
