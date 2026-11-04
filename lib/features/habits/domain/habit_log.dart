class HabitLog {
  final int id;
  final int habitId;
  final String habitName;
  final String category;
  final DateTime date;
  final bool completed;
  final DateTime? completedAt;

  const HabitLog({
    required this.id,
    required this.habitId,
    required this.habitName,
    required this.category,
    required this.date,
    required this.completed,
    this.completedAt,
  });

  factory HabitLog.fromJson(Map<String, dynamic> json) => HabitLog(
        id: json['id'] as int,
        habitId: json['habit_id'] as int,
        habitName: (json['habit_name'] as String?) ?? '',
        category: (json['category'] as String?) ?? '',
        date: DateTime.parse(json['date'] as String),
        completed: json['completed'] as bool? ?? false,
        completedAt:
            json['completed_at'] == null ? null : DateTime.parse(json['completed_at'] as String),
      );
}
