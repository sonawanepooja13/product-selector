import 'package:flutter/material.dart';
import '../../models/attendance_record.dart';

class AttendanceCard extends StatelessWidget {
  final AttendanceRecord item;
  final VoidCallback onTap;

  const AttendanceCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (item.status) {
      case AttendanceStatus.present:
        statusColor = Colors.green.shade700;
        break;
      case AttendanceStatus.late:
        statusColor = Colors.orange.shade800;
        break;
      case AttendanceStatus.absent:
        statusColor = Colors.red.shade700;
        break;
      case AttendanceStatus.halfDay:
        statusColor = Colors.blue.shade700;
        break;
    }

    return Card(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Avatar, Employee Name, Employee ID, Status Tag
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF2F5D9F).withValues(alpha: 0.12),
                    child: Text(
                      item.employeeName.isNotEmpty
                          ? item.employeeName[0].toUpperCase()
                          : 'E',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F5D9F),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.employeeName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item.employeeId,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, thickness: 0.6),
              ),
              // Row 2: Clock-In, Clock-Out, Source
              Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  _timeChip(
                    icon: Icons.login_rounded,
                    label: 'In: ${item.clockIn}',
                    color: Colors.teal.shade700,
                  ),
                  _timeChip(
                    icon: Icons.logout_rounded,
                    label: 'Out: ${item.clockOut}',
                    color: Colors.blueGrey.shade700,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fingerprint_rounded,
                          size: 15, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        item.source,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
