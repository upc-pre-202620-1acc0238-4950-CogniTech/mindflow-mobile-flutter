import '../domain/journal_entry.dart';
import '../domain/journal_repository.dart';

class GetRecentEntriesUseCase {
  final JournalRepository repository;
  GetRecentEntriesUseCase({required this.repository});

  Future<List<JournalEntry>> execute({int limit = 3}) => repository.getRecentEntries(limit: limit);
}
