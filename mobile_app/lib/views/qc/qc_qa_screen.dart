import 'package:flutter/material.dart';
import '../../models/qc_report.dart';
import '../../services/qc_service.dart';
import '../widgets/mobile_header.dart';

class QcQaScreen extends StatefulWidget {
  const QcQaScreen({super.key});

  @override
  State<QcQaScreen> createState() => _QcQaScreenState();
}

class _QcQaScreenState extends State<QcQaScreen> {
  final QcService _service = QcService();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _service,
      builder: (context, _) {
        final reports = _service.reports;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F9),
          appBar: const MobileHeader(
            title: 'Quality Control (QC/QA)',
            subtitle: 'Panel Inspection Checklists & Defect Logs',
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final r = reports[index];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r.inspectionId,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Chip(
                            label: Text(r.statusLabel,
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                            backgroundColor: r.status == QcStatus.passed
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Batch: ${r.batchId} • Inspector: ${r.inspectorName}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 10),
                      Text(
                        'Checkpoints Passed: ${r.passedCheckpoints} / ${r.totalCheckpoints}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      if (r.defectNotes.isNotEmpty) ...[
                        const Divider(height: 16),
                        Text('Notes: ${r.defectNotes}',
                            style: const TextStyle(
                                fontSize: 12, fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
            onPressed: () => _showAddQcDialog(context),
            child: const Icon(Icons.playlist_add_check_rounded),
          ),
        );
      },
    );
  }

  void _showAddQcDialog(BuildContext context) {
    final batchCtrl = TextEditingController(text: 'BATCH-20260821_083');
    final inspectorCtrl = TextEditingController(text: 'Suresh Patil');
    final notesCtrl = TextEditingController();
    QcStatus status = QcStatus.passed;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
                const Text('Log Quality Control Inspection',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: batchCtrl,
                  decoration: const InputDecoration(labelText: 'Production Batch ID'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: inspectorCtrl,
                  decoration: const InputDecoration(labelText: 'Inspector Name'),
                ),
                const SizedBox(height: 12),
                SegmentedButton<QcStatus>(
                  segments: const [
                    ButtonSegment(value: QcStatus.passed, label: Text('PASS')),
                    ButtonSegment(value: QcStatus.failed, label: Text('FAIL')),
                  ],
                  selected: {status},
                  onSelectionChanged: (val) =>
                      setModalState(() => status = val.first),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Defect / QC Notes'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _service.addReport(
                        QcReport(
                          inspectionId:
                              'QC-2026-${(100 + _service.reports.length).toString()}',
                          batchId: batchCtrl.text.trim(),
                          inspectorName: inspectorCtrl.text.trim(),
                          inspectionDate: DateTime.now(),
                          status: status,
                          totalCheckpoints: 12,
                          passedCheckpoints: status == QcStatus.passed ? 12 : 10,
                          defectNotes: notesCtrl.text.trim(),
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save Inspection Record'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
