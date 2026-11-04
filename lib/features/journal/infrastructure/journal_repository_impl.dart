import '../domain/journal_entry.dart';
import '../domain/journal_repository.dart';
import 'journal_api.dart';

class JournalRepositoryImpl implements JournalRepository {
  final JournalApi api;
  JournalRepositoryImpl({required this.api});

  @override
  Future<List<JournalEntry>> getRecentEntries({int limit = 3}) => api.getRecentEntries(limit: limit);

  @override
  Future<JournalEntry> createEntry({
    required String content,
    required String category,
    String sentiment = 'neutral',
    String title = '',
  }) =>
      api.createEntry(content: content, category: category, sentiment: sentiment, title: title);
}
