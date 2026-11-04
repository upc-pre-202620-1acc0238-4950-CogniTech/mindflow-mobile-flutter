import '../domain/analytics_dashboard.dart';
import '../infrastructure/analytics_api.dart';

class GetDashboardUseCase {
  final AnalyticsApi api;
  GetDashboardUseCase({required this.api});

  Future<AnalyticsDashboard> execute({required DateTime from, required DateTime to}) =>
      api.getDashboard(from: from, to: to);
}
