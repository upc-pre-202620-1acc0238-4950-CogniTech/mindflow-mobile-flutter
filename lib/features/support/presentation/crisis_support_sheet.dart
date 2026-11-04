import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// The crisis-line sheet reachable from Chat's "Support" button. Línea 113
/// (option 5, Minsa) is the only verified crisis line for this app — see
/// the design handoff's content rules.
class CrisisSupportSheet extends StatelessWidget {
  const CrisisSupportSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CrisisSupportSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Talk to someone now',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          const Text(
            'If you feel unsafe or think you may hurt yourself, please reach out to a person. '
            'In Peru, Línea 113, option 5, offers free psychological support, 24 hours a day.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => launchUrl(Uri.parse('tel:113')),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const Text('Call 113'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to chat'),
          ),
        ],
      ),
    );
  }
}
