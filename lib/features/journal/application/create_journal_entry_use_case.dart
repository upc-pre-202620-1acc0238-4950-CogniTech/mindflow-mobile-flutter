import '../domain/journal_entry.dart';
import '../domain/journal_repository.dart';

class CreateJournalEntryUseCase {
  final JournalRepository repository;
  CreateJournalEntryUseCase({required this.repository});

  Future<JournalEntry> execute({
    required String content,
    required String category,
    String sentiment = 'neutral',
    String title = '',
  }) =>
      repository.createEntry(content: content, category: category, sentiment: sentiment, title: title);
}
