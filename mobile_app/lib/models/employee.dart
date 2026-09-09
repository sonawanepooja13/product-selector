class Employee {
  final String id;
  final String fullName;
  final String department; // Engineering, Production, Sales, HR, Accounts
  final String designation;
  final double monthlySalary;
  final String mobileNumber;
  final DateTime dateJoined;
  final int activeLeaveRequests;

  const Employee({
    required this.id,
    required this.fullName,
    required this.department,
    required this.designation,
    required this.monthlySalary,
    required this.mobileNumber,
    required this.dateJoined,
    this.activeLeaveRequests = 0,
  });

  Employee copyWith({
    String? id,
    String? fullName,
    String? department,
    String? designation,
    double? monthlySalary,
    String? mobileNumber,
    DateTime? dateJoined,
    int? activeLeaveRequests,
  }) {
    return Employee(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      dateJoined: dateJoined ?? this.dateJoined,
      activeLeaveRequests: activeLeaveRequests ?? this.activeLeaveRequests,
    );
  }
}
