class WellnessExercise {
  static const typeBreathing = 'breathing';
  static const typeMeditation = 'meditation';

  final int id;
  final String type;
  final String name;
  final String description;
  final int durationSeconds;
  final int? inhaleSeconds;
  final int? holdSeconds;
  final int? exhaleSeconds;
  final int? holdAfterExhaleSeconds;
  final int? cycles;

  const WellnessExercise({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.durationSeconds,
    this.inhaleSeconds,
    this.holdSeconds,
    this.exhaleSeconds,
    this.holdAfterExhaleSeconds,
    this.cycles,
  });

  bool get isBreathing => type == typeBreathing;

  factory WellnessExercise.fromJson(Map<String, dynamic> json) => WellnessExercise(
        id: json['id'] as int,
        type: (json['type'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
        durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 60,
        inhaleSeconds: (json['inhale_seconds'] as num?)?.toInt(),
        holdSeconds: (json['hold_seconds'] as num?)?.toInt(),
        exhaleSeconds: (json['exhale_seconds'] as num?)?.toInt(),
        holdAfterExhaleSeconds: (json['hold_after_exhale_seconds'] as num?)?.toInt(),
        cycles: (json['cycles'] as num?)?.toInt(),
      );

  String get durationLabel {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    if (m == 0) return '$s sec';
    if (s == 0) return '$m min';
    return '$m min $s sec';
  }
}
