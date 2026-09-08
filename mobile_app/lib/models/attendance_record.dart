enum AttendanceStatus { present, late, absent, halfDay }

class AttendanceRecord {
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final String clockIn;
  final String clockOut;
  final AttendanceStatus status;
  final String source;

  const AttendanceRecord({
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.clockIn,
    required this.clockOut,
    required this.status,
    required this.source,
  });

  String get formattedDate =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String get statusLabel {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.halfDay:
        return 'Half Day';
    }
  }

  AttendanceRecord copyWith({
    String? employeeId,
    String? employeeName,
    DateTime? date,
    String? clockIn,
    String? clockOut,
    AttendanceStatus? status,
    String? source,
  }) {
    return AttendanceRecord(
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      clockIn: clockIn ?? this.clockIn,
      clockOut: clockOut ?? this.clockOut,
      status: status ?? this.status,
      source: source ?? this.source,
    );
  }
}
