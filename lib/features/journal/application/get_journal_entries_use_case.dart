import '../domain/journal_entry.dart';
import '../domain/journal_repository.dart';

class GetJournalEntriesUseCase {
  final JournalRepository repository;
  GetJournalEntriesUseCase({required this.repository});

  Future<List<JournalEntry>> execute({String? query}) => repository.getEntries(query: query);
}
