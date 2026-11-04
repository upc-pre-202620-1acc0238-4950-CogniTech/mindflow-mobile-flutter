import '../domain/ai_feedback_summary.dart';
import '../infrastructure/ai_feedback_api.dart';

class GetAiFeedbackSummaryUseCase {
  final AiFeedbackApi api;
  GetAiFeedbackSummaryUseCase({required this.api});

  Future<AiFeedbackSummary> execute() => api.getSummary();
}
