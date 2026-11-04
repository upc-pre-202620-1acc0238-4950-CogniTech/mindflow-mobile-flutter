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

class _MicroMeditationPageState extends State<MicroMeditationPage> {
  late int _secondsLeft = widget.exercise.durationSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 0) return;
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
                    Text('Meditation · ${widget.exercise.durationLabel}',
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
                      Text(done ? 'Done' : _timeLabel,
                          style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Text(widget.exercise.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20, height: 1.5)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(done ? 'Done' : 'End early'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
