import '../../../core/network/api_client.dart';
import '../domain/journal_entry.dart';

class JournalApi {
  final ApiClient client;
  JournalApi({required this.client});

  Future<List<JournalEntry>> getRecentEntries({int limit = 3}) async {
    final json = await client.get('/journal/entries', query: {
      '_sort': 'date',
      '_order': 'desc',
      '_limit': limit,
    });
    return (json as List).map((e) => JournalEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<JournalEntry> createEntry({
    required String content,
    required String category,
    String sentiment = 'neutral',
    String title = '',
  }) async {
    final today = DateTime.now();
    final date =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final json = await client.post('/journal/entries', body: {
      'date': date,
      'title': title,
      'content': content,
      'sentiment': sentiment,
      'category': category,
    });
    return JournalEntry.fromJson(json as Map<String, dynamic>);
  }
}
