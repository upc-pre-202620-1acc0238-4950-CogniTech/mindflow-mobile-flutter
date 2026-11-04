class AppNotification {
  final int id;
  final String type;
  final String title;
  final String body;
  final DateTime? readAt;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.readAt,
    this.createdAt,
  });

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as int,
        type: (json['type'] as String?) ?? 'general',
        title: (json['title'] as String?) ?? '',
        body: (json['body'] as String?) ?? '',
        readAt: json['read_at'] == null ? null : DateTime.parse(json['read_at'] as String),
        createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
      );
}
