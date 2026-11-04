class CategoryCount {
  final String category;
  final int count;
  const CategoryCount({required this.category, required this.count});

  factory CategoryCount.fromJson(Map<String, dynamic> json) => CategoryCount(
        category: (json['category'] as String?) ?? '',
        count: (json['count'] as num?)?.toInt() ?? 0,
      );
}

/// Mirrors exactly what `GET /analytics/dashboard` returns: aggregate
/// counts for a date range. The backend does not compute a mood score,
/// a day-by-day trend, or word frequencies, so this model doesn't either.
class AnalyticsDashboard {
  final DateTime from;
  final DateTime to;
  final int journalEntries;
  final Map<String, int> sentiments;
  final List<CategoryCount> topCategories;
  final int habitCompletions;
  final int activeHabits;

  const AnalyticsDashboard({
    required this.from,
    required this.to,
    required this.journalEntries,
    required this.sentiments,
    required this.topCategories,
    required this.habitCompletions,
    required this.activeHabits,
  });

  factory AnalyticsDashboard.fromJson(Map<String, dynamic> json) => AnalyticsDashboard(
        from: DateTime.parse(json['from'] as String),
        to: DateTime.parse(json['to'] as String),
        journalEntries: (json['journal_entries'] as num?)?.toInt() ?? 0,
        sentiments: ((json['sentiments'] as Map<String, dynamic>?) ?? {})
            .map((key, value) => MapEntry(key, (value as num).toInt())),
        topCategories: ((json['top_categories'] as List?) ?? [])
            .map((e) => CategoryCount.fromJson(e as Map<String, dynamic>))
            .toList(),
        habitCompletions: (json['habit_completions'] as num?)?.toInt() ?? 0,
        activeHabits: (json['active_habits'] as num?)?.toInt() ?? 0,
      );

  int get positive => sentiments['positive'] ?? 0;
  int get neutral => sentiments['neutral'] ?? 0;
  int get negative => sentiments['negative'] ?? 0;
  int get total => positive + neutral + negative;
  double get positivityRate => total == 0 ? 0 : positive / total;
}
