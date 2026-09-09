import 'package:flutter/foundation.dart';
import '../models/production_batch.dart';

class ProductionService extends ChangeNotifier {
  static final ProductionService _instance = ProductionService._internal();
  factory ProductionService() => _instance;

  ProductionService._internal() {
    _initBatches();
  }

  final List<ProductionBatch> _batches = [];
  List<ProductionBatch> get batches => List.unmodifiable(_batches);

  void _initBatches() {
    _batches.addAll([
      ProductionBatch(
        batchId: 'BATCH-20260821_083',
        productName: '3-Pump Booster Panel 15HP VFD',
        targetQuantity: 5,
        stage: ProductionStage.panelAssembly,
        assignedLead: 'Rajesh Kumar',
        startDate: DateTime.now().subtract(const Duration(days: 4)),
      ),
      ProductionBatch(
        batchId: 'BATCH-20260821_084',
        productName: 'STP Control Panel 7.5HP Dual',
        targetQuantity: 2,
        stage: ProductionStage.wiringAndTesting,
        assignedLead: 'Suresh Patil',
        startDate: DateTime.now().subtract(const Duration(days: 6)),
      ),
      ProductionBatch(
        batchId: 'BATCH-20260825_082',
        productName: 'Smart Water Meter Telemetry Panel',
        targetQuantity: 10,
        stage: ProductionStage.qualityCheck,
        assignedLead: 'Amit Sharma',
        startDate: DateTime.now().subtract(const Duration(days: 8)),
      ),
    ]);
  }

  void addBatch(ProductionBatch batch) {
    _batches.insert(0, batch);
    notifyListeners();
  }

  void advanceStage(String batchId) {
    final idx = _batches.indexWhere((b) => b.batchId == batchId);
    if (idx != -1) {
      final current = _batches[idx];
      if (current.stage.index < ProductionStage.values.length - 1) {
        final nextStage = ProductionStage.values[current.stage.index + 1];
        _batches[idx] = current.copyWith(stage: nextStage);
        notifyListeners();
      }
    }
  }
}
