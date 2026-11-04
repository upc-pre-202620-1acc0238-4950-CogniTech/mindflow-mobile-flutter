class AiFeedbackSummary {
  final int totalRatings;
  final double averageRating;
  final Map<int, int> distribution;

  const AiFeedbackSummary({
    required this.totalRatings,
    required this.averageRating,
    required this.distribution,
  });

  factory AiFeedbackSummary.fromJson(Map<String, dynamic> json) {
    final rawDistribution = json['distribution'] as Map<String, dynamic>? ?? {};
    return AiFeedbackSummary(
      totalRatings: (json['total_ratings'] as num?)?.toInt() ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
      distribution: {
        for (var i = 1; i <= 5; i++) i: (rawDistribution['$i'] as num?)?.toInt() ?? 0,
      },
    );
  }
}
