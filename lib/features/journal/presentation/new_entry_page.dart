import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import 'new_entry_view_model.dart';

class NewEntryPage extends StatefulWidget {
  const NewEntryPage({super.key});

  @override
  State<NewEntryPage> createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  final _controller = TextEditingController();
  late final NewEntryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<NewEntryViewModel>();
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('New entry'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How are you feeling right now?',
                      style: TextStyle(fontSize: 15, color: colors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    minLines: 6,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText: 'Write here. This is a private, encrypted space.',
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(NewEntryViewModel.categories.length, (i) {
                      final selected = i == _viewModel.selectedCategory;
                      return ChoiceChip(
                        label: Text(NewEntryViewModel.categories[i]),
                        selected: selected,
                        onSelected: (_) => _viewModel.selectCategory(i),
                        selectedColor: colors.text,
                        labelStyle: TextStyle(color: selected ? Colors.white : colors.text),
                        backgroundColor: colors.surface,
                        side: BorderSide(color: selected ? colors.text : const Color(0xFFB8C0CF)),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),
                  if (_viewModel.errorMessage != null) ...[
                    Text(_viewModel.errorMessage!, style: TextStyle(color: colors.crisisText)),
                    const SizedBox(height: 8),
                  ],
                  ElevatedButton(
                    onPressed:
                        _viewModel.isLoading ? null : () => _viewModel.save(_controller.text),
                    child: _viewModel.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Save entry'),
                  ),
                  if (_viewModel.savedEntry != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.tintBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MindFlow AI · sentiment: ${_viewModel.savedEntry!.sentiment}',
                            style: TextStyle(
                                fontSize: 13, color: colors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _viewModel.savedEntry!.aiResponse ??
                                'Thanks for writing. Take a moment for yourself.',
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text('Chat is coming in the next update.')));
                                  },
                                  child: const Text('Talk about it'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 46),
                                  foregroundColor: colors.text,
                                  side: const BorderSide(color: Color(0xFFB8C0CF)),
                                ),
                                child: const Text('Done'),
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
