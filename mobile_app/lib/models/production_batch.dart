enum ProductionStage {
  orderReceived,
  componentSourcing,
  panelAssembly,
  wiringAndTesting,
  qualityCheck,
  readyForDispatch
}

class ProductionBatch {
  final String batchId;
  final String productName;
  final int targetQuantity;
  final ProductionStage stage;
  final String assignedLead;
  final DateTime startDate;

  const ProductionBatch({
    required this.batchId,
    required this.productName,
    required this.targetQuantity,
    required this.stage,
    required this.assignedLead,
    required this.startDate,
  });

  String get stageLabel {
    switch (stage) {
      case ProductionStage.orderReceived:
        return 'Order Received';
      case ProductionStage.componentSourcing:
        return 'Component Sourcing';
      case ProductionStage.panelAssembly:
        return 'Panel Assembly';
      case ProductionStage.wiringAndTesting:
        return 'Wiring & Testing';
      case ProductionStage.qualityCheck:
        return 'Quality Check (QC)';
      case ProductionStage.readyForDispatch:
        return 'Ready for Dispatch';
    }
  }

  double get progressPercent {
    return (stage.index + 1) / ProductionStage.values.length;
  }

  ProductionBatch copyWith({
    String? batchId,
    String? productName,
    int? targetQuantity,
    ProductionStage? stage,
    String? assignedLead,
    DateTime? startDate,
  }) {
    return ProductionBatch(
      batchId: batchId ?? this.batchId,
      productName: productName ?? this.productName,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      stage: stage ?? this.stage,
      assignedLead: assignedLead ?? this.assignedLead,
      startDate: startDate ?? this.startDate,
    );
  }
}
