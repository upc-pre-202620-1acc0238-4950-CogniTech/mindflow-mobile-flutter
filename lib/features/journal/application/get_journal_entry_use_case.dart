import '../domain/journal_entry.dart';
import '../domain/journal_repository.dart';

class GetJournalEntryUseCase {
  final JournalRepository repository;
  GetJournalEntryUseCase({required this.repository});

  Future<JournalEntry> execute(int id) => repository.getEntry(id);
}
