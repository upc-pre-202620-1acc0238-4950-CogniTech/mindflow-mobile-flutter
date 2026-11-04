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

  /// Full list for the Journal tab (List/Calendar). Category and sentiment
  /// are filtered client-side since the backend doesn't take those as
  /// query params; `q` runs a real server-side search over encrypted
  /// content via a hashed token index.
  Future<List<JournalEntry>> getEntries({String? query}) async {
    final json = await client.get('/journal/entries', query: {
      '_sort': 'date',
      '_order': 'desc',
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
    });
    return (json as List).map((e) => JournalEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<JournalEntry> getEntry(int id) async {
    final json = await client.get('/journal/entries/$id');
    return JournalEntry.fromJson(json as Map<String, dynamic>);
  }

  Future<JournalEntry> updateEntry({
    required int id,
    required String title,
    required String content,
    required String sentiment,
    required String category,
  }) async {
    final json = await client.put('/journal/entries/$id', body: {
      'title': title,
      'content': content,
      'sentiment': sentiment,
      'category': category,
    });
    return JournalEntry.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteEntry(int id) => client.delete('/journal/entries/$id');

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
