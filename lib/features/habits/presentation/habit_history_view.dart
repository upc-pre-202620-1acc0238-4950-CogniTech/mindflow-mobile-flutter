import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import 'habits_view_model.dart';

class HabitHistoryView extends StatelessWidget {
  final HabitsViewModel viewModel;
  const HabitHistoryView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final completed = viewModel.logs.where((l) => l.completed).toList()
      ..sort((a, b) => (b.completedAt ?? b.date).compareTo(a.completedAt ?? a.date));

    if (completed.isEmpty) {
      return Center(child: Text('Aún no hay hábitos completados.', style: TextStyle(color: colors.textSecondary)));
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 110),
        itemCount: completed.length,
        separatorBuilder: (_, index) => Divider(height: 1, color: colors.border),
        itemBuilder: (context, i) {
          final log = completed[i];
          final when = log.completedAt ?? log.date;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: colors.success, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.habitName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Text('Completado', style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                    ],
                  ),
                ),
                Text(_label(when), style: TextStyle(fontSize: 13, color: colors.textSecondary)),
              ],
            ),
          );
        },
      ),
    );
  }

  String _label(DateTime date) {
    final now = DateTime.now();
    final dayPart =
        DateUtils.isSameDay(date, now) ? 'Hoy' : DateFormat('EEE d').format(date);
    return '$dayPart · ${DateFormat('HH:mm').format(date)}';
  }
}
