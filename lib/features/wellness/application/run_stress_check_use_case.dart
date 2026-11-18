import '../infrastructure/wellness_api.dart';

class RunStressCheckUseCase {
  final WellnessApi api;
  RunStressCheckUseCase({required this.api});

  /// True when habits were paused/resumed as a result of the check.
  Future<bool> execute() => api.runStressCheck();
}
