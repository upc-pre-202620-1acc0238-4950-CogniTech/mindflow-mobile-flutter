import '../domain/subscription_plan.dart';
import '../infrastructure/subscriptions_api.dart';

class GetMySubscriptionUseCase {
  final SubscriptionsApi api;
  GetMySubscriptionUseCase({required this.api});

  Future<CurrentSubscription> execute() => api.getMine();
}
