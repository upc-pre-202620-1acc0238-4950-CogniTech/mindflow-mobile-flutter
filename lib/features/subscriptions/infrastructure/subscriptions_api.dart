import '../../../core/network/api_client.dart';
import '../domain/subscription_plan.dart';

class SubscriptionsApi {
  final ApiClient client;
  SubscriptionsApi({required this.client});

  Future<List<SubscriptionPlan>> getPlans() async {
    final json = await client.get('/subscriptions/plans', auth: false);
    return (json as List).map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CurrentSubscription> getMine() async {
    final json = await client.get('/subscriptions/me') as Map<String, dynamic>;
    return CurrentSubscription.fromJson(json);
  }

  /// Returns the Stripe Checkout URL to open in a browser (test mode —
  /// the backend has no mobile deep-link return target, so the app
  /// re-polls `/subscriptions/me` after the user comes back instead of
  /// catching a redirect).
  Future<String> startCheckout() async {
    final json = await client.post('/subscriptions/checkout') as Map<String, dynamic>;
    return json['checkout_url'] as String;
  }
}
