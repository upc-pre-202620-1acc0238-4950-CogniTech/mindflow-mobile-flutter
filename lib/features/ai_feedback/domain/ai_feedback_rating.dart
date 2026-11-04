class AiFeedbackRating {
  final int id;
  final int contentId;
  final String contentType;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  const AiFeedbackRating({
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  factory AiFeedbackRating.fromJson(Map<String, dynamic> json) => AiFeedbackRating(
        id: json['id'] as int,
        contentId: json['content_id'] as int,
        contentType: (json['content_type'] as String?) ?? '',
        rating: json['rating'] as int,
        comment: json['comment'] as String?,
        createdAt:
            json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      );
}
