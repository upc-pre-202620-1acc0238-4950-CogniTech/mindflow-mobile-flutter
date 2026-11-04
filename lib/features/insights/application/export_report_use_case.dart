import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../infrastructure/analytics_api.dart';

class ExportReportUseCase {
  final AnalyticsApi api;
  ExportReportUseCase({required this.api});

  Future<File> executeCsv() async {
    final bytes = await api.downloadCsv();
    return _save(bytes, 'mindflow-report.csv');
  }

  Future<File> executePdf() async {
    final bytes = await api.downloadPdf();
    return _save(bytes, 'mindflow-report.pdf');
  }

  Future<File> _save(List<int> bytes, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    return file.writeAsBytes(bytes);
  }
}
