import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/ai_feedback_rating.dart';
import 'ai_feedback_history_view_model.dart';

/// Read-only history of the ratings the user has given to AI-generated
/// content (journal AI replies, AI-paused habits), plus the backend's
/// aggregate summary. Not part of the 21-screen design — added as a
/// Settings entry point like Support, since no mock screen covers it.
class AiFeedbackHistoryPage extends StatefulWidget {
  const AiFeedbackHistoryPage({super.key});

  @override
  State<AiFeedbackHistoryPage> createState() => _AiFeedbackHistoryPageState();
}

class _AiFeedbackHistoryPageState extends State<AiFeedbackHistoryPage> {
  late final AiFeedbackHistoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<AiFeedbackHistoryViewModel>();
  }

  String _label(String contentType) => switch (contentType) {
        'journal' => 'Journal AI reply',
        'habit' => 'AI-paused habit',
        _ => contentType,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('AI feedback')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_viewModel.errorMessage != null) {
              return Center(
                  child: Text(_viewModel.errorMessage!, style: TextStyle(color: colors.crisisText)));
            }

            final summary = _viewModel.summary!;
            return RefreshIndicator(
              onRefresh: _viewModel.refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: colors.tintBlue, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your ratings', style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(summary.totalRatings == 0 ? '—' : summary.averageRating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text('/ 5 · ${summary.totalRatings} rating(s)',
                                  style: TextStyle(fontSize: 14, color: colors.textSecondary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        for (var i = 5; i >= 1; i--)
                          _DistributionBar(
                            stars: i,
                            count: summary.distribution[i] ?? 0,
                            total: summary.totalRatings,
                            colors: colors,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text('History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (_viewModel.ratings.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text('You have not rated any AI content yet.',
                          style: TextStyle(color: colors.textSecondary)),
                    )
                  else
                    for (final r in _viewModel.ratings) _RatingRow(rating: r, label: _label(r.contentType)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DistributionBar extends StatelessWidget {
  final int stars;
  final int count;
  final int total;
  final AppColors colors;

  const _DistributionBar({required this.stars, required this.count, required this.total, required this.colors});

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text('$stars', style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Icon(Icons.star, size: 12, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                backgroundColor: colors.border,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 20, child: Text('$count', style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final AiFeedbackRating rating;
  final String label;
  const _RatingRow({required this.rating, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: colors.border), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              Row(
                children: [
                  for (var i = 1; i <= 5; i++)
                    Icon(i <= rating.rating ? Icons.star : Icons.star_border, size: 15, color: colors.primary),
                ],
              ),
            ],
          ),
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(rating.comment!, style: TextStyle(fontSize: 14, color: colors.textSecondary)),
          ],
          if (rating.createdAt != null) ...[
            const SizedBox(height: 6),
            Text(DateFormat('d MMM yyyy').format(rating.createdAt!),
                style: TextStyle(fontSize: 12, color: colors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
