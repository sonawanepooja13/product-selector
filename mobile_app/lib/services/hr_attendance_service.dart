import 'package:flutter/foundation.dart';
import '../models/employee.dart';
import '../models/attendance_record.dart';

class HrAttendanceService extends ChangeNotifier {
  static final HrAttendanceService _instance = HrAttendanceService._internal();
  factory HrAttendanceService() => _instance;

  HrAttendanceService._internal() {
    _initEmployees();
    _initAttendance();
  }

  final List<Employee> _employees = [];
  final List<AttendanceRecord> _attendanceLogs = [];

  List<Employee> get employees => List.unmodifiable(_employees);
  List<AttendanceRecord> get attendanceLogs => List.unmodifiable(_attendanceLogs);

  void _initEmployees() {
    _employees.addAll([
      Employee(
        id: 'EMP-001',
        fullName: 'Rajesh Kumar',
        department: 'Production',
        designation: 'Senior Assembly Lead',
        monthlySalary: 45000,
        mobileNumber: '+91 98765 11223',
        dateJoined: DateTime(2022, 3, 15),
        activeLeaveRequests: 1,
      ),
      Employee(
        id: 'EMP-002',
        fullName: 'Priya Sharma',
        department: 'Engineering',
        designation: 'R&D Electrical Engineer',
        monthlySalary: 52000,
        mobileNumber: '+91 98112 33445',
        dateJoined: DateTime(2021, 8, 1),
        activeLeaveRequests: 0,
      ),
      Employee(
        id: 'EMP-003',
        fullName: 'Suresh Patil',
        department: 'Quality Control',
        designation: 'QC Inspector',
        monthlySalary: 38000,
        mobileNumber: '+91 97654 55667',
        dateJoined: DateTime(2023, 1, 10),
        activeLeaveRequests: 0,
      ),
    ]);
  }

  void _initAttendance() {
    final today = DateTime.now();
    _attendanceLogs.addAll([
      AttendanceRecord(
        employeeId: 'EMP-001',
        employeeName: 'Rajesh Kumar',
        date: today,
        clockIn: '09:02 AM',
        clockOut: '06:15 PM',
        status: AttendanceStatus.present,
        source: 'Biometric Device #1',
      ),
      AttendanceRecord(
        employeeId: 'EMP-002',
        employeeName: 'Priya Sharma',
        date: today,
        clockIn: '09:35 AM',
        clockOut: '06:30 PM',
        status: AttendanceStatus.late,
        source: 'Biometric Device #1',
      ),
      AttendanceRecord(
        employeeId: 'EMP-003',
        employeeName: 'Suresh Patil',
        date: today,
        clockIn: '08:55 AM',
        clockOut: '06:00 PM',
        status: AttendanceStatus.present,
        source: 'Mobile App Punch',
      ),
    ]);
  }

  void addEmployee(Employee emp) {
    _employees.add(emp);
    notifyListeners();
  }

  void addAttendanceRecord(AttendanceRecord rec) {
    _attendanceLogs.insert(0, rec);
    notifyListeners();
  }
}
