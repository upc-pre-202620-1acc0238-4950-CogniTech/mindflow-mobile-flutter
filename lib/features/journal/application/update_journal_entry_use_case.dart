import '../domain/journal_entry.dart';
import '../domain/journal_repository.dart';

class UpdateJournalEntryUseCase {
  final JournalRepository repository;
  UpdateJournalEntryUseCase({required this.repository});

  Future<JournalEntry> execute({
    required int id,
    required String title,
    required String content,
    required String sentiment,
    required String category,
  }) =>
      repository.updateEntry(
          id: id, title: title, content: content, sentiment: sentiment, category: category);
}
