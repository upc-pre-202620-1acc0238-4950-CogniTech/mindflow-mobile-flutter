class HabitSuggestion {
  final String name;
  final String category;
  final String frequency;
  final String reason;

  const HabitSuggestion({
    required this.name,
    required this.category,
    required this.frequency,
    required this.reason,
  });

  factory HabitSuggestion.fromJson(Map<String, dynamic> json) => HabitSuggestion(
        name: (json['name'] as String?) ?? '',
        category: (json['category'] as String?) ?? '',
        frequency: (json['frequency'] as String?) ?? 'Daily',
        reason: (json['reason'] as String?) ?? '',
      );
}
