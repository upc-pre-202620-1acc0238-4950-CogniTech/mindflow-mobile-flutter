import '../domain/ai_feedback_rating.dart';
import '../infrastructure/ai_feedback_api.dart';

class GetMyAiFeedbackUseCase {
  final AiFeedbackApi api;
  GetMyAiFeedbackUseCase({required this.api});

  Future<List<AiFeedbackRating>> execute() => api.getMyRatings();
}
