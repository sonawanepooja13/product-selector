class WaterMeterSpec {
  final String modelName;
  final String meterType; // "Mechanical Multi-Jet", "Ultrasonic Smart Meter", "Electromagnetic"
  final String pipeSize; // "DN15 (1/2\")", "DN20 (3/4\")", "DN25 (1\")", "DN50 (2\")", "DN100 (4\")"
  final double nominalFlowQ3; // m3/h
  final double maxFlowQ4; // m3/h
  final bool pulseOutput;
  final bool rs485Modbus;
  final double unitPrice;

  const WaterMeterSpec({
    required this.modelName,
    required this.meterType,
    required this.pipeSize,
    required this.nominalFlowQ3,
    required this.maxFlowQ4,
    required this.pulseOutput,
    required this.rs485Modbus,
    required this.unitPrice,
  });

  double calculateTotalPrice(int qty, double marginPercent) {
    final subtotal = unitPrice * qty;
    return subtotal * (1 + (marginPercent / 100));
  }
}
