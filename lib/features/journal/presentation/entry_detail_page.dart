import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../ai_feedback/presentation/ai_rating_stars.dart';
import '../../chat/presentation/chat_page.dart';
import '../../wellness/presentation/wellness_exercises_page.dart';
import '../domain/journal_entry.dart';
import 'entry_detail_view_model.dart';
import 'new_entry_view_model.dart';

class EntryDetailPage extends StatefulWidget {
  final int entryId;
  const EntryDetailPage({super.key, required this.entryId});

  @override
  State<EntryDetailPage> createState() => _EntryDetailPageState();
}

class _EntryDetailPageState extends State<EntryDetailPage> {
  late final EntryDetailViewModel _viewModel;
  bool _editing = false;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  int _editCategory = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<EntryDetailViewModel>();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _viewModel.load(widget.entryId).then((_) => _resetEditFields());
  }

  void _resetEditFields() {
    final entry = _viewModel.entry;
    if (entry == null) return;
    _titleController.text = entry.title;
    _contentController.text = entry.content;
    final idx = NewEntryViewModel.categories.indexOf(entry.category);
    _editCategory = idx >= 0 ? idx : 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar esta entrada?'),
        content: const Text('Esto no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      final ok = await _viewModel.delete();
      if (ok && mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).pop(_viewModel.isDeleted)),
        actions: [
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              if (_viewModel.entry == null) return const SizedBox.shrink();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(_editing ? Icons.close : Icons.edit_outlined),
                    onPressed: () => setState(() {
                      if (_editing) _resetEditFields();
                      _editing = !_editing;
                    }),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _viewModel.isSaving ? null : _confirmDelete,
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final entry = _viewModel.entry;
            if (entry == null) {
              return Center(
                  child: Text(_viewModel.errorMessage ?? 'No se encontró la entrada.',
                      style: TextStyle(color: colors.crisisText)));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE · HH:mm').format(entry.date),
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  if (_editing)
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: -0.01),
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                    )
                  else
                    Text(entry.title.isEmpty ? '(Sin título)' : entry.title,
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: -0.01)),
                  const SizedBox(height: 10),
                  if (_editing)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(NewEntryViewModel.categories.length, (i) {
                        final selected = i == _editCategory;
                        return ChoiceChip(
                          label: Text(NewEntryViewModel.categories[i]),
                          selected: selected,
                          onSelected: (_) => setState(() => _editCategory = i),
                        );
                      }),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      children: [
                        _Pill(text: entry.category),
                        _Pill(
                            text: entry.sentimentLabel,
                            dotColor: _sentimentColor(entry.sentiment, colors)),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (_editing)
                    TextField(
                      controller: _contentController,
                      minLines: 5,
                      maxLines: 12,
                      style: const TextStyle(fontSize: 17, height: 1.5),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    )
                  else
                    Text(entry.content, style: const TextStyle(fontSize: 17, height: 1.5)),
                  if (_editing) ...[
                    const SizedBox(height: 16),
                    if (_viewModel.errorMessage != null)
                      Text(_viewModel.errorMessage!, style: TextStyle(color: colors.crisisText)),
                    ElevatedButton(
                      onPressed: _viewModel.isSaving
                          ? null
                          : () async {
                              final ok = await _viewModel.save(
                                title: _titleController.text.trim(),
                                content: _contentController.text.trim(),
                                sentiment: entry.sentiment,
                                category: NewEntryViewModel.categories[_editCategory],
                              );
                              if (ok) setState(() => _editing = false);
                            },
                      child: _viewModel.isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Guardar cambios'),
                    ),
                  ],
                  if (!_editing && entry.aiResponse != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.tintBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MindFlow AI',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          Text(entry.aiResponse!, style: const TextStyle(fontSize: 16, height: 1.5)),
                          const SizedBox(height: 10),
                          AiRatingStars(
                            prompt: '¿Te fue útil esta respuesta?',
                            submittedRating: _viewModel.myAiRating,
                            isSubmitting: _viewModel.isSubmittingAiRating,
                            onRate: _viewModel.rateAiResponse,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => const ChatPage())),
                      child: const Text('Hablarlo'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const WellnessExercisesPage())),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: colors.text,
                        side: const BorderSide(color: Color(0xFFB8C0CF)),
                      ),
                      child: const Text('Iniciar una pausa guiada'),
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

  Color _sentimentColor(String sentiment, AppColors colors) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return colors.success;
      case 'negative':
        return colors.crisis;
      default:
        return colors.textSecondary;
    }
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color? dotColor;
  const _Pill({required this.text, this.dotColor});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: dotColor!, width: 2)),
            ),
            const SizedBox(width: 6),
          ],
          Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
