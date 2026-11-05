class SupportMessage {
  final int id;
  final int authorId;
  final bool isStaff;
  final String body;
  final DateTime? createdAt;

  const SupportMessage({
    required this.id,
    required this.authorId,
    required this.isStaff,
    required this.body,
    this.createdAt,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) => SupportMessage(
        id: json['id'] as int,
        authorId: (json['author_id'] as num?)?.toInt() ?? 0,
        isStaff: json['is_staff'] as bool? ?? false,
        body: (json['body'] as String?) ?? '',
        createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
      );
}

class SupportTicket {
  final int id;
  final String subject;
  final String category;
  final String priority;
  final String status;
  final List<SupportMessage> messages;
  final DateTime? updatedAt;

  const SupportTicket({
    required this.id,
    required this.subject,
    required this.category,
    required this.priority,
    required this.status,
    required this.messages,
    this.updatedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
        id: json['id'] as int,
        subject: (json['subject'] as String?) ?? '',
        category: (json['category'] as String?) ?? 'general',
        priority: (json['priority'] as String?) ?? 'normal',
        status: (json['status'] as String?) ?? 'open',
        messages: ((json['messages'] as List?) ?? [])
            .map((e) => SupportMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
        updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
      );

  /// The backend stores status as free English text (default 'open', set by
  /// support staff otherwise); this maps the known values to Spanish and
  /// falls back to the raw value for anything else.
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Abierto';
      case 'closed':
        return 'Cerrado';
      case 'resolved':
        return 'Resuelto';
      case 'in_progress':
        return 'En progreso';
      case 'pending':
        return 'Pendiente';
      default:
        return status;
    }
  }
}
