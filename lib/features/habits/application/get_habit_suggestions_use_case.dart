import '../domain/habit_suggestion.dart';
import '../domain/habits_repository.dart';

class GetHabitSuggestionsUseCase {
  final HabitsRepository repository;
  GetHabitSuggestionsUseCase({required this.repository});

  Future<List<HabitSuggestion>> execute() => repository.getSuggestions();
}
