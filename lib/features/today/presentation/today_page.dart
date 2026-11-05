import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../journal/presentation/entry_detail_page.dart';
import '../../journal/presentation/new_entry_page.dart';
import '../../notifications/presentation/notifications_page.dart';
import '../../notifications/presentation/notifications_view_model.dart';
import '../../pause/presentation/breathing_pause_page.dart';
import '../../pause/presentation/micro_meditation_page.dart';
import '../../wellness/presentation/wellness_exercises_page.dart';
import 'today_view_model.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late final TodayViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<TodayViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.isLoading && _viewModel.snapshot == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: _viewModel.refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                children: [
                  if (_viewModel.errorMessage != null) ...[
                    Text(_viewModel.errorMessage!, style: TextStyle(color: colors.crisisText)),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(_viewModel.snapshot?.profile.displayName ?? ''),
                              style: TextStyle(fontSize: 14, color: colors.textSecondary),
                            ),
                            Text(
                              DateFormat('EEEE, d MMMM').format(DateTime.now()),
                              style: const TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: -0.01),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          if (_viewModel.pausedHabits > 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: colors.warningSurface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_viewModel.pausedHabits} pausados',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colors.warningText),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          const _NotificationBell(),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Hábitos',
                          value: '${_viewModel.activeHabits} de ${_viewModel.totalHabits}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'Entradas recientes',
                          value: '${_viewModel.snapshot?.recentEntries.length ?? 0}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.tintBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Check-in · ¿cómo va tu día?',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(TodayViewModel.moods.length, (i) {
                            final selected = i == _viewModel.selectedMood;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    right: i == TodayViewModel.moods.length - 1 ? 0 : 6),
                                child: ChoiceChip(
                                  label: FittedBox(
                                      child: Text(TodayViewModel.moods[i].word)),
                                  labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                                  visualDensity: VisualDensity.compact,
                                  selected: selected,
                                  onSelected: (_) => _viewModel.pickMood(i),
                                  selectedColor: colors.primary,
                                  backgroundColor: colors.surface,
                                  labelStyle: TextStyle(
                                      fontSize: 13,
                                      color: selected ? Colors.white : colors.text),
                                  side: BorderSide(
                                      color:
                                          selected ? colors.primary : const Color(0xFFB8C0CF)),
                                ),
                              ),
                            );
                          }),
                        ),
                        if (_viewModel.selectedMood != null &&
                            TodayViewModel.moods[_viewModel.selectedMood!].sentiment ==
                                'negative') ...[
                          const SizedBox(height: 10),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 14, color: colors.text),
                              children: [
                                const TextSpan(
                                    text: 'Si se siente pesado, la Línea 113, opción 5, es '
                                        'gratuita y está disponible las 24 horas. '),
                                TextSpan(
                                  text: 'Llamar al 113',
                                  style: TextStyle(
                                      color: colors.crisisText, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: (_viewModel.selectedMood == null || _viewModel.isCheckingIn)
                              ? null
                              : _viewModel.saveCheckIn,
                          child: _viewModel.isCheckingIn
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Guardar y hablarlo'),
                        ),
                        if (_viewModel.checkInResult?.aiResponse != null) ...[
                          const SizedBox(height: 10),
                          Text(_viewModel.checkInResult!.aiResponse!,
                              style: const TextStyle(fontSize: 15, height: 1.4)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      final saved = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(builder: (_) => const NewEntryPage()));
                      if (saved == true) _viewModel.refresh();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Escribe lo que tienes en mente',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Privado y encriptado. MindFlow AI responde con apoyo.',
                              style: TextStyle(fontSize: 14, color: colors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pausas rápidas',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const WellnessExercisesPage())),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                        child: const Text('Ver todas', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (_viewModel.featuredBreathing == null && _viewModel.featuredMeditation == null)
                    Text('No hay ejercicios guiados disponibles por ahora.',
                        style: TextStyle(fontSize: 14, color: colors.textSecondary))
                  else
                    Row(
                      children: [
                        if (_viewModel.featuredBreathing != null)
                          Expanded(
                            child: _QuickPauseTile(
                              title: _viewModel.featuredBreathing!.name,
                              subtitle: _viewModel.featuredBreathing!.durationLabel,
                              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) =>
                                      BreathingPausePage(exercise: _viewModel.featuredBreathing!))),
                            ),
                          ),
                        if (_viewModel.featuredBreathing != null && _viewModel.featuredMeditation != null)
                          const SizedBox(width: 10),
                        if (_viewModel.featuredMeditation != null)
                          Expanded(
                            child: _QuickPauseTile(
                              title: _viewModel.featuredMeditation!.name,
                              subtitle: _viewModel.featuredMeditation!.durationLabel,
                              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) =>
                                      MicroMeditationPage(exercise: _viewModel.featuredMeditation!))),
                            ),
                          ),
                      ],
                    ),
                  if ((_viewModel.snapshot?.recentEntries.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 24),
                    Text('Entradas recientes',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary)),
                    const SizedBox(height: 10),
                    for (final entry in _viewModel.snapshot!.recentEntries)
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => EntryDetailPage(entryId: entry.id)));
                          _viewModel.refresh();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: colors.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat('d MMM').format(entry.date),
                                  style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                              const SizedBox(height: 4),
                              Text(
                                entry.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _greeting(String name) {
    final hour = DateTime.now().hour;
    final period = hour < 12 ? 'Buenos días' : (hour < 18 ? 'Buenas tardes' : 'Buenas noches');
    return name.isEmpty ? period : '$period, $name';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _QuickPauseTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _QuickPauseTile({required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            Text(subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: colors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _NotificationBell extends StatefulWidget {
  const _NotificationBell();

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell> {
  late final NotificationsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<NotificationsViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () async {
            await Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const NotificationsPage()));
            _viewModel.refreshUnreadCount();
          },
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_outlined, color: colors.text),
                if (_viewModel.unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        _viewModel.unreadCount > 9 ? '9+' : '${_viewModel.unreadCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
