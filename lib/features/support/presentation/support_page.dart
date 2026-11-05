import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/support_ticket.dart';
import 'support_view_model.dart';
import 'ticket_detail_page.dart';

/// Support and FAQ (W23). The mock's new-ticket form is a single textarea
/// with no subject field, but the backend requires `subject` — so the
/// subject is derived from the first part of the description, the same
/// way Chat derives a conversation title from the first message.
class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  late final SupportViewModel _viewModel;
  final _controller = TextEditingController();
  int? _openFaq;

  static const _faq = [
    ('¿Mis entradas son privadas?',
        'Sí. Tus entradas se guardan encriptadas y solo tú puedes verlas.'),
    ('¿Cómo funciona MindFlow AI?',
        'Lee el tono de lo que escribes para dar una respuesta empática y sugerencias de bienestar.'),
    ('¿Por qué se pausaron mis hábitos?',
        'Cuando la IA detecta estrés alto, pausa tareas demandantes para que priorices el descanso.'),
    ('¿Qué incluye Premium?',
        'Por ahora, Freemium y Premium desbloquean las mismas funciones — Premium es lo que mantiene '
            'financiado el proyecto a medida que se lancen más funciones exclusivas.'),
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<SupportViewModel>();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final ok = await _viewModel.sendTicket(_controller.text);
    if (ok) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Soporte')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return RefreshIndicator(
              onRefresh: _viewModel.refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? colors.crisisSurface
                          : const Color(0xFFFBF3F2),
                      border: Border.all(color: const Color(0xFFE6C3C1)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('¿Necesitas hablar con alguien ahora?',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600, color: colors.crisisText)),
                        const SizedBox(height: 6),
                        const Text(
                            'En Perú, la Línea 113, opción 5, ofrece apoyo psicológico gratuito las 24 horas.',
                            style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => launchUrl(Uri.parse('tel:113')),
                          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                          child: const Text('Llamar al 113'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Enviar un ticket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    minLines: 4,
                    maxLines: 8,
                    decoration: const InputDecoration(hintText: 'Describe el problema que tienes'),
                  ),
                  const SizedBox(height: 10),
                  if (_viewModel.errorMessage != null) ...[
                    Text(_viewModel.errorMessage!, style: TextStyle(color: colors.crisisText)),
                    const SizedBox(height: 8),
                  ],
                  ElevatedButton(
                    onPressed: _viewModel.isSending ? null : _send,
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    child: _viewModel.isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Enviar ticket'),
                  ),
                  if (_viewModel.lastCreated != null)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(12),
                      decoration:
                          BoxDecoration(color: colors.tintGreen, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                          'Ticket #${_viewModel.lastCreated!.id} enviado. Te contactaremos por correo.',
                          style: const TextStyle(fontSize: 15)),
                    ),
                  if (_viewModel.tickets.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Text('Mis tickets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    for (final t in _viewModel.tickets) _TicketRow(ticket: t),
                  ],
                  const SizedBox(height: 22),
                  const Text('Preguntas frecuentes',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  for (var i = 0; i < _faq.length; i++)
                    _FaqRow(
                      question: _faq[i].$1,
                      answer: _faq[i].$2,
                      open: _openFaq == i,
                      onTap: () => setState(() => _openFaq = _openFaq == i ? null : i),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  final SupportTicket ticket;
  const _TicketRow({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => TicketDetailPage(ticketId: ticket.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: colors.border), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ticket.subject, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  Text('${ticket.messages.length} mensaje(s)',
                      style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                ],
              ),
            ),
            Text(ticket.statusLabel, style: TextStyle(fontSize: 13, color: colors.primary)),
          ],
        ),
      ),
    );
  }
}

class _FaqRow extends StatelessWidget {
  final String question;
  final String answer;
  final bool open;
  final VoidCallback onTap;

  const _FaqRow({required this.question, required this.answer, required this.open, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.border))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(question,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                  Text(open ? '−' : '+', style: TextStyle(fontSize: 20, color: colors.textSecondary)),
                ],
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(answer, style: TextStyle(fontSize: 15, color: colors.textSecondary)),
            ),
        ],
      ),
    );
  }
}
