import '../../../core/network/api_client.dart';
import '../domain/wellness_exercise.dart';

class WellnessApi {
  final ApiClient client;
  WellnessApi({required this.client});

  /// POST /wellness/stress-check. Returns true when the backend paused or
  /// resumed at least one habit (so the caller should reload the list).
  Future<bool> runStressCheck() async {
    final json = await client.post('/wellness/stress-check') as Map<String, dynamic>;
    bool nonEmpty(String key) => (json[key] as List?)?.isNotEmpty ?? false;
    return nonEmpty('paused_habits') || nonEmpty('resumed_habits');
  }

  Future<List<WellnessExercise>> getExercises({String? type}) async {
    final json = await client.get('/wellness/exercises', query: {
      'type': ?type,
    });
    return (json as List).map((e) => WellnessExercise.fromJson(e as Map<String, dynamic>)).toList();
  }
}
