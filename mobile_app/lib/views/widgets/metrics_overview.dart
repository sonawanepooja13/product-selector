import 'package:flutter/material.dart';
import '../../models/attendance_record.dart';

class MetricsOverview extends StatelessWidget {
  final List<AttendanceRecord> records;

  const MetricsOverview({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final presentCount =
        records.where((r) => r.status == AttendanceStatus.present).length;
    final lateCount =
        records.where((r) => r.status == AttendanceStatus.late).length;
    final absentCount =
        records.where((r) => r.status == AttendanceStatus.absent).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive width calculation to prevent overflow on any phone width
          final cardWidth = (constraints.maxWidth - 20) / 3;
          return Row(
            children: [
              _metricBadge(
                title: 'Present',
                count: '$presentCount',
                color: Colors.green.shade700,
                width: cardWidth,
              ),
              const SizedBox(width: 10),
              _metricBadge(
                title: 'Late',
                count: '$lateCount',
                color: Colors.amber.shade900,
                width: cardWidth,
              ),
              const SizedBox(width: 10),
              _metricBadge(
                title: 'Absent',
                count: '$absentCount',
                color: Colors.red.shade700,
                width: cardWidth,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _metricBadge({
    required String title,
    required String count,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
