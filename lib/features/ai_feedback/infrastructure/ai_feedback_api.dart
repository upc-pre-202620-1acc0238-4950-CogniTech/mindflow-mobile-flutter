import '../../../core/network/api_client.dart';
import '../domain/ai_feedback_rating.dart';
import '../domain/ai_feedback_summary.dart';

/// Rates AI-generated content the backend can verify by id: a journal
/// entry's AI reply (`contentType: 'journal'`) or a habit the AI paused
/// (`contentType: 'habit'`) — the only two types `POST /ai-feedback`
/// accepts.
class AiFeedbackApi {
  final ApiClient client;
  AiFeedbackApi({required this.client});

  Future<AiFeedbackRating> submitRating({
    required int contentId,
    required String contentType,
    required int rating,
    String? comment,
  }) async {
    final json = await client.post('/ai-feedback', body: {
      'content_id': contentId,
      'content_type': contentType,
      'rating': rating,
      if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
    });
    return AiFeedbackRating.fromJson(json as Map<String, dynamic>);
  }

  Future<List<AiFeedbackRating>> getMyRatings() async {
    final json = await client.get('/ai-feedback');
    return (json as List).map((e) => AiFeedbackRating.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AiFeedbackSummary> getSummary() async {
    final json = await client.get('/ai-feedback/summary');
    return AiFeedbackSummary.fromJson(json as Map<String, dynamic>);
  }
}
