import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../support/presentation/crisis_support_sheet.dart';
import '../domain/chat_message.dart';
import 'chat_view_model.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatViewModel _viewModel;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ChatViewModel>();
    _viewModel.addListener(_scrollToBottom);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_scrollToBottom);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text;
    _controller.clear();
    await _viewModel.send(text);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MindFlow AI', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            Text('Privado para ti', style: TextStyle(fontSize: 13, color: Color(0xFF5A6070))),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton(
              onPressed: () => CrisisSupportSheet.show(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.crisisText,
                side: BorderSide(color: colors.crisis),
                minimumSize: const Size(0, 40),
              ),
              child: const Text('Soporte'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return Column(
              children: [
                Expanded(
                  child: _viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _viewModel.messages.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Escribe lo que tienes en mente. MindFlow AI responde con apoyo.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: colors.textSecondary),
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                              itemCount: _viewModel.messages.length,
                              itemBuilder: (context, i) => _MessageBubble(message: _viewModel.messages[i]),
                            ),
                ),
                if (_viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(_viewModel.errorMessage!, style: TextStyle(color: colors.crisisText)),
                  ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    'MindFlow AI es un apoyo para tu bienestar, no un reemplazo del cuidado profesional.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF5A6070)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.border))),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(hintText: 'Escribe un mensaje'),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        onPressed: _viewModel.isSending ? null : _send,
                        icon: _viewModel.isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.arrow_forward),
                        style: IconButton.styleFrom(
                          backgroundColor: colors.primary,
                          minimumSize: const Size(48, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
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

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isUser)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2, left: 2),
                  child: Text('MindFlow', style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isUser ? colors.userBubble : colors.aiBubble,
                  border: isUser ? null : Border.all(color: colors.aiBubbleBorder),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    topRight: const Radius.circular(14),
                    bottomLeft: Radius.circular(isUser ? 14 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 14),
                  ),
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: isUser ? colors.userBubbleText : colors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
