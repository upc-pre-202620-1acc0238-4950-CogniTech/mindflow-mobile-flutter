import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/journal_entry.dart';
import 'entry_detail_page.dart';

class JournalCalendarView extends StatefulWidget {
  final List<JournalEntry> entries;
  const JournalCalendarView({super.key, required this.entries});

  @override
  State<JournalCalendarView> createState() => _JournalCalendarViewState();
}

class _JournalCalendarViewState extends State<JournalCalendarView> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime _selectedDay = DateTime.now();

  Map<DateTime, List<JournalEntry>> get _byDay {
    final map = <DateTime, List<JournalEntry>>{};
    for (final e in widget.entries) {
      final key = DateTime(e.date.year, e.date.month, e.date.day);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final byDay = _byDay;
    final firstOfMonth = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leadingOffset = (firstOfMonth.weekday - DateTime.monday) % 7;
    final dayEntries = byDay[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)] ?? [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMMM yyyy').format(_month),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            Row(
              children: [
                IconButton(
                    onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left)),
                IconButton(
                    onPressed: () => _changeMonth(1), icon: const Icon(Icons.chevron_right)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map((d) => Center(
                  child: Text(d,
                      style: TextStyle(fontSize: 13, color: colors.textSecondary))))
              .toList(),
        ),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 0.85,
          children: [
            for (var i = 0; i < leadingOffset; i++) const SizedBox.shrink(),
            for (var day = 1; day <= daysInMonth; day++)
              _DayCell(
                date: DateTime(_month.year, _month.month, day),
                entries: byDay[DateTime(_month.year, _month.month, day)] ?? [],
                selected: DateUtils.isSameDay(_selectedDay, DateTime(_month.year, _month.month, day)),
                onTap: () => setState(() => _selectedDay = DateTime(_month.year, _month.month, day)),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _Legend(color: colors.success, label: 'Positivo'),
            const SizedBox(width: 16),
            _Legend(color: colors.textSecondary, label: 'Neutral', ring: true),
            const SizedBox(width: 16),
            _Legend(color: colors.crisis, label: 'Negativo', square: true),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.border))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('MMMM d').format(_selectedDay),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              if (dayEntries.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('No hay entradas este día.',
                      style: TextStyle(fontSize: 14, color: colors.textSecondary)),
                )
              else
                for (final entry in dayEntries)
                  InkWell(
                    onTap: () async {
                      await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => EntryDetailPage(entryId: entry.id)));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.title.isEmpty ? '(Sin título)' : entry.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          Text('${entry.category} · ${entry.sentimentLabel}',
                              style: TextStyle(fontSize: 14, color: colors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final List<JournalEntry> entries;
  final bool selected;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.entries,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sentiment = entries.isEmpty ? null : entries.first.sentiment.toLowerCase();

    Color bg = colors.background;
    Color mark = Colors.transparent;
    BoxShape shape = BoxShape.circle;
    if (sentiment == 'positive') {
      bg = colors.tintGreen;
      mark = colors.success;
    } else if (sentiment == 'neutral') {
      bg = colors.border.withValues(alpha: 0.3);
      mark = colors.textSecondary;
    } else if (sentiment == 'negative') {
      bg = colors.crisisSurface;
      mark = colors.crisis;
      shape = BoxShape.rectangle;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? colors.text : colors.border, width: selected ? 2 : 1),
          color: bg,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${date.day}',
                style: TextStyle(
                    fontSize: 14, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
            const SizedBox(height: 2),
            if (sentiment != null)
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(shape: shape, color: mark),
              ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final bool ring;
  final bool square;
  const _Legend({required this.color, required this.label, this.ring = false, this.square = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: square ? BoxShape.rectangle : BoxShape.circle,
            color: ring ? Colors.transparent : color,
            border: ring ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
      ],
    );
  }
}
