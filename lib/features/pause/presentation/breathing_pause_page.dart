import 'dart:async';

import 'package:flutter/material.dart';

import '../../wellness/domain/wellness_exercise.dart';

/// Breathing pause (W8), driven by a real [WellnessExercise] (type
/// "breathing") from `GET /wellness/exercises` — inhale/hold/exhale/
/// hold-after-exhale timings and cycle count come from the backend, not
/// a hardcoded 4-7-8.
class BreathingPausePage extends StatefulWidget {
  final WellnessExercise exercise;
  const BreathingPausePage({super.key, required this.exercise});

  @override
  State<BreathingPausePage> createState() => _BreathingPausePageState();
}

class _Phase {
  final String label;
  final int seconds;
  final double circleSize;
  const _Phase(this.label, this.seconds, this.circleSize);
}

class _BreathingPausePageState extends State<BreathingPausePage> {
  late final List<_Phase> _phases = [
    if ((widget.exercise.inhaleSeconds ?? 0) > 0)
      _Phase('Breathe in', widget.exercise.inhaleSeconds!, 230),
    if ((widget.exercise.holdSeconds ?? 0) > 0) _Phase('Hold', widget.exercise.holdSeconds!, 230),
    if ((widget.exercise.exhaleSeconds ?? 0) > 0)
      _Phase('Breathe out', widget.exercise.exhaleSeconds!, 130),
    if ((widget.exercise.holdAfterExhaleSeconds ?? 0) > 0)
      _Phase('Hold', widget.exercise.holdAfterExhaleSeconds!, 130),
  ];

  int _phase = 0;
  int _cycle = 1;
  late int _remaining = widget.exercise.durationSeconds;
  Timer? _overallTimer;
  Timer? _phaseTimer;
  int _secondsInPhase = 0;
  bool _done = false;

  int get _totalCycles => widget.exercise.cycles ?? 1;

  @override
  void initState() {
    super.initState();
    _overallTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 0) return;
      setState(() => _remaining--);
    });
    if (_phases.isNotEmpty) _startPhaseLoop();
  }

  void _startPhaseLoop() {
    _phaseTimer?.cancel();
    _secondsInPhase = 0;
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _secondsInPhase++;
      if (_secondsInPhase >= _phases[_phase].seconds) {
        _secondsInPhase = 0;
        if (_phase < _phases.length - 1) {
          setState(() => _phase++);
        } else if (_cycle < _totalCycles) {
          setState(() {
            _phase = 0;
            _cycle++;
          });
        } else {
          _phaseTimer?.cancel();
          setState(() => _done = true);
        }
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
    final phase = _phases.isEmpty ? null : _phases[_phase];

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
                      Text(widget.exercise.name,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF5A6070))),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _done ? 'Well done' : (phase?.label ?? widget.exercise.name),
                          key: ValueKey('$_phase-$_cycle-$_done'),
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
                        width: phase?.circleSize ?? 180,
                        height: phase?.circleSize ?? 180,
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
                          if (_totalCycles > 1)
                            Text('cycle $_cycle of $_totalCycles',
                                style: const TextStyle(fontSize: 14, color: Color(0xFF5A6070)))
                          else
                            const Text('left', style: TextStyle(fontSize: 14, color: Color(0xFF5A6070))),
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
                child: Text(_done ? 'Done' : 'End early'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
