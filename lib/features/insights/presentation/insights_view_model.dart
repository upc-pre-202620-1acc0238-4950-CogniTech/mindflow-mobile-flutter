import 'package:flutter/material.dart';

import '../../habits/application/get_habits_use_case.dart';
import '../../habits/domain/habit.dart';
import '../application/export_report_use_case.dart';
import '../application/get_dashboard_use_case.dart';
import '../domain/analytics_dashboard.dart';

class InsightsViewModel extends ChangeNotifier {
  final GetDashboardUseCase getDashboard;
  final GetHabitsUseCase getHabits;
  final ExportReportUseCase exportReport;

  InsightsViewModel({
    required this.getDashboard,
    required this.getHabits,
    required this.exportReport,
  }) {
    refresh();
  }

  static const ranges = ['Semana', 'Mes'];

  bool isLoading = true;
  bool isExporting = false;
  String? errorMessage;
  int rangeIndex = 1;
  AnalyticsDashboard? dashboard;
  int bestStreak = 0;

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final now = DateTime.now();
      final from = rangeIndex == 0 ? now.subtract(const Duration(days: 7)) : now.subtract(const Duration(days: 30));
      final results = await Future.wait([
        getDashboard.execute(from: from, to: now),
        getHabits.execute(),
      ]);
      dashboard = results[0] as AnalyticsDashboard;
      final habits = results[1] as List<Habit>;
      bestStreak =
          habits.isEmpty ? 0 : habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);
    } catch (_) {
      errorMessage = 'No se pudo cargar tu análisis. Desliza hacia abajo para reintentar.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectRange(int index) async {
    rangeIndex = index;
    await refresh();
  }

  Future<String?> export({required bool pdf}) async {
    isExporting = true;
    errorMessage = null;
    notifyListeners();
    try {
      final file = pdf ? await exportReport.executePdf() : await exportReport.executeCsv();
      return file.path;
    } catch (_) {
      errorMessage = 'No se pudo exportar el reporte. Intenta de nuevo.';
      return null;
    } finally {
      isExporting = false;
      notifyListeners();
    }
  }
}
