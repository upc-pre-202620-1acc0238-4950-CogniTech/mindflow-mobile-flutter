import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/journal_entry.dart';
import 'entry_detail_page.dart';
import 'journal_calendar_view.dart';
import 'journal_list_view_model.dart';
import 'new_entry_page.dart';

class JournalListPage extends StatefulWidget {
  const JournalListPage({super.key});

  @override
  State<JournalListPage> createState() => _JournalListPageState();
}

class _JournalListPageState extends State<JournalListPage> {
  late final JournalListViewModel _viewModel;
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<JournalListViewModel>();
  }

  Future<void> _openNewEntry() async {
    final saved = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => const NewEntryPage()));
    if (saved == true) _viewModel.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Diario',
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.01)),
                      IconButton.filled(
                        onPressed: _openNewEntry,
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: colors.primary,
                          minimumSize: const Size(48, 48),
                          shape:
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFB8C0CF)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TabButton(
                            label: 'Lista',
                            selected: !_showCalendar,
                            onTap: () => setState(() => _showCalendar = false),
                          ),
                        ),
                        Expanded(
                          child: _TabButton(
                            label: 'Calendario',
                            selected: _showCalendar,
                            onTap: () => setState(() => _showCalendar = true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_showCalendar) ...[
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: _viewModel.onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Busca en tus pensamientos',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _viewModel.categoryIndex,
                            isExpanded: true,
                            decoration: const InputDecoration(isDense: true),
                            items: List.generate(
                              JournalListViewModel.categories.length,
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text(JournalListViewModel.categories[i],
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            onChanged: (i) {
                              if (i != null) _viewModel.selectCategory(i);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _viewModel.sentimentIndex,
                            isExpanded: true,
                            decoration: const InputDecoration(isDense: true),
                            items: List.generate(
                              JournalListViewModel.sentiments.length,
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text(JournalListViewModel.sentiments[i],
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            onChanged: (i) {
                              if (i != null) _viewModel.selectSentiment(i);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Expanded(
                    child: _showCalendar
                        ? JournalCalendarView(entries: _viewModel.allEntries)
                        : _buildList(colors),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(AppColors colors) {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_viewModel.errorMessage != null) {
      return Center(child: Text(_viewModel.errorMessage!, style: TextStyle(color: colors.crisisText)));
    }
    final entries = _viewModel.filteredEntries;
    if (entries.isEmpty) {
      return Center(
          child: Text('Aún no hay entradas.', style: TextStyle(color: colors.textSecondary)));
    }
    return RefreshIndicator(
      onRefresh: _viewModel.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 110, top: 8),
        itemCount: entries.length,
        separatorBuilder: (_, index) => Divider(height: 1, color: colors.border),
        itemBuilder: (context, i) => _EntryRow(entry: entries[i], onChanged: _viewModel.refresh),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1B2333) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF1B2333))),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onChanged;
  const _EntryRow({required this.entry, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: () async {
        final changed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => EntryDetailPage(entryId: entry.id)));
        if (changed == true) onChanged();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 52,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_dayLabel(entry.date),
                      style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                  Text(DateFormat('HH:mm').format(entry.date),
                      style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title.isEmpty ? '(Sin título)' : entry.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(
                    entry.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text('${entry.category} · ${entry.sentimentLabel}',
                      style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    if (DateUtils.isSameDay(date, now)) return 'Hoy';
    return DateFormat('EEE d').format(date);
  }
}
