import 'journal_entry.dart';

abstract class JournalRepository {
  Future<List<JournalEntry>> getRecentEntries({int limit});

  Future<JournalEntry> createEntry({
    required String content,
    required String category,
    String sentiment,
    String title,
  });
}
