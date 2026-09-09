import 'package:flutter/material.dart';
import '../../models/employee.dart';
import '../../services/hr_attendance_service.dart';
import '../widgets/mobile_header.dart';

class HrScreen extends StatefulWidget {
  const HrScreen({super.key});

  @override
  State<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen> {
  final HrAttendanceService _service = HrAttendanceService();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _service,
      builder: (context, _) {
        final employees = _service.employees;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F9),
          appBar: const MobileHeader(
            title: 'Human Resources (HR)',
            subtitle: 'Employee Directory & Payroll',
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final emp = employees[index];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF2F5D9F),
                    foregroundColor: Colors.white,
                    child: Text(
                      emp.fullName.substring(0, 1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    emp.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text('${emp.designation} • ${emp.department}',
                          style: const TextStyle(fontSize: 12)),
                      Text('Mobile: ${emp.mobileNumber}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${emp.monthlySalary.toStringAsFixed(0)}/mo',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F5D9F),
                          fontSize: 13,
                        ),
                      ),
                      if (emp.activeLeaveRequests > 0)
                        Chip(
                          label: Text('${emp.activeLeaveRequests} Leave Req',
                              style: const TextStyle(
                                  fontSize: 9, color: Colors.amber)),
                          backgroundColor: Colors.amber.shade50,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFFDB2777),
            foregroundColor: Colors.white,
            onPressed: () => _showAddEmployeeDialog(context),
            child: const Icon(Icons.person_add_rounded),
          ),
        );
      },
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final deptCtrl = TextEditingController(text: 'Production');
    final desigCtrl = TextEditingController(text: 'Assembly Technician');
    final salaryCtrl = TextEditingController(text: '35000');
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Register New Employee',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deptCtrl,
                decoration: const InputDecoration(labelText: 'Department'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: desigCtrl,
                decoration: const InputDecoration(labelText: 'Designation'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: salaryCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monthly Salary (₹)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB2777),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty) {
                      _service.addEmployee(
                        Employee(
                          id: 'EMP-${(100 + _service.employees.length).toString()}',
                          fullName: nameCtrl.text.trim(),
                          department: deptCtrl.text.trim(),
                          designation: desigCtrl.text.trim(),
                          monthlySalary: double.tryParse(salaryCtrl.text) ?? 0.0,
                          mobileNumber: phoneCtrl.text.trim(),
                          dateJoined: DateTime.now(),
                        ),
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Save Employee Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
