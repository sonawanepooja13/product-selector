import 'package:flutter/material.dart';
import '../../models/water_meter.dart';
import '../widgets/mobile_header.dart';

class WaterMeterView extends StatefulWidget {
  const WaterMeterView({super.key});

  @override
  State<WaterMeterView> createState() => _WaterMeterViewState();
}

class _WaterMeterViewState extends State<WaterMeterView> {
  String _meterType = 'Ultrasonic Smart Meter';
  String _pipeSize = 'DN25 (1")';
  int _quantity = 10;
  bool _pulseOutput = true;
  bool _modbusTelemetry = true;
  double _margin = 15.0;

  final List<WaterMeterSpec> _specs = [
    const WaterMeterSpec(
      modelName: 'WM-ULTRASONIC-DN15',
      meterType: 'Ultrasonic Smart Meter',
      pipeSize: 'DN15 (1/2")',
      nominalFlowQ3: 2.5,
      maxFlowQ4: 3.125,
      pulseOutput: true,
      rs485Modbus: true,
      unitPrice: 4200,
    ),
    const WaterMeterSpec(
      modelName: 'WM-ULTRASONIC-DN25',
      meterType: 'Ultrasonic Smart Meter',
      pipeSize: 'DN25 (1")',
      nominalFlowQ3: 6.3,
      maxFlowQ4: 7.875,
      pulseOutput: true,
      rs485Modbus: true,
      unitPrice: 6500,
    ),
    const WaterMeterSpec(
      modelName: 'WM-ELECTRO-DN50',
      meterType: 'Electromagnetic',
      pipeSize: 'DN50 (2")',
      nominalFlowQ3: 25.0,
      maxFlowQ4: 31.25,
      pulseOutput: true,
      rs485Modbus: true,
      unitPrice: 18500,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedSpec = _specs.firstWhere(
      (s) => s.pipeSize == _pipeSize,
      orElse: () => _specs.first,
    );

    final totalPrice = selectedSpec.calculateTotalPrice(_quantity, _margin);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: const MobileHeader(
        title: 'Water Meter Selector',
        subtitle: 'Flow Rate, Sizing & Modbus Telemetry',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quote Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD97706), Color(0xFFB45309)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.shade900.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Water Meter Quotation Summary',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  '₹${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.white24, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Model: ${selectedSpec.modelName}',
                        style: const TextStyle(color: Colors.white, fontSize: 12)),
                    Text('Flow Q3: ${selectedSpec.nominalFlowQ3} m³/h',
                        style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Config Card
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Technical Configuration',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _meterType,
                    items: [
                      'Mechanical Multi-Jet',
                      'Ultrasonic Smart Meter',
                      'Electromagnetic'
                    ]
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setState(() => _meterType = val!),
                    decoration: const InputDecoration(labelText: 'Meter Technology'),
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: _pipeSize,
                    items: [
                      'DN15 (1/2")',
                      'DN25 (1")',
                      'DN50 (2")'
                    ]
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => _pipeSize = val!),
                    decoration: const InputDecoration(labelText: 'Nominal Pipe Diameter'),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Quantity (Units):'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          Text('$_quantity',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),

                  SwitchListTile(
                    title: const Text('Pulse Output Interface'),
                    value: _pulseOutput,
                    onChanged: (val) => setState(() => _pulseOutput = val),
                  ),
                  SwitchListTile(
                    title: const Text('RS485 Modbus Telemetry Protocol'),
                    value: _modbusTelemetry,
                    onChanged: (val) => setState(() => _modbusTelemetry = val),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
