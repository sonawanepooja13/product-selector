import 'package:flutter/material.dart';
import '../../models/production_batch.dart';
import '../../services/production_service.dart';
import '../widgets/mobile_header.dart';

class ProductionScreen extends StatefulWidget {
  const ProductionScreen({super.key});

  @override
  State<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends State<ProductionScreen> {
  final ProductionService _prodService = ProductionService();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _prodService,
      builder: (context, _) {
        final batches = _prodService.batches;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F9),
          appBar: const MobileHeader(
            title: 'Production Process',
            subtitle: 'Batch Stepper & Manufacturing Status',
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: batches.length,
            itemBuilder: (context, index) {
              final batch = batches[index];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 14),
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
                          Text(
                            batch.batchId,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2F5D9F),
                            ),
                          ),
                          Chip(
                            label: Text(
                              batch.stageLabel,
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: Colors.amber.shade50,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${batch.productName} • Target Qty: ${batch.targetQuantity} Units',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),

                      // Progress Bar
                      LinearProgressIndicator(
                        value: batch.progressPercent,
                        backgroundColor: Colors.grey.shade200,
                        color: const Color(0xFF2F5D9F),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lead: ${batch.assignedLead}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (batch.stage.index <
                              ProductionStage.values.length - 1)
                            ElevatedButton.icon(
                              onPressed: () {
                                _prodService.advanceStage(batch.batchId);
                              },
                              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                              label: const Text('Next Stage'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2F5D9F),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF2F5D9F),
            foregroundColor: Colors.white,
            onPressed: () => _showAddBatchDialog(context),
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }

  void _showAddBatchDialog(BuildContext context) {
    final prodCtrl = TextEditingController(text: '4-Pump VFD Booster Panel 20HP');
    final qtyCtrl = TextEditingController(text: '3');
    final leadCtrl = TextEditingController(text: 'Rajesh Kumar');

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
              const Text('Launch New Production Batch',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: prodCtrl,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Batch Quantity'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: leadCtrl,
                decoration: const InputDecoration(labelText: 'Assigned Team Lead'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F5D9F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final batchNo =
                        'BATCH-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}_${(100 + _prodService.batches.length).toString()}';

                    _prodService.addBatch(
                      ProductionBatch(
                        batchId: batchNo,
                        productName: prodCtrl.text.trim(),
                        targetQuantity: int.tryParse(qtyCtrl.text) ?? 1,
                        stage: ProductionStage.orderReceived,
                        assignedLead: leadCtrl.text.trim(),
                        startDate: DateTime.now(),
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Start Production'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
