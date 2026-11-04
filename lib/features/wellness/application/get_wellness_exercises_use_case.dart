import '../domain/wellness_exercise.dart';
import '../infrastructure/wellness_api.dart';

class GetWellnessExercisesUseCase {
  final WellnessApi api;
  GetWellnessExercisesUseCase({required this.api});

  Future<List<WellnessExercise>> execute({String? type}) => api.getExercises(type: type);
}
