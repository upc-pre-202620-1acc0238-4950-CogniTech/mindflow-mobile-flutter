import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../ai_feedback/presentation/ai_rating_stars.dart';
import '../domain/habit.dart';
import 'habits_view_model.dart';

class RoutinesView extends StatelessWidget {
  final HabitsViewModel viewModel;
  const RoutinesView({super.key, required this.viewModel});

  Future<void> _openAddHabit(BuildContext context) async {
    final nameController = TextEditingController();
    int category = 0;
    int frequency = 0;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('New habit', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(hintText: 'e.g. Read 10 pages before bed'),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(HabitsViewModel.categories.length, (i) {
                        return ChoiceChip(
                          label: Text(HabitsViewModel.categories[i]),
                          selected: category == i,
                          onSelected: (_) => setSheetState(() => category = i),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(HabitsViewModel.frequencies.length, (i) {
                        final selected = frequency == i;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: i == HabitsViewModel.frequencies.length - 1 ? 0 : 8),
                            child: OutlinedButton(
                              onPressed: () => setSheetState(() => frequency = i),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(44),
                                backgroundColor: selected ? const Color(0xFF1B2333) : null,
                                foregroundColor: selected ? Colors.white : const Color(0xFF1B2333),
                                side: BorderSide(
                                    color: selected ? const Color(0xFF1B2333) : const Color(0xFFB8C0CF)),
                              ),
                              child: Text(HabitsViewModel.frequencies[i]),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: viewModel.isMutating
                          ? null
                          : () async {
                              final ok = await viewModel.addHabit(
                                name: nameController.text,
                                category: HabitsViewModel.categories[category],
                                frequency: HabitsViewModel.frequencies[frequency],
                              );
                              if (ok && context.mounted) Navigator.of(context).pop();
                            },
                      child: const Text('Add habit'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = viewModel.activeHabits.length;
    final done = viewModel.doneTodayCount;
    final pct = total == 0 ? 0.0 : done / total;

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 110),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _openAddHabit(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add habit'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
            ),
          ),
          if (viewModel.habits.any((h) => h.pausedByAi)) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: colors.warningSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stress is above your average',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  SizedBox(height: 2),
                  Text('We paused demanding habits for today. Rest comes first.',
                      style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily progress', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Text('$done of $total active', style: TextStyle(fontSize: 14, color: colors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: colors.border,
              color: colors.success,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: viewModel.setFilterText,
            decoration: const InputDecoration(hintText: 'Filter your habits', prefixIcon: Icon(Icons.search)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: HabitsViewModel.statuses.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == viewModel.statusFilterIndex;
                return ChoiceChip(
                  label: Text(HabitsViewModel.statuses[i]),
                  selected: selected,
                  onSelected: (_) => viewModel.selectStatus(i),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          if (viewModel.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(viewModel.errorMessage!, style: TextStyle(color: colors.crisisText)),
            ),
          if (viewModel.filteredHabits.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                  child: Text('No habits here.', style: TextStyle(color: colors.textSecondary))),
            )
          else
            for (final habit in viewModel.filteredHabits)
              _HabitRow(
                habit: habit,
                done: viewModel.todayLogFor(habit) != null,
                onToggle: () => viewModel.toggleHabit(habit),
                onLongPress: () => _confirmDelete(context, habit),
                myRating: viewModel.aiPauseRatings[habit.id],
                isSubmittingRating: viewModel.submittingRatingForHabitId == habit.id,
                onRate: (rating) => viewModel.rateAiPause(habit, rating),
              ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${habit.name}"?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) await viewModel.removeHabit(habit.id);
  }
}

class _HabitRow extends StatelessWidget {
  final Habit habit;
  final bool done;
  final VoidCallback onToggle;
  final VoidCallback onLongPress;
  final int? myRating;
  final bool isSubmittingRating;
  final ValueChanged<int> onRate;

  const _HabitRow({
    required this.habit,
    required this.done,
    required this.onToggle,
    required this.onLongPress,
    required this.myRating,
    required this.isSubmittingRating,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final paused = habit.pausedByAi;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.border))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: paused ? null : onToggle,
            onLongPress: onLongPress,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? colors.success : Colors.transparent,
                    border: Border.all(
                      color: paused ? colors.textSecondary : (done ? colors.success : colors.inputBorder),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: done ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.name,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: paused ? colors.textSecondary : colors.text)),
                      Text('${habit.category} · ${habit.frequency}',
                          style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                    ],
                  ),
                ),
                Text(
                  paused ? 'Paused by AI' : '${habit.streak} days',
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          if (paused) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 42),
              child: AiRatingStars(
                prompt: 'Was pausing this helpful?',
                submittedRating: myRating,
                isSubmitting: isSubmittingRating,
                onRate: onRate,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
