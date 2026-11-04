class Habit {
  final int id;
  final String name;
  final String category;
  final String frequency;
  final int streak;
  final String status;
  final bool pausedByAi;

  const Habit({
    required this.id,
    required this.name,
    required this.category,
    required this.frequency,
    required this.streak,
    required this.status,
    required this.pausedByAi,
  });

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as int,
        name: json['name'] as String,
        category: (json['category'] as String?) ?? '',
        frequency: (json['frequency'] as String?) ?? '',
        streak: (json['streak'] as num?)?.toInt() ?? 0,
        status: (json['status'] as String?) ?? 'active',
        pausedByAi: json['paused_by_ai'] as bool? ?? false,
      );
}
