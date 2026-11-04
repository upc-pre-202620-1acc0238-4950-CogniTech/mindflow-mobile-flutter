import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'habit_suggestions_view_model.dart';

class HabitSuggestionsView extends StatelessWidget {
  final HabitSuggestionsViewModel viewModel;
  const HabitSuggestionsView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.errorMessage != null && viewModel.suggestions.isEmpty) {
      return Center(child: Text(viewModel.errorMessage!, style: TextStyle(color: colors.crisisText)));
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 14, 0, 110),
        children: [
          Text('Based on your recent entries, these routines can lower stress.',
              style: TextStyle(fontSize: 15, color: colors.textSecondary)),
          const SizedBox(height: 10),
          if (viewModel.suggestions.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text('No suggestions right now.', style: TextStyle(color: colors.textSecondary)),
            )
          else
            for (var i = 0; i < viewModel.suggestions.length; i++)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.border))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(viewModel.suggestions[i].name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          Text(viewModel.suggestions[i].category,
                              style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                          if (viewModel.suggestions[i].reason.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(viewModel.suggestions[i].reason, style: const TextStyle(fontSize: 14)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: viewModel.addedIndexes.contains(i) || viewModel.addingIndex == i
                          ? null
                          : () => viewModel.add(i),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        backgroundColor: viewModel.addedIndexes.contains(i) ? colors.tintGreen : colors.primary,
                        foregroundColor: viewModel.addedIndexes.contains(i) ? colors.successText : Colors.white,
                        side: BorderSide(
                            color: viewModel.addedIndexes.contains(i) ? colors.tintGreen : colors.primary),
                      ),
                      child: viewModel.addingIndex == i
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(viewModel.addedIndexes.contains(i) ? 'Added' : 'Add'),
                    ),
                  ],
                ),
              ),
          if (viewModel.allAdded)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('You added every available suggestion.',
                  style: TextStyle(fontSize: 14, color: colors.textSecondary)),
            ),
        ],
      ),
    );
  }
}
