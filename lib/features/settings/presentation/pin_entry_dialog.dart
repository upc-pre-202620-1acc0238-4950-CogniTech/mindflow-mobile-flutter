import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Asks for a 4-digit PIN. Returns the PIN, or null if cancelled.
class PinEntryDialog extends StatefulWidget {
  final String title;
  final String? subtitle;

  const PinEntryDialog({super.key, required this.title, this.subtitle});

  static Future<String?> show(BuildContext context, {required String title, String? subtitle}) {
    return showDialog<String>(
      context: context,
      builder: (context) => PinEntryDialog(title: title, subtitle: subtitle),
    );
  }

  @override
  State<PinEntryDialog> createState() => _PinEntryDialogState();
}

class _PinEntryDialogState extends State<PinEntryDialog> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.subtitle != null) ...[
            Text(widget.subtitle!),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, letterSpacing: 8),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(counterText: ''),
            onSubmitted: (value) {
              if (value.length == 4) Navigator.of(context).pop(value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        TextButton(
          onPressed: _controller.text.length == 4
              ? () => Navigator.of(context).pop(_controller.text)
              : null,
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
