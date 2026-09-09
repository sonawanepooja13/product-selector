import 'package:flutter/foundation.dart';
import '../models/qc_report.dart';

class QcService extends ChangeNotifier {
  static final QcService _instance = QcService._internal();
  factory QcService() => _instance;

  QcService._internal() {
    _initReports();
  }

  final List<QcReport> _reports = [];
  List<QcReport> get reports => List.unmodifiable(_reports);

  void _initReports() {
    _reports.addAll([
      QcReport(
        inspectionId: 'QC-2026-041',
        batchId: 'BATCH-20260821_083',
        inspectorName: 'Suresh Patil',
        inspectionDate: DateTime.now().subtract(const Duration(days: 1)),
        status: QcStatus.passed,
        totalCheckpoints: 12,
        passedCheckpoints: 12,
        defectNotes: 'All insulation and busbar torque tests passed 100%.',
      ),
      QcReport(
        inspectionId: 'QC-2026-042',
        batchId: 'BATCH-20260821_084',
        inspectorName: 'Suresh Patil',
        inspectionDate: DateTime.now().subtract(const Duration(hours: 4)),
        status: QcStatus.failed,
        totalCheckpoints: 12,
        passedCheckpoints: 10,
        defectNotes: 'Phase R indicator LED loose connection; door earth wire missing terminal lug.',
      ),
    ]);
  }

  void addReport(QcReport report) {
    _reports.insert(0, report);
    notifyListeners();
  }
}
