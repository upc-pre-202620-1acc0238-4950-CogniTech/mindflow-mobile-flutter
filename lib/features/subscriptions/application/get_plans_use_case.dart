import '../domain/subscription_plan.dart';
import '../infrastructure/subscriptions_api.dart';

class GetPlansUseCase {
  final SubscriptionsApi api;
  GetPlansUseCase({required this.api});

  Future<List<SubscriptionPlan>> execute() => api.getPlans();
}
