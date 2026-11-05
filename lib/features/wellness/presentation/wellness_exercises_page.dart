import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../pause/presentation/breathing_pause_page.dart';
import '../../pause/presentation/micro_meditation_page.dart';
import '../domain/wellness_exercise.dart';
import 'wellness_exercises_view_model.dart';

/// Catalog of guided exercises from `GET /wellness/exercises` — real
/// content, not the two fixed "Breathing"/"Meditation" buttons the
/// design mock hardcodes.
class WellnessExercisesPage extends StatefulWidget {
  const WellnessExercisesPage({super.key});

  @override
  State<WellnessExercisesPage> createState() => _WellnessExercisesPageState();
}

class _WellnessExercisesPageState extends State<WellnessExercisesPage> {
  late final WellnessExercisesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<WellnessExercisesViewModel>();
  }

  void _open(WellnessExercise exercise) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => exercise.isBreathing
          ? BreathingPausePage(exercise: exercise)
          : MicroMeditationPage(exercise: exercise),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Pausas rápidas')),
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
            return RefreshIndicator(
              onRefresh: _viewModel.refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  if (_viewModel.breathing.isNotEmpty) ...[
                    Text('Respiración', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                    const SizedBox(height: 8),
                    for (final e in _viewModel.breathing) _ExerciseTile(exercise: e, onTap: () => _open(e)),
                    const SizedBox(height: 16),
                  ],
                  if (_viewModel.meditation.isNotEmpty) ...[
                    Text('Meditación', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                    const SizedBox(height: 8),
                    for (final e in _viewModel.meditation) _ExerciseTile(exercise: e, onTap: () => _open(e)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final WellnessExercise exercise;
  final VoidCallback onTap;
  const _ExerciseTile({required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(exercise.description, style: TextStyle(fontSize: 14, color: colors.textSecondary)),
            const SizedBox(height: 4),
            Text(exercise.durationLabel, style: TextStyle(fontSize: 13, color: colors.primary)),
          ],
        ),
      ),
    );
  }
}
