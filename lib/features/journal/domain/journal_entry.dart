class JournalEntry {
  final int id;
  final DateTime date;
  final String title;
  final String content;
  final String sentiment;
  final String category;
  final String? aiResponse;

  const JournalEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    required this.sentiment,
    required this.category,
    this.aiResponse,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as int,
        date: DateTime.parse(json['date'] as String),
        title: (json['title'] as String?) ?? '',
        content: (json['content'] as String?) ?? '',
        sentiment: (json['sentiment'] as String?) ?? 'neutral',
        category: (json['category'] as String?) ?? '',
        aiResponse: json['ai_response'] as String?,
      );
}
