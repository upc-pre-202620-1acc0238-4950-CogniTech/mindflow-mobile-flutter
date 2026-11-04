import '../domain/ai_feedback_rating.dart';
import '../infrastructure/ai_feedback_api.dart';

class SubmitAiFeedbackUseCase {
  final AiFeedbackApi api;
  SubmitAiFeedbackUseCase({required this.api});

  Future<AiFeedbackRating> execute({
    required int contentId,
    required String contentType,
    required int rating,
    String? comment,
  }) =>
      api.submitRating(
        contentId: contentId,
        contentType: contentType,
        rating: rating,
        comment: comment,
      );
}
