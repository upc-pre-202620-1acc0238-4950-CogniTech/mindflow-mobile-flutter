import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Inline 1-5 star picker used to rate a specific piece of AI-generated
/// content (a journal AI reply, an AI-paused habit). [submittedRating]
/// null means not rated yet; once set, the stars become read-only.
class AiRatingStars extends StatelessWidget {
  final String prompt;
  final int? submittedRating;
  final bool isSubmitting;
  final ValueChanged<int> onRate;

  const AiRatingStars({
    super.key,
    required this.prompt,
    required this.submittedRating,
    required this.isSubmitting,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (submittedRating != null) {
      return Row(
        children: [
          for (var i = 1; i <= 5; i++)
            Icon(i <= submittedRating! ? Icons.star : Icons.star_border, size: 20, color: colors.primary),
          const SizedBox(width: 8),
          Text('Thanks for your feedback', style: TextStyle(fontSize: 13, color: colors.textSecondary)),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: Text(prompt, style: TextStyle(fontSize: 13, color: colors.textSecondary))),
        if (isSubmitting)
          const SizedBox(
              width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
        else
          for (var i = 1; i <= 5; i++)
            InkWell(
              onTap: () => onRate(i),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(Icons.star_border, size: 20, color: colors.textSecondary),
              ),
            ),
      ],
    );
  }
}
