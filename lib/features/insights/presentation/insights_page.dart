import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import 'insights_view_model.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  late final InsightsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<InsightsViewModel>();
  }

  Future<void> _export({required bool pdf}) async {
    final path = await _viewModel.export(pdf: pdf);
    if (path != null && mounted) {
      await SharePlus.instance.share(ShareParams(files: [XFile(path)], text: 'Reporte de MindFlow'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final dashboard = _viewModel.dashboard;

            return RefreshIndicator(
              onRefresh: _viewModel.refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
                children: [
                  const Text('Análisis',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.01)),
                  const SizedBox(height: 12),
                  if (_viewModel.isLoading && dashboard == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    Row(
                      children: [
                        _StatCard(label: 'Entradas', value: '${dashboard?.journalEntries ?? 0}'),
                        const SizedBox(width: 8),
                        _StatCard(label: 'Hábitos activos', value: '${dashboard?.activeHabits ?? 0}'),
                        const SizedBox(width: 8),
                        _StatCard(label: 'Mejor racha', value: '${_viewModel.bestStreak} d'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFB8C0CF)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: List.generate(InsightsViewModel.ranges.length, (i) {
                          final selected = i == _viewModel.rangeIndex;
                          return Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(9),
                              onTap: () => _viewModel.selectRange(i),
                              child: Container(
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: selected ? const Color(0xFF1B2333) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text(
                                  InsightsViewModel.ranges[i],
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: selected ? Colors.white : const Color(0xFF1B2333)),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    if (dashboard != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.border),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Positividad general',
                                style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                            Text('${(dashboard.positivityRate * 100).round()}%',
                                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 10),
                            if (dashboard.total > 0)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Row(
                                  children: [
                                    if (dashboard.positive > 0)
                                      Expanded(
                                          flex: dashboard.positive,
                                          child: Container(height: 8, color: colors.success)),
                                    if (dashboard.neutral > 0)
                                      Expanded(
                                          flex: dashboard.neutral,
                                          child: Container(height: 8, color: colors.textSecondary)),
                                    if (dashboard.negative > 0)
                                      Expanded(
                                          flex: dashboard.negative,
                                          child: Container(height: 8, color: colors.crisis)),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 14,
                              children: [
                                _Legend(color: colors.success, label: 'Positivo (${dashboard.positive})'),
                                _Legend(color: colors.textSecondary, label: 'Neutral (${dashboard.neutral})'),
                                _Legend(color: colors.crisis, label: 'Negativo (${dashboard.negative})'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (dashboard.topCategories.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Text('Categorías principales',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        for (final c in dashboard.topCategories)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(c.category, style: const TextStyle(fontSize: 15)),
                                Text('${c.count}', style: TextStyle(color: colors.textSecondary)),
                              ],
                            ),
                          ),
                      ],
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Hábitos completados', style: TextStyle(fontSize: 15)),
                            Text('${dashboard.habitCompletions}', style: TextStyle(color: colors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.border))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Exporta tus datos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Comparte un reporte estructurado con tu psicólogo.',
                              style: TextStyle(fontSize: 14, color: colors.textSecondary)),
                          const SizedBox(height: 10),
                          if (_viewModel.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(_viewModel.errorMessage!, style: TextStyle(color: colors.crisisText)),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _viewModel.isExporting ? null : () => _export(pdf: true),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 48),
                                    foregroundColor: colors.text,
                                    side: const BorderSide(color: Color(0xFFB8C0CF)),
                                  ),
                                  child: const Text('Exportar PDF'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _viewModel.isExporting ? null : () => _export(pdf: false),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 48),
                                    foregroundColor: colors.text,
                                    side: const BorderSide(color: Color(0xFFB8C0CF)),
                                  ),
                                  child: const Text('Exportar CSV'),
                                ),
                              ),
                            ],
                          ),
                        ],
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
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
      ],
    );
  }
}
