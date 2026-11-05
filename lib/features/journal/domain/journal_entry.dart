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

/// The backend always returns sentiment as English ('positive' / 'neutral' /
/// 'negative'); this maps it to the label shown in the UI.
String sentimentLabelEs(String sentiment) {
  switch (sentiment.toLowerCase()) {
    case 'positive':
      return 'Positivo';
    case 'negative':
      return 'Negativo';
    default:
      return 'Neutral';
  }
}

extension JournalEntrySentimentLabel on JournalEntry {
  String get sentimentLabel => sentimentLabelEs(sentiment);
}
