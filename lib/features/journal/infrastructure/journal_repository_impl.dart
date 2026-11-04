import '../domain/journal_entry.dart';
import '../domain/journal_repository.dart';
import 'journal_api.dart';

class JournalRepositoryImpl implements JournalRepository {
  final JournalApi api;
  JournalRepositoryImpl({required this.api});

  @override
  Future<List<JournalEntry>> getRecentEntries({int limit = 3}) => api.getRecentEntries(limit: limit);

  @override
  Future<List<JournalEntry>> getEntries({String? query}) => api.getEntries(query: query);

  @override
  Future<JournalEntry> getEntry(int id) => api.getEntry(id);

  @override
  Future<JournalEntry> createEntry({
    required String content,
    required String category,
    String sentiment = 'neutral',
    String title = '',
  }) =>
      api.createEntry(content: content, category: category, sentiment: sentiment, title: title);

  @override
  Future<JournalEntry> updateEntry({
    required int id,
    required String title,
    required String content,
    required String sentiment,
    required String category,
  }) =>
      api.updateEntry(id: id, title: title, content: content, sentiment: sentiment, category: category);

  @override
  Future<void> deleteEntry(int id) => api.deleteEntry(id);
}
