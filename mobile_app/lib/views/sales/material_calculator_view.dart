import 'package:flutter/material.dart';
import '../widgets/mobile_header.dart';

class MaterialCalculatorTab extends StatefulWidget {
  const MaterialCalculatorTab({super.key});

  @override
  State<MaterialCalculatorTab> createState() => _MaterialCalculatorTabState();
}

class _MaterialCalculatorTabState extends State<MaterialCalculatorTab> {
  double _rawMaterialCost = 15000;
  double _laborHours = 8;
  double _laborRatePerHour = 450;
  double _overheadPercent = 10;
  double _profitMarginPercent = 15;

  @override
  Widget build(BuildContext context) {
    final totalLaborCost = _laborHours * _laborRatePerHour;
    final baseTotal = _rawMaterialCost + totalLaborCost;
    final overheadAmount = baseTotal * (_overheadPercent / 100);
    final subtotalWithOverhead = baseTotal + overheadAmount;
    final profitAmount = subtotalWithOverhead * (_profitMarginPercent / 100);
    final grandTotal = subtotalWithOverhead + profitAmount;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: const MobileHeader(
        title: 'Material & Labor Calculator',
        subtitle: 'Panel Assembly Costing Engine',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cost Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2F5D9F), Color(0xFF1F3B66)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F3B66).withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Grand Estimated Cost',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${grandTotal.toStringAsFixed(2)}',
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
                    _buildCostMetric('Raw Material', '₹${_rawMaterialCost.toStringAsFixed(0)}'),
                    _buildCostMetric('Labor Total', '₹${totalLaborCost.toStringAsFixed(0)}'),
                    _buildCostMetric('Overhead ($overheadAmount)', '₹${overheadAmount.toStringAsFixed(0)}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Controls Card
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cost Parameters Configurator',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Raw Material Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Raw Material Base Cost:'),
                      Chip(
                        label: Text('₹${_rawMaterialCost.toStringAsFixed(0)}'),
                        backgroundColor: Colors.blue.shade50,
                      ),
                    ],
                  ),
                  Slider(
                    value: _rawMaterialCost,
                    min: 1000,
                    max: 100000,
                    divisions: 99,
                    activeColor: const Color(0xFF2F5D9F),
                    onChanged: (val) => setState(() => _rawMaterialCost = val),
                  ),

                  const Divider(),

                  // Labor Hours
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Labor Assembly Hours:'),
                      Chip(
                        label: Text('${_laborHours.toStringAsFixed(1)} hrs'),
                        backgroundColor: Colors.orange.shade50,
                      ),
                    ],
                  ),
                  Slider(
                    value: _laborHours,
                    min: 1,
                    max: 40,
                    divisions: 39,
                    activeColor: Colors.orange,
                    onChanged: (val) => setState(() => _laborHours = val),
                  ),

                  // Labor Rate per Hour
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Labor Hourly Rate:'),
                      Chip(
                        label: Text('₹${_laborRatePerHour.toStringAsFixed(0)}/hr'),
                        backgroundColor: Colors.orange.shade50,
                      ),
                    ],
                  ),
                  Slider(
                    value: _laborRatePerHour,
                    min: 100,
                    max: 2000,
                    divisions: 19,
                    activeColor: Colors.orange,
                    onChanged: (val) => setState(() => _laborRatePerHour = val),
                  ),

                  const Divider(),

                  // Overhead %
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Factory Overhead (${_overheadPercent.toInt()}%):'),
                      Text('₹${overheadAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _overheadPercent,
                    min: 0,
                    max: 30,
                    divisions: 30,
                    onChanged: (val) => setState(() => _overheadPercent = val),
                  ),

                  // Profit Margin %
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Profit Margin (${_profitMarginPercent.toInt()}%):'),
                      Text('₹${profitAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  Slider(
                    value: _profitMarginPercent,
                    min: 0,
                    max: 50,
                    divisions: 50,
                    activeColor: Colors.green,
                    onChanged: (val) => setState(() => _profitMarginPercent = val),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
