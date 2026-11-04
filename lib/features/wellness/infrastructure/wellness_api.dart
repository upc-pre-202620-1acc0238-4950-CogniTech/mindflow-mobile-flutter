import '../../../core/network/api_client.dart';
import '../domain/wellness_exercise.dart';

class WellnessApi {
  final ApiClient client;
  WellnessApi({required this.client});

  Future<List<WellnessExercise>> getExercises({String? type}) async {
    final json = await client.get('/wellness/exercises', query: {
      if (type != null) 'type': type,
    });
    return (json as List).map((e) => WellnessExercise.fromJson(e as Map<String, dynamic>)).toList();
  }
}
