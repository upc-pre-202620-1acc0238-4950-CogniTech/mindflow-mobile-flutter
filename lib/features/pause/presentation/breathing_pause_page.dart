import 'dart:async';
import 'dart:math' as math;

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
  final Color color;
  const _Phase(this.label, this.seconds, this.circleSize, this.color);
}

class _BreathingPausePageState extends State<BreathingPausePage>
    with SingleTickerProviderStateMixin {
  static const _inhaleColor = Color(0xFF2B6AD9);
  static const _holdColor = Color(0xFF7B5DE0);
  static const _exhaleColor = Color(0xFF2FAE8C);

  late final List<_Phase> _phases = [
    if ((widget.exercise.inhaleSeconds ?? 0) > 0)
      _Phase('Inhala', widget.exercise.inhaleSeconds!, 230, _inhaleColor),
    if ((widget.exercise.holdSeconds ?? 0) > 0)
      _Phase('Mantén', widget.exercise.holdSeconds!, 230, _holdColor),
    if ((widget.exercise.exhaleSeconds ?? 0) > 0)
      _Phase('Exhala', widget.exercise.exhaleSeconds!, 130, _exhaleColor),
    if ((widget.exercise.holdAfterExhaleSeconds ?? 0) > 0)
      _Phase('Mantén', widget.exercise.holdAfterExhaleSeconds!, 130, _holdColor),
  ];

  int _phase = 0;
  int _cycle = 1;
  late int _remaining = widget.exercise.durationSeconds;
  Timer? _overallTimer;
  Timer? _phaseTimer;
  int _secondsInPhase = 0;
  bool _done = false;

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

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
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _overallTimer?.cancel();
    _phaseTimer?.cancel();
    _pulseController.dispose();
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
    final phaseColor = phase?.color ?? _inhaleColor;
    final phaseProgress =
        phase == null ? 0.0 : (_secondsInPhase / phase.seconds).clamp(0.0, 1.0);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 900),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.4,
            colors: [
              phaseColor.withValues(alpha: 0.16),
              const Color(0xFFEEF4FE),
            ],
          ),
        ),
        child: SafeArea(
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
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            _done ? 'Bien hecho' : (phase?.label ?? widget.exercise.name),
                            key: ValueKey('$_phase-$_cycle-$_done'),
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.01,
                                color: _done ? const Color(0xFF1B2333) : phaseColor),
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
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final ambient =
                                1 + (math.sin(_pulseController.value * math.pi) * 0.02);
                            return Transform.scale(scale: _done ? 1 : ambient, child: child);
                          },
                          child: SizedBox(
                            width: 266,
                            height: 266,
                            child: CircularProgressIndicator(
                              value: _done ? 1 : phaseProgress,
                              strokeWidth: 5,
                              backgroundColor: phaseColor.withValues(alpha: 0.12),
                              valueColor: AlwaysStoppedAnimation(phaseColor),
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: Duration(seconds: phase?.seconds ?? 1),
                          curve: Curves.easeInOut,
                          width: phase?.circleSize ?? 180,
                          height: phase?.circleSize ?? 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white,
                                phaseColor.withValues(alpha: 0.18),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: phaseColor.withValues(alpha: 0.35),
                                blurRadius: 30,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_timeLabel,
                                style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w600)),
                            if (_totalCycles > 1)
                              Text('ciclo $_cycle de $_totalCycles',
                                  style: const TextStyle(fontSize: 14, color: Color(0xFF5A6070)))
                            else
                              const Text('restante', style: TextStyle(fontSize: 14, color: Color(0xFF5A6070))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: phaseColor,
                    minimumSize: const Size.fromHeight(52),
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_done ? 'Listo' : 'Terminar antes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
