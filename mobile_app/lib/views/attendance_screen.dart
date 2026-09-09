import 'package:flutter/material.dart';
import '../models/attendance_record.dart';
import '../services/hr_attendance_service.dart';
import 'widgets/mobile_header.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final HrAttendanceService _service = HrAttendanceService();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _service,
      builder: (context, _) {
        final logs = _service.attendanceLogs;

        final presentCount = logs
            .where((l) => l.status == AttendanceStatus.present)
            .length;
        final lateCount = logs
            .where((l) => l.status == AttendanceStatus.late)
            .length;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F9),
          appBar: const MobileHeader(
            title: 'Biometric Attendance',
            subtitle: 'Device Sync & Punch Logs',
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Biometric Device Connection Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F3B66),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.fingerprint_rounded,
                          color: Colors.greenAccent, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Biometric Device Online',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          SizedBox(height: 2),
                          Text('IP: 192.168.1.100 • Device #1 Connected',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white24,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                      ),
                      onPressed: () => _simulatePunchIn(context),
                      child: const Text('Sync Log',
                          style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Present Today', '$presentCount Staff',
                        Colors.green.shade50, Colors.green.shade700),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('Late Arrivals', '$lateCount Staff',
                        Colors.amber.shade50, Colors.amber.shade900),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'Today\'s Attendance Punch Logs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ...logs.map((rec) => Card(
                    elevation: 0.5,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF2F5D9F),
                        foregroundColor: Colors.white,
                        child: Icon(Icons.person_rounded, size: 20),
                      ),
                      title: Text(rec.employeeName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(
                          'Clock In: ${rec.clockIn} • Clock Out: ${rec.clockOut}\nSource: ${rec.source}',
                          style: const TextStyle(fontSize: 11)),
                      trailing: Chip(
                        label: Text(rec.statusLabel,
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold)),
                        backgroundColor: rec.status == AttendanceStatus.present
                            ? Colors.green.shade50
                            : Colors.amber.shade50,
                      ),
                    ),
                  )),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xFF0284C7),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.touch_app_rounded),
            label: const Text('Punch In / Out'),
            onPressed: () => _simulatePunchIn(context),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: textCol, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: textCol, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _simulatePunchIn(BuildContext context) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    _service.addAttendanceRecord(
      AttendanceRecord(
        employeeId: 'EMP-001',
        employeeName: 'Current User',
        date: now,
        clockIn: timeStr,
        clockOut: '--:--',
        status: AttendanceStatus.present,
        source: 'Mobile App Punch',
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attendance punch logged successfully at $timeStr!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
