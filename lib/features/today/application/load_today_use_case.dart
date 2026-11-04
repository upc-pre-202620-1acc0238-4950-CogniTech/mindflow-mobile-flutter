import '../../habits/application/get_habits_use_case.dart';
import '../../habits/domain/habit.dart';
import '../../journal/application/get_recent_entries_use_case.dart';
import '../../journal/domain/journal_entry.dart';
import '../../profile/application/get_profile_use_case.dart';
import '../../profile/domain/user_profile.dart';

class TodaySnapshot {
  final UserProfile profile;
  final List<Habit> habits;
  final List<JournalEntry> recentEntries;

  const TodaySnapshot({required this.profile, required this.habits, required this.recentEntries});
}

/// Aggregates the real data Today (W1) can honestly show today: the
/// signed-in profile, the user's habits (for the "N active / M paused by
/// AI" summary) and the last journal entries. There is no backend concept
/// of a calendar "agenda" yet, so Today does not fabricate one.
class LoadTodayUseCase {
  final GetProfileUseCase getProfile;
  final GetHabitsUseCase getHabits;
  final GetRecentEntriesUseCase getRecentEntries;

  LoadTodayUseCase({
    required this.getProfile,
    required this.getHabits,
    required this.getRecentEntries,
  });

  Future<TodaySnapshot> execute() async {
    final results = await Future.wait([
      getProfile.execute(),
      getHabits.execute(),
      getRecentEntries.execute(limit: 3),
    ]);
    return TodaySnapshot(
      profile: results[0] as UserProfile,
      habits: results[1] as List<Habit>,
      recentEntries: results[2] as List<JournalEntry>,
    );
  }
}
