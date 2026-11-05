import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import 'plans_view_model.dart';

/// Plans (W21). The real backend does not gate any feature by plan today
/// (not even the PDF/CSV export the mock calls "Premium") — so this
/// screen lists what is real (both plans currently unlock the same
/// features; the price is the only live difference) instead of the
/// mock's invented Premium-only perks (advanced charts, streak freeze,
/// priority support).
class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  late final PlansViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<PlansViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Planes')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final isPremium = _viewModel.current?.isPremium ?? false;

            return RefreshIndicator(
              onRefresh: _viewModel.refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Text('Invierte en tu bienestar. Elige el plan que se ajuste a tu ritmo.',
                      style: TextStyle(fontSize: 16, color: colors.textSecondary)),
                  const SizedBox(height: 16),
                  if (_viewModel.errorMessage != null) ...[
                    Text(_viewModel.errorMessage!, style: TextStyle(color: colors.crisisText)),
                    const SizedBox(height: 10),
                  ],
                  _PlanCard(
                    title: 'Freemium',
                    priceLabel: 'Gratis',
                    current: !isPremium,
                    highlighted: false,
                    features: const [
                      'Diario interactivo con respuestas de IA',
                      'Hábitos que se adaptan al estrés',
                      'Guías de respiración y meditación',
                      'Análisis: entradas, estado de ánimo, categorías',
                      'Exportación en PDF y CSV',
                    ],
                  ),
                  const SizedBox(height: 14),
                  _PlanCard(
                    title: 'Premium',
                    priceLabel: _premiumPriceLabel(),
                    current: isPremium,
                    highlighted: true,
                    features: const [
                      'Todo lo de Freemium',
                      'Apoya el desarrollo del proyecto',
                    ],
                    action: isPremium
                        ? null
                        : ElevatedButton(
                            onPressed: _viewModel.isStartingCheckout ? null : _viewModel.upgrade,
                            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                            child: _viewModel.isStartingCheckout
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Mejorar a Premium'),
                          ),
                    note: isPremium
                        ? null
                        : 'Stripe se abre en modo de prueba. No se realiza ningún cargo real.',
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Los pagos son procesados por Stripe. Por ahora, Freemium y Premium desbloquean '
                    'las mismas funciones en la app — Premium es el plan que mantiene financiado el '
                    'proyecto a medida que se lancen más funciones exclusivas.',
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _premiumPriceLabel() {
    final premium = _viewModel.plans.where((p) => p.isPremium).toList();
    if (premium.isEmpty) return '\$4.99 / mes';
    final p = premium.first;
    return '\$${p.price.toStringAsFixed(2)} / ${p.interval ?? "mes"}';
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String priceLabel;
  final bool current;
  final bool highlighted;
  final List<String> features;
  final Widget? action;
  final String? note;

  const _PlanCard({
    required this.title,
    required this.priceLabel,
    required this.current,
    required this.highlighted,
    required this.features,
    this.action,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: highlighted ? colors.primary : colors.border, width: highlighted ? 2 : 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: current ? colors.border.withValues(alpha: 0.3) : colors.tintBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  current ? 'Tu plan' : (highlighted ? 'Recomendado' : ''),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: current ? colors.text : colors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(priceLabel, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          for (final f in features)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check, size: 18, color: colors.success),
                  const SizedBox(width: 8),
                  Expanded(child: Text(f, style: const TextStyle(fontSize: 15))),
                ],
              ),
            ),
          if (action != null) ...[
            const SizedBox(height: 8),
            action!,
          ],
          if (note != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: colors.warningSurface, borderRadius: BorderRadius.circular(10)),
              child: Text(note!, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ],
      ),
    );
  }
}
