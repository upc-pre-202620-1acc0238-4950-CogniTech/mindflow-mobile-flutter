class SubscriptionPlan {
  final String id;
  final double price;
  final String currency;
  final String? interval;

  const SubscriptionPlan({
    required this.id,
    required this.price,
    required this.currency,
    this.interval,
  });

  bool get isPremium => id == 'premium';

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) => SubscriptionPlan(
        id: json['id'] as String,
        price: (json['price'] as num).toDouble(),
        currency: (json['currency'] as String?) ?? 'USD',
        interval: json['interval'] as String?,
      );
}

class CurrentSubscription {
  final String plan;
  final String status;

  const CurrentSubscription({required this.plan, required this.status});

  bool get isPremium => plan == 'premium';

  factory CurrentSubscription.fromJson(Map<String, dynamic> json) => CurrentSubscription(
        plan: (json['plan'] as String?) ?? 'freemium',
        status: (json['status'] as String?) ?? 'active',
      );
}
