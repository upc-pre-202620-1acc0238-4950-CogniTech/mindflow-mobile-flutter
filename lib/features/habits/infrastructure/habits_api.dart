import '../../../core/network/api_client.dart';
import '../domain/habit.dart';
import '../domain/habit_log.dart';
import '../domain/habit_suggestion.dart';

class HabitsApi {
  final ApiClient client;
  HabitsApi({required this.client});

  Future<List<Habit>> getHabits() async {
    final json = await client.get('/habits');
    return (json as List).map((e) => Habit.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Habit> createHabit({
    required String name,
    required String category,
    required String frequency,
  }) async {
    final json = await client.post('/habits', body: {
      'name': name,
      'category': category,
      'frequency': frequency,
      // Ignored server-side (the controller overwrites it with the JWT's
      // user id) but the resource requires the field.
      'user_id': 0,
    });
    return Habit.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteHabit(int id) => client.delete('/habits/$id');

  Future<List<HabitLog>> getLogs({int? habitId}) async {
    final json = await client.get('/habit-logs', query: {
      if (habitId != null) 'habit_id': habitId,
    });
    return (json as List).map((e) => HabitLog.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<HabitLog> createLog({
    required int habitId,
    required String habitName,
    required String category,
    required DateTime date,
  }) async {
    final dateStr = _isoDate(date);
    final json = await client.post('/habit-logs', body: {
      'habit_id': habitId,
      'habit_name': habitName,
      'category': category,
      'date': dateStr,
      'completed': true,
      'completed_at': DateTime.now().toIso8601String(),
    });
    return HabitLog.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteLog(int id) => client.delete('/habit-logs/$id');

  Future<List<HabitSuggestion>> getSuggestions() async {
    final json = await client.post('/habits/suggestions');
    final list = (json as Map<String, dynamic>)['suggestions'] as List;
    return list.map((e) => HabitSuggestion.fromJson(e as Map<String, dynamic>)).toList();
  }

  String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
