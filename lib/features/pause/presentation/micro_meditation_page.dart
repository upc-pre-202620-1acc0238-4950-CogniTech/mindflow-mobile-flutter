import 'dart:async';

import 'package:flutter/material.dart';

/// W13 — Micro-meditation, 3 steps of 1 minute each. Entirely local.
class MicroMeditationPage extends StatefulWidget {
  const MicroMeditationPage({super.key});

  @override
  State<MicroMeditationPage> createState() => _MicroMeditationPageState();
}

class _Step {
  final String title;
  final String text;
  const _Step(this.title, this.text);
}

class _MicroMeditationPageState extends State<MicroMeditationPage> {
  static const _steps = [
    _Step('Settle in', 'Close your eyes and bring your attention to your breathing.'),
    _Step('Notice', 'Notice the sensations in your body, without judging them.'),
    _Step('Let go', 'If a thought appears, observe it and let it pass.'),
  ];

  int _step = 0;
  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startStepTimer();
  }

  void _startStepTimer() {
    _timer?.cancel();
    _secondsLeft = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 0) {
        if (_step < _steps.length - 1) _advance();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  void _advance() {
    setState(() => _step = (_step + 1) % _steps.length);
    _startStepTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeLabel => '0:${_secondsLeft.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Micro-meditation · 3 min',
                        style: TextStyle(fontSize: 14, color: Color(0xFF5A6070))),
                    Text(step.title,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.01)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(_steps.length, (i) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i == _steps.length - 1 ? 0 : 8),
                      height: 6,
                      decoration: BoxDecoration(
                        color: i <= _step ? const Color(0xFF2B6AD9) : const Color(0xFFB8C0CF),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_timeLabel,
                          style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Text(step.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20, height: 1.5)),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _step == _steps.length - 1
                    ? () => Navigator.of(context).pop()
                    : _advance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B6AD9),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_step == _steps.length - 1 ? 'Done' : 'Next step'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
