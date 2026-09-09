import 'package:flutter/material.dart';
import '../widgets/mobile_header.dart';

class BmsSelectorView extends StatefulWidget {
  const BmsSelectorView({super.key});

  @override
  State<BmsSelectorView> createState() => _BmsSelectorViewState();
}

class _BmsSelectorViewState extends State<BmsSelectorView> {
  int _digitalInputs = 16;
  int _digitalOutputs = 8;
  int _analogInputs = 8;
  int _analogOutputs = 4;
  String _protocol = 'BACnet IP & Modbus RTU';

  @override
  Widget build(BuildContext context) {
    final totalPoints = _digitalInputs + _digitalOutputs + _analogInputs + _analogOutputs;
    final baseCost = 45000 + (totalPoints * 850);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: const MobileHeader(
        title: 'BMS Panel Configurator',
        subtitle: 'DDC Controller & I/O Points Sizing',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total DDC Controller Panel Estimate',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  '₹${baseCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.white24, height: 24),
                Text('Total I/O Points Configured: $totalPoints Points',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DDC I/O Points Sizing',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  _buildIoStepper('Digital Inputs (DI)', _digitalInputs, (val) {
                    setState(() => _digitalInputs = val);
                  }),
                  _buildIoStepper('Digital Outputs (DO)', _digitalOutputs, (val) {
                    setState(() => _digitalOutputs = val);
                  }),
                  _buildIoStepper('Analog Inputs (AI)', _analogInputs, (val) {
                    setState(() => _analogInputs = val);
                  }),
                  _buildIoStepper('Analog Outputs (AO)', _analogOutputs, (val) {
                    setState(() => _analogOutputs = val);
                  }),

                  const Divider(),

                  DropdownButtonFormField<String>(
                    value: _protocol,
                    items: [
                      'BACnet IP & Modbus RTU',
                      'Modbus RS485 Only',
                      'LonWorks'
                    ]
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) => setState(() => _protocol = val!),
                    decoration: const InputDecoration(labelText: 'Communication Protocol'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIoStepper(String title, int val, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: val > 0 ? () => onChanged(val - 2) : null,
              ),
              Text('$val', style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => onChanged(val + 2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
