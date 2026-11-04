import 'dart:async';

import 'package:flutter/material.dart';

/// W8 — Breathing 4-7-8, ~2 minutes. Entirely local: no backend call.
class BreathingPausePage extends StatefulWidget {
  const BreathingPausePage({super.key});

  @override
  State<BreathingPausePage> createState() => _BreathingPausePageState();
}

class _BreathingPausePageState extends State<BreathingPausePage> {
  static const _phases = ['Breathe in', 'Hold', 'Breathe out'];
  static const _phaseSeconds = [4, 7, 8];
  static const _circleSize = [230.0, 230.0, 130.0];

  int _phase = 0;
  late int _remaining = 120;
  Timer? _overallTimer;
  Timer? _phaseTimer;
  int _secondsInPhase = 0;

  @override
  void initState() {
    super.initState();
    _overallTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 0) return;
      setState(() => _remaining--);
    });
    _startPhaseLoop();
  }

  void _startPhaseLoop() {
    _phaseTimer?.cancel();
    _secondsInPhase = 0;
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _secondsInPhase++;
      if (_secondsInPhase >= _phaseSeconds[_phase]) {
        setState(() => _phase = (_phase + 1) % _phases.length);
        _secondsInPhase = 0;
      }
    });
  }

  @override
  void dispose() {
    _overallTimer?.cancel();
    _phaseTimer?.cancel();
    super.dispose();
  }

  String get _timeLabel {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
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
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Breathing pause',
                          style: TextStyle(fontSize: 14, color: Color(0xFF5A6070))),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _phases[_phase],
                          key: ValueKey(_phase),
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.01),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeInOut,
                        width: _circleSize[_phase],
                        height: _circleSize[_phase],
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.fromBorderSide(
                              BorderSide(color: Color(0xFF2B6AD9), width: 2)),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_timeLabel,
                              style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w600)),
                          const Text('left',
                              style: TextStyle(fontSize: 14, color: Color(0xFF5A6070))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B6AD9),
                  minimumSize: const Size.fromHeight(52),
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_remaining <= 0 ? 'Done' : 'End early'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
