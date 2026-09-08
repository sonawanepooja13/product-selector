import 'package:flutter/material.dart';
import '../../models/product_configuration.dart';
import '../../services/bom_calculation_engine.dart';

class MaterialCalculatorTab extends StatefulWidget {
  const MaterialCalculatorTab({super.key});

  @override
  State<MaterialCalculatorTab> createState() => _MaterialCalculatorTabState();
}

class _MaterialCalculatorTabState extends State<MaterialCalculatorTab> {
  final TextEditingController _currentController =
      TextEditingController(text: '15');

  int _numPumps = 3;
  int _numVfd = 1;
  bool _mainIncomer = true;
  bool _doorMountSwitch = true;
  int _panelSizeLevel = 4;
  bool _olrRequired = false;
  bool _indicatorLight = false;
  String _controllerType = 'AIPCU OR HMI';

  BomCalculationResult? _result;

  @override
  void initState() {
    super.initState();
    _calculateBOM();
  }

  @override
  void dispose() {
    _currentController.dispose();
    super.dispose();
  }

  void _calculateBOM() {
    final currentVal = double.tryParse(_currentController.text.trim()) ?? 15.0;

    setState(() {
      _result = BomCalculationEngine.calculateBom(
        pumpCurrent: currentVal,
        numPumps: _numPumps,
        numVfd: _numVfd,
        mainIncomerRequired: _mainIncomer,
        doorMountSwitchRequired: _doorMountSwitch,
        panelSizeLevel: _panelSizeLevel,
        olrRequired: _olrRequired,
        indicatorLightRequired: _indicatorLight,
        controllerType: _controllerType,
      );
    });
  }

  void _showExportDialog() {
    if (_result == null) return;
    final buffer = StringBuffer();
    buffer.writeln('--- BILL OF MATERIALS (BOM) ---');
    buffer.writeln(
        'HP: ${_result!.pumpHp.toStringAsFixed(2)} HP | Total Current: ${_result!.totalPanelCurrent} A');
    buffer.writeln(
        '------------------------------------------------------------');
    for (final item in _result!.items) {
      buffer.writeln(
          '${item.qty}x ${item.itemName} (${item.capacity}) - DP: ₹${item.dp.toStringAsFixed(2)} | Total: ₹${item.totalDp.toStringAsFixed(2)}');
    }
    buffer.writeln(
        '------------------------------------------------------------');
    buffer.writeln(
        'Material Total: ₹${_result!.totalMaterialCost.toStringAsFixed(2)}');
    buffer.writeln('Labor Cost: ₹${_result!.laborCost.toStringAsFixed(2)}');
    buffer.writeln('Grand Total: ₹${_result!.grandTotal.toStringAsFixed(2)}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export BOM Breakdown'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              buffer.toString(),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2F5D9F),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('BOM copied to clipboard!')),
              );
            },
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Copy All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Specifications Card
        Card(
          color: Colors.white,
          child: ExpansionTile(
            initiallyExpanded: true,
            shape: const Border(),
            title: const Text(
              'Calculator Inputs (Yellow Section)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    TextField(
                      controller: _currentController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Pump Current (Amperes)',
                        prefixIcon: Icon(Icons.bolt_rounded),
                      ),
                      onChanged: (_) => _calculateBOM(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: _numPumps,
                            decoration: const InputDecoration(
                              labelText: 'Pumps',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                            items: [1, 2, 3, 4, 5]
                                .map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Text('$p Pumps'),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              setState(() => _numPumps = v!);
                              _calculateBOM();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: _numVfd,
                            decoration: const InputDecoration(
                              labelText: 'VFDs',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                            items: [0, 1, 2, 3, 4]
                                .map((v) => DropdownMenuItem(
                                      value: v,
                                      child: Text('$v VFD'),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              setState(() => _numVfd = v!);
                              _calculateBOM();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: _panelSizeLevel,
                            decoration: const InputDecoration(
                              labelText: 'Size Level (1-5)',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                            items: [1, 2, 3, 4, 5]
                                .map((l) => DropdownMenuItem(
                                      value: l,
                                      child: Text('Level $l'),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              setState(() => _panelSizeLevel = v!);
                              _calculateBOM();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _controllerType,
                            decoration: const InputDecoration(
                              labelText: 'Controller',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'AIPCU OR HMI',
                                child: Text('HMI Display'),
                              ),
                              DropdownMenuItem(
                                value: 'Standard DLC',
                                child: Text('Standard DLC'),
                              ),
                            ],
                            onChanged: (v) {
                              setState(() => _controllerType = v!);
                              _calculateBOM();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      dense: true,
                      title: const Text('Main Incomer Switch Required'),
                      value: _mainIncomer,
                      onChanged: (v) {
                        setState(() => _mainIncomer = v);
                        _calculateBOM();
                      },
                    ),
                    SwitchListTile(
                      dense: true,
                      title: const Text('3-Pole Door Mount Switch'),
                      value: _doorMountSwitch,
                      onChanged: (v) {
                        setState(() => _doorMountSwitch = v);
                        _calculateBOM();
                      },
                    ),
                    SwitchListTile(
                      dense: true,
                      title: const Text('Overload Relay (OLR)'),
                      value: _olrRequired,
                      onChanged: (v) {
                        setState(() => _olrRequired = v);
                        _calculateBOM();
                      },
                    ),
                    SwitchListTile(
                      dense: true,
                      title: const Text('Indicator Lights (R-Y-B)'),
                      value: _indicatorLight,
                      onChanged: (v) {
                        setState(() => _indicatorLight = v);
                        _calculateBOM();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Grand Total Summary Card
        if (_result != null) _buildSummaryCard(),

        const SizedBox(height: 14),

        // Material Items Header & Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Material Breakdown (${_result?.items.length ?? 0} components)',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              onPressed: _showExportDialog,
              icon: const Icon(Icons.share_outlined, size: 16),
              label: const Text('Export'),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // BOM Items List
        if (_result != null)
          ..._result!.items.map((item) => _buildBomItemCard(item)),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final r = _result!;
    return Card(
      color: const Color(0xFF1F3B66),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grand Total Cost',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '₹${r.grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${r.pumpHp.toStringAsFixed(2)} HP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${r.totalPanelCurrent}A Load',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _costSubItem(
                    'Material DP Total', '₹${r.totalMaterialCost.toStringAsFixed(2)}'),
                _costSubItem(
                    'Labor & Assembly', '₹${r.laborCost.toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _costSubItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildBomItemCard(BomItem item) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2F5D9F).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${item.qty}x',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F5D9F),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Cap: ${item.capacity}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${item.totalDp.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  '@ ₹${item.dp.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
