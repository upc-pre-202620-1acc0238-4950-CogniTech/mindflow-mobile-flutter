import '../../../core/network/api_client.dart';
import '../domain/analytics_dashboard.dart';

class AnalyticsApi {
  final ApiClient client;
  AnalyticsApi({required this.client});

  Future<AnalyticsDashboard> getDashboard({required DateTime from, required DateTime to}) async {
    final json = await client.get('/analytics/dashboard', query: {
      'from': _isoDate(from),
      'to': _isoDate(to),
    });
    return AnalyticsDashboard.fromJson(json as Map<String, dynamic>);
  }

  Future<List<int>> downloadCsv() => client.getBytes('/analytics/report.csv');

  Future<List<int>> downloadPdf() => client.getBytes('/analytics/report.pdf');

  String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
