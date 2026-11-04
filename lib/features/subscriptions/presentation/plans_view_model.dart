import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../application/get_my_subscription_use_case.dart';
import '../application/get_plans_use_case.dart';
import '../application/start_checkout_use_case.dart';
import '../domain/subscription_plan.dart';

class PlansViewModel extends ChangeNotifier with WidgetsBindingObserver {
  final GetPlansUseCase getPlans;
  final GetMySubscriptionUseCase getMySubscription;
  final StartCheckoutUseCase startCheckout;

  PlansViewModel({
    required this.getPlans,
    required this.getMySubscription,
    required this.startCheckout,
  }) {
    WidgetsBinding.instance.addObserver(this);
    refresh();
  }

  bool isLoading = true;
  bool isStartingCheckout = false;
  bool _awaitingCheckoutReturn = false;
  String? errorMessage;
  List<SubscriptionPlan> plans = [];
  CurrentSubscription? current;

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([getPlans.execute(), getMySubscription.execute()]);
      plans = results[0] as List<SubscriptionPlan>;
      current = results[1] as CurrentSubscription;
    } catch (_) {
      errorMessage = 'Could not load plans right now.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> upgrade() async {
    isStartingCheckout = true;
    errorMessage = null;
    notifyListeners();
    try {
      final url = await startCheckout.execute();
      _awaitingCheckoutReturn = true;
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      errorMessage = 'Could not start checkout. Stripe test credentials may not be configured.';
    } finally {
      isStartingCheckout = false;
      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingCheckoutReturn) {
      _awaitingCheckoutReturn = false;
      refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
