import 'journal_entry.dart';

abstract class JournalRepository {
  Future<List<JournalEntry>> getRecentEntries({int limit});

  Future<List<JournalEntry>> getEntries({String? query});

  Future<JournalEntry> getEntry(int id);

  Future<JournalEntry> createEntry({
    required String content,
    required String category,
    String sentiment,
    String title,
  });

  Future<JournalEntry> updateEntry({
    required int id,
    required String title,
    required String content,
    required String sentiment,
    required String category,
  });

  Future<void> deleteEntry(int id);
}
