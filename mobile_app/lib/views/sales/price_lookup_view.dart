import 'package:flutter/material.dart';
import '../../services/bom_calculation_engine.dart';
import '../widgets/mobile_header.dart';
import 'material_calculator_view.dart';

class PriceLookupView extends StatefulWidget {
  final String category;

  const PriceLookupView({
    super.key,
    required this.category,
  });

  @override
  State<PriceLookupView> createState() => _PriceLookupViewState();
}

class _PriceLookupViewState extends State<PriceLookupView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form parameters matching price_tab.py
  double _pumpHp = 5.0; // HP
  int _numPumps = 2; // 1 - 6
  int _numVfd = 1; // 0 - 6
  bool _mainIncomer = true;
  bool _doorSwitch = true;
  bool _olrRequired = true;
  bool _indicatorLights = true;
  double _discountPercent = 10.0;
  double _marginPercent = 15.0;

  BomCalculationResult? _result;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _recalculate();
  }

  void _recalculate() {
    // Current estimate: Current = HP / 0.625
    final pumpCurrent = _pumpHp / 0.625;

    final result = BomCalculationEngine.calculateBom(
      pumpCurrent: pumpCurrent,
      numPumps: _numPumps,
      numVfd: _numVfd,
      mainIncomerRequired: _mainIncomer,
      doorMountSwitchRequired: _doorSwitch,
      panelSizeLevel: 3,
      olrRequired: _olrRequired,
      indicatorLightRequired: _indicatorLights,
    );

    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final netMaterial = (_result?.totalMaterialCost ?? 0.0) *
        (1 - (_discountPercent / 100)) *
        (1 + (_marginPercent / 100));
    final netTotal = netMaterial + (_result?.laborCost ?? 0.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: MobileHeader(
        title: widget.category,
        subtitle: 'Price List Search & BOM Engine',
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF2F5D9F),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF2F5D9F),
              tabs: const [
                Tab(text: 'Price Configurator'),
                Tab(text: 'BOM Itemized Sheet'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildConfiguratorTab(netTotal),
                _buildBomSheetTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Net Estimated Price:',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  Text(
                    '₹${netTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F5D9F),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MaterialCalculatorTab(),
                  ),
                );
              },
              icon: const Icon(Icons.calculate_rounded),
              label: const Text('Material Calc'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F5D9F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfiguratorTab(double netTotal) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Parameters Card
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Panel Technical Specs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),

                // HP Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pump HP Capacity:'),
                    Chip(
                      label: Text('${_pumpHp.toStringAsFixed(1)} HP'),
                      backgroundColor: Colors.blue.shade50,
                    ),
                  ],
                ),
                Slider(
                  value: _pumpHp,
                  min: 0.5,
                  max: 50.0,
                  divisions: 99,
                  activeColor: const Color(0xFF2F5D9F),
                  onChanged: (val) {
                    setState(() => _pumpHp = val);
                    _recalculate();
                  },
                ),

                const Divider(),

                // Pump Count Stepper
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Number of Pumps:'),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _numPumps > 1
                              ? () {
                                  setState(() => _numPumps--);
                                  _recalculate();
                                }
                              : null,
                        ),
                        Text('$_numPumps',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: _numPumps < 6
                              ? () {
                                  setState(() => _numPumps++);
                                  _recalculate();
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),

                // VFD Stepper
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Number of VFD Drives:'),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _numVfd > 0
                              ? () {
                                  setState(() => _numVfd--);
                                  _recalculate();
                                }
                              : null,
                        ),
                        Text('$_numVfd',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: _numVfd < _numPumps
                              ? () {
                                  setState(() => _numVfd++);
                                  _recalculate();
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),

                const Divider(),

                SwitchListTile(
                  title: const Text('Main Incomer Switch'),
                  value: _mainIncomer,
                  onChanged: (val) {
                    setState(() => _mainIncomer = val);
                    _recalculate();
                  },
                ),
                SwitchListTile(
                  title: const Text('Door Mount Rotary Switch'),
                  value: _doorSwitch,
                  onChanged: (val) {
                    setState(() => _doorSwitch = val);
                    _recalculate();
                  },
                ),
                SwitchListTile(
                  title: const Text('Thermal Overload Relay (OLR)'),
                  value: _olrRequired,
                  onChanged: (val) {
                    setState(() => _olrRequired = val);
                    _recalculate();
                  },
                ),
                SwitchListTile(
                  title: const Text('Phase LED Indicator Lights'),
                  value: _indicatorLights,
                  onChanged: (val) {
                    setState(() => _indicatorLights = val);
                    _recalculate();
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Commercials Card
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Commercial Discounts & Margin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Discount: ${_discountPercent.toInt()}%'),
                    Text('Margin: ${_marginPercent.toInt()}%'),
                  ],
                ),
                Slider(
                  value: _discountPercent,
                  min: 0,
                  max: 30,
                  divisions: 30,
                  label: '${_discountPercent.toInt()}% Discount',
                  onChanged: (val) => setState(() => _discountPercent = val),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBomSheetTab() {
    final items = _result?.items ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 0.5,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(item.itemName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('Category: ${item.category} • Capacity: ${item.capacity}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Qty: ${item.qty}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('₹${item.totalDp.toStringAsFixed(0)}',
                    style: const TextStyle(color: Color(0xFF2F5D9F), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }
}
