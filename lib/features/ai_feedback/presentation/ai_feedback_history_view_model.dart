import 'package:flutter/material.dart';

import '../application/get_ai_feedback_summary_use_case.dart';
import '../application/get_my_ai_feedback_use_case.dart';
import '../domain/ai_feedback_rating.dart';
import '../domain/ai_feedback_summary.dart';

class AiFeedbackHistoryViewModel extends ChangeNotifier {
  final GetMyAiFeedbackUseCase getMyFeedback;
  final GetAiFeedbackSummaryUseCase getSummary;

  AiFeedbackHistoryViewModel({required this.getMyFeedback, required this.getSummary}) {
    refresh();
  }

  bool isLoading = true;
  String? errorMessage;
  List<AiFeedbackRating> ratings = [];
  AiFeedbackSummary? summary;

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([getMyFeedback.execute(), getSummary.execute()]);
      ratings = results[0] as List<AiFeedbackRating>;
      summary = results[1] as AiFeedbackSummary;
    } catch (_) {
      errorMessage = 'No se pudo cargar tu historial de comentarios sobre la IA.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
