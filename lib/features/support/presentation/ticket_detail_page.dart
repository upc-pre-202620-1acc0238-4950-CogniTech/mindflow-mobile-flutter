import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import 'ticket_detail_view_model.dart';

class TicketDetailPage extends StatefulWidget {
  final int ticketId;
  const TicketDetailPage({super.key, required this.ticketId});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  late final TicketDetailViewModel _viewModel;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<TicketDetailViewModel>();
    _viewModel.load(widget.ticketId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Ticket')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final ticket = _viewModel.ticket;
            if (ticket == null) {
              return Center(
                  child: Text(_viewModel.errorMessage ?? 'Not found.',
                      style: TextStyle(color: colors.crisisText)));
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(ticket.subject,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.tintBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(ticket.status,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      for (final m in ticket.messages)
                        Align(
                          alignment: m.isStaff ? Alignment.centerLeft : Alignment.centerRight,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 280),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: m.isStaff ? colors.tintBlue : colors.text,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m.isStaff ? 'Support' : 'You',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: m.isStaff ? colors.textSecondary : Colors.white70)),
                                  const SizedBox(height: 2),
                                  Text(m.body,
                                      style: TextStyle(
                                          fontSize: 15, color: m.isStaff ? colors.text : Colors.white)),
                                  if (m.createdAt != null) ...[
                                    const SizedBox(height: 4),
                                    Text(DateFormat('d MMM · HH:mm').format(m.createdAt!),
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: m.isStaff ? colors.textSecondary : Colors.white60)),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(_viewModel.errorMessage!, style: TextStyle(color: colors.crisisText)),
                  ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.border))),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(hintText: 'Write a reply'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        onPressed: _viewModel.isSending
                            ? null
                            : () async {
                                final text = _controller.text;
                                _controller.clear();
                                await _viewModel.reply(text);
                              },
                        icon: _viewModel.isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.arrow_forward),
                        style: IconButton.styleFrom(backgroundColor: colors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
