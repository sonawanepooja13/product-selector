enum QcStatus { passed, failed, pending }

class QcReport {
  final String inspectionId;
  final String batchId;
  final String inspectorName;
  final DateTime inspectionDate;
  final QcStatus status;
  final int totalCheckpoints;
  final int passedCheckpoints;
  final String defectNotes;

  const QcReport({
    required this.inspectionId,
    required this.batchId,
    required this.inspectorName,
    required this.inspectionDate,
    required this.status,
    required this.totalCheckpoints,
    required this.passedCheckpoints,
    required this.defectNotes,
  });

  String get statusLabel {
    switch (status) {
      case QcStatus.passed:
        return 'PASSED';
      case QcStatus.failed:
        return 'FAILED';
      case QcStatus.pending:
        return 'PENDING';
    }
  }

  QcReport copyWith({
    String? inspectionId,
    String? batchId,
    String? inspectorName,
    DateTime? inspectionDate,
    QcStatus? status,
    int? totalCheckpoints,
    int? passedCheckpoints,
    String? defectNotes,
  }) {
    return QcReport(
      inspectionId: inspectionId ?? this.inspectionId,
      batchId: batchId ?? this.batchId,
      inspectorName: inspectorName ?? this.inspectorName,
      inspectionDate: inspectionDate ?? this.inspectionDate,
      status: status ?? this.status,
      totalCheckpoints: totalCheckpoints ?? this.totalCheckpoints,
      passedCheckpoints: passedCheckpoints ?? this.passedCheckpoints,
      defectNotes: defectNotes ?? this.defectNotes,
    );
  }
}
