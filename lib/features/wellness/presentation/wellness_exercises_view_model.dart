import 'package:flutter/material.dart';

import '../application/get_wellness_exercises_use_case.dart';
import '../domain/wellness_exercise.dart';

class WellnessExercisesViewModel extends ChangeNotifier {
  final GetWellnessExercisesUseCase getExercises;
  WellnessExercisesViewModel({required this.getExercises}) {
    refresh();
  }

  bool isLoading = true;
  String? errorMessage;
  List<WellnessExercise> exercises = [];

  List<WellnessExercise> get breathing =>
      exercises.where((e) => e.type == WellnessExercise.typeBreathing).toList();
  List<WellnessExercise> get meditation =>
      exercises.where((e) => e.type == WellnessExercise.typeMeditation).toList();

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      exercises = await getExercises.execute();
    } catch (_) {
      errorMessage = 'No se pudo cargar la biblioteca de ejercicios.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
