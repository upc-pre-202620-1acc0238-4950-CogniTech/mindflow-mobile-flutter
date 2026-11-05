import 'dart:async';

import 'package:flutter/material.dart';

import '../application/get_journal_entries_use_case.dart';
import '../domain/journal_entry.dart';

class JournalListViewModel extends ChangeNotifier {
  final GetJournalEntriesUseCase getEntries;
  JournalListViewModel({required this.getEntries}) {
    refresh();
  }

  /// Entries can only ever be created with these categories (see
  /// NewEntryPage); 'All' is a UI-only filter, not a real category.
  static const categories = ['Todas', 'Trabajo', 'Familia', 'Reflexión personal', 'Salud', 'Aprendizaje'];

  /// Display labels for the sentiment filter. Index 0 means "any".
  static const sentiments = ['Cualquier estado', 'Positivo', 'Neutral', 'Negativo'];

  /// The backend always returns sentiment as English ('positive' /
  /// 'neutral' / 'negative'), regardless of the app's display language —
  /// this is what [filteredEntries] actually matches against.
  static const _sentimentValues = ['', 'positive', 'neutral', 'negative'];

  bool isLoading = true;
  String? errorMessage;
  List<JournalEntry> _entries = [];

  int categoryIndex = 0;
  int sentimentIndex = 0;
  String searchText = '';
  Timer? _debounce;

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      _entries = await getEntries.execute(query: searchText.trim().isEmpty ? null : searchText);
    } catch (_) {
      errorMessage = 'No se pudo cargar tu diario. Desliza hacia abajo para reintentar.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String value) {
    searchText = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), refresh);
  }

  void selectCategory(int index) {
    categoryIndex = index;
    notifyListeners();
  }

  void selectSentiment(int index) {
    sentimentIndex = index;
    notifyListeners();
  }

  List<JournalEntry> get filteredEntries {
    return _entries.where((e) {
      final matchesCategory = categoryIndex == 0 || e.category == categories[categoryIndex];
      final matchesSentiment = sentimentIndex == 0 ||
          e.sentiment.toLowerCase() == _sentimentValues[sentimentIndex];
      return matchesCategory && matchesSentiment;
    }).toList();
  }

  List<JournalEntry> get allEntries => _entries;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
