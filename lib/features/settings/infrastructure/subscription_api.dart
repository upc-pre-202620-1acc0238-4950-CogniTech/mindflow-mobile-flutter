import '../../../core/network/api_client.dart';

class SubscriptionApi {
  final ApiClient client;
  SubscriptionApi({required this.client});

  /// Returns the raw plan id ("freemium"/"premium") from `GET
  /// /subscriptions/me`, which the backend serializes from the
  /// Subscription entity directly (no dedicated resource DTO).
  Future<String> getPlan() async {
    final json = await client.get('/subscriptions/me') as Map<String, dynamic>;
    return (json['plan'] as String?) ?? 'freemium';
  }
}
