import 'package:flutter/material.dart';
import '../../models/attendance_record.dart';

class RecordDetailBottomSheet extends StatelessWidget {
  final AttendanceRecord item;

  const RecordDetailBottomSheet({super.key, required this.item});

  static void show(BuildContext context, AttendanceRecord item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => RecordDetailBottomSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.employeeName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Text(
            'ID: ${item.employeeId}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const Divider(height: 24),
          _detailRow('Date', item.formattedDate),
          _detailRow('Clock In Time', item.clockIn),
          _detailRow('Clock Out Time', item.clockOut),
          _detailRow('Attendance Status', item.statusLabel),
          _detailRow('Data Source', item.source),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.tonal(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
