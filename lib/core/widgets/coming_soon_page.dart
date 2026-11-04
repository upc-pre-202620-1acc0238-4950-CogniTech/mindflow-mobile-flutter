import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shown for tabs/flows not built yet in this feature branch. Honest
/// placeholder for in-progress screens — never used in place of real
/// content once a feature branch ships it.
class ComingSoonPage extends StatelessWidget {
  final String title;
  const ComingSoonPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction_outlined, size: 40, color: colors.textSecondary),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('Coming in a following feature branch.',
                  style: TextStyle(color: colors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
