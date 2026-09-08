import '../models/attendance_record.dart';

class BiometricSyncService {
  /// Simulates testing biometric TCP device socket connection
  Future<bool> testConnection({
    required String ip,
    required int port,
    required int password,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    if (ip.isEmpty || port <= 0) {
      throw Exception('Invalid IP address or port');
    }
    return true;
  }

  /// Simulates pulling log records from biometric terminal
  Future<List<AttendanceRecord>> fetchNewLogs() async {
    await Future.delayed(const Duration(seconds: 2));
    final now = DateTime.now();
    return [
      AttendanceRecord(
        employeeId: 'EMP-${1005 + now.second}',
        employeeName: 'Kunal Deshmukh',
        date: now,
        clockIn: '09:12 AM',
        clockOut: 'Pending',
        status: AttendanceStatus.present,
        source: 'Biometric device',
      ),
    ];
  }

  /// Initial sample records converted from hr_attendance_leave.csv
  List<AttendanceRecord> getInitialRecords() {
    final today = DateTime.now();
    return [
      AttendanceRecord(
        employeeId: 'EMP-1001',
        employeeName: 'Rajesh Sharma',
        date: today,
        clockIn: '09:02 AM',
        clockOut: '06:15 PM',
        status: AttendanceStatus.present,
        source: 'Biometric device',
      ),
      AttendanceRecord(
        employeeId: 'EMP-1002',
        employeeName: 'Pooja Sonawane',
        date: today,
        clockIn: '09:35 AM',
        clockOut: '06:30 PM',
        status: AttendanceStatus.late,
        source: 'Biometric device',
      ),
      AttendanceRecord(
        employeeId: 'EMP-1003',
        employeeName: 'Amit Verma',
        date: today,
        clockIn: '08:55 AM',
        clockOut: '05:45 PM',
        status: AttendanceStatus.present,
        source: 'Biometric device',
      ),
      AttendanceRecord(
        employeeId: 'EMP-1004',
        employeeName: 'Sneha Patil',
        date: today,
        clockIn: '--:--',
        clockOut: '--:--',
        status: AttendanceStatus.absent,
        source: 'System (Auto)',
      ),
    ];
  }
}
