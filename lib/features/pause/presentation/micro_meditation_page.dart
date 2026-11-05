import 'dart:async';

import 'package:flutter/material.dart';

import '../../wellness/domain/wellness_exercise.dart';

/// Meditation pause (W13), driven by a real [WellnessExercise] (type
/// "meditation"). The backend only gives a name, description and total
/// duration — no step-by-step script — so this is a single continuous
/// countdown with the exercise's own description as guidance, rather
/// than inventing a 3-step structure the data doesn't have.
class MicroMeditationPage extends StatefulWidget {
  final WellnessExercise exercise;
  const MicroMeditationPage({super.key, required this.exercise});

  @override
  State<MicroMeditationPage> createState() => _MicroMeditationPageState();
}

class _MicroMeditationPageState extends State<MicroMeditationPage>
    with SingleTickerProviderStateMixin {
  static const _tint = Color(0xFF7B5DE0);

  late final int _totalSeconds = widget.exercise.durationSeconds;
  late int _secondsLeft = widget.exercise.durationSeconds;
  Timer? _timer;

  late final AnimationController _breathController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 0) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) _breathController.stop();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  String get _timeLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final done = _secondsLeft <= 0;
    final progress =
        _totalSeconds == 0 ? 1.0 : (1 - (_secondsLeft / _totalSeconds)).clamp(0.0, 1.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.4,
            colors: [Color(0x1A7B5DE0), Color(0xFFEEF4FE)],
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Meditación · ${widget.exercise.durationLabel}',
                          style: const TextStyle(fontSize: 14, color: Color(0xFF5A6070))),
                      Text(widget.exercise.name,
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.01)),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 220,
                              height: 220,
                              child: CircularProgressIndicator(
                                value: done ? 1 : progress,
                                strokeWidth: 5,
                                backgroundColor: _tint.withValues(alpha: 0.12),
                                valueColor: const AlwaysStoppedAnimation(_tint),
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _breathController,
                              builder: (context, child) {
                                final scale = done
                                    ? 1.0
                                    : 0.88 + (_breathController.value * 0.14);
                                return Transform.scale(scale: scale, child: child);
                              },
                              child: Container(
                                width: 170,
                                height: 170,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [Colors.white, _tint.withValues(alpha: 0.2)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _tint.withValues(alpha: 0.3),
                                      blurRadius: 28,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(done ? 'Listo' : _timeLabel,
                                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Text(widget.exercise.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18, height: 1.5)),
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tint,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(done ? 'Listo' : 'Terminar antes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
