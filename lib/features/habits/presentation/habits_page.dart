import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import 'habit_history_view.dart';
import 'habit_suggestions_view.dart';
import 'habit_suggestions_view_model.dart';
import 'habits_view_model.dart';
import 'routines_view.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  late final HabitsViewModel _habitsViewModel;
  late final HabitSuggestionsViewModel _suggestionsViewModel;
  int _tab = 0;

  static const _tabs = ['Rutinas', 'Sugerencias IA', 'Historial'];

  @override
  void initState() {
    super.initState();
    _habitsViewModel = getIt<HabitsViewModel>();
    _suggestionsViewModel = getIt<HabitSuggestionsViewModel>()
      ..onHabitAdded = _habitsViewModel.refresh;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hábitos',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.01)),
              const SizedBox(height: 12),
              Row(
                children: List.generate(_tabs.length, (i) {
                  final selected = i == _tab;
                  return Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _tab = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: selected ? colors.primary : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _tabs[i],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            color: selected ? colors.primary : colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: Listenable.merge([_habitsViewModel, _suggestionsViewModel]),
                  builder: (context, _) {
                    switch (_tab) {
                      case 1:
                        return HabitSuggestionsView(viewModel: _suggestionsViewModel);
                      case 2:
                        return HabitHistoryView(viewModel: _habitsViewModel);
                      default:
                        return RoutinesView(viewModel: _habitsViewModel);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
