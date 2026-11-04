import '../../../core/network/api_client.dart';
import '../domain/habit.dart';

class HabitsApi {
  final ApiClient client;
  HabitsApi({required this.client});

  Future<List<Habit>> getHabits() async {
    final json = await client.get('/habits');
    return (json as List).map((e) => Habit.fromJson(e as Map<String, dynamic>)).toList();
  }
}
