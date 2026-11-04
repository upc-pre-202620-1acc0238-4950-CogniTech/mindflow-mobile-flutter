import '../domain/journal_repository.dart';

class DeleteJournalEntryUseCase {
  final JournalRepository repository;
  DeleteJournalEntryUseCase({required this.repository});

  Future<void> execute(int id) => repository.deleteEntry(id);
}
