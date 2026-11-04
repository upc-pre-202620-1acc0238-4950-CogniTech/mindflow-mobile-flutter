import '../infrastructure/subscriptions_api.dart';

class StartCheckoutUseCase {
  final SubscriptionsApi api;
  StartCheckoutUseCase({required this.api});

  Future<String> execute() => api.startCheckout();
}
