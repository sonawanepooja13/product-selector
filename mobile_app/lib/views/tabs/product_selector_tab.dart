import 'package:flutter/material.dart';
import '../../models/product_configuration.dart';
import '../../services/product_catalog_service.dart';

class ProductSelectorTab extends StatefulWidget {
  final VoidCallback onNavigateToBOM;

  const ProductSelectorTab({super.key, required this.onNavigateToBOM});

  @override
  State<ProductSelectorTab> createState() => _ProductSelectorTabState();
}

class _ProductSelectorTabState extends State<ProductSelectorTab> {
  final ProductCatalogService _catalogService = ProductCatalogService();

  late Customer _selectedCustomer;
  final TextEditingController _currentController =
      TextEditingController(text: '10.0');

  int _numPumps = 2;
  int _numVfd = 1;
  String _bypass = 'With Bypass';
  String _panelType = 'Indoor';
  String _panelSize = '600x400';
  String _panelClass = 'Industrial';
  String _mainIncomer = 'Yes';
  String _olrRequired = 'Yes';
  String _indicatorLight = 'Yes';

  ProductSearchResult? _searchResult;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomer = _catalogService.customers.first;
  }

  @override
  void dispose() {
    _currentController.dispose();
    super.dispose();
  }

  void _searchPrice() {
    final currentVal = double.tryParse(_currentController.text.trim());
    if (currentVal == null || currentVal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Pump Current (Amperes).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final query = ProductConfiguration(
      pumpCurrent: currentVal,
      numPumps: _numPumps,
      numVfd: _numVfd,
      bypass: _bypass,
      panelType: _panelType,
      panelSize: _panelSize,
      panelClass: _panelClass,
      mainIncomer: _mainIncomer,
      olrRequired: _olrRequired,
      indicatorLight: _indicatorLight,
      price: 0.0,
    );

    setState(() {
      _hasSearched = true;
      _searchResult = _catalogService.searchPrice(query, _selectedCustomer);
    });
  }

  void _openAddCustomerSheet() {
    final nameController = TextEditingController();
    final percentController = TextEditingController(text: '0.0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Customer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Register client profile and special price percentage.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  hintText: 'e.g. Apex Industrial Works',
                  prefixIcon: Icon(Icons.business_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: percentController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price Adjustment (%)',
                  hintText: 'e.g. 10 for +10%, -5 for 5% discount',
                  prefixIcon: Icon(Icons.percent_rounded),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2F5D9F),
                  ),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final pct = double.tryParse(percentController.text.trim());
                    if (name.isEmpty || pct == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill valid customer details.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final newCust = Customer(name: name, percentage: pct);
                    _catalogService.addCustomer(newCust);
                    setState(() => _selectedCustomer = newCust);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added customer $name')),
                    );
                  },
                  child: const Text('Save Customer'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openAddNewPriceDialog() {
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Configuration Price'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuration not in database:\n'
                '$_numPumps Pumps, $_numVfd VFD, ${_currentController.text}A, $_panelSize',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Base Price (₹)',
                  hintText: 'e.g. 145000',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2F5D9F),
              ),
              onPressed: () {
                final price = double.tryParse(priceController.text.trim());
                if (price == null || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid numeric price.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final currentVal =
                    double.tryParse(_currentController.text.trim()) ?? 10.0;
                final newProd = ProductConfiguration(
                  pumpCurrent: currentVal,
                  numPumps: _numPumps,
                  numVfd: _numVfd,
                  bypass: _bypass,
                  panelType: _panelType,
                  panelSize: _panelSize,
                  panelClass: _panelClass,
                  mainIncomer: _mainIncomer,
                  olrRequired: _olrRequired,
                  indicatorLight: _indicatorLight,
                  price: price,
                );

                _catalogService.addProduct(newProd);
                Navigator.pop(ctx);
                _searchPrice();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New product price saved!')),
                );
              },
              child: const Text('Save Price'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Customer Selector Bar
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Target Customer & Discount',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: const Color(0xFF2F5D9F),
                      ),
                      onPressed: _openAddCustomerSheet,
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                      label: const Text('New Client'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Customer>(
                  initialValue: _selectedCustomer,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.account_circle_outlined),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: _catalogService.customers.map((c) {
                    final sign = c.percentage >= 0 ? '+' : '';
                    return DropdownMenuItem<Customer>(
                      value: c,
                      child: Text(
                        '${c.name} ($sign${c.percentage}%)',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCustomer = val;
                        if (_hasSearched) _searchPrice();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Product Parameter Configurator Card
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Booster Panel Specifications',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),

                // Pump Current (A)
                TextField(
                  controller: _currentController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Pump Current (Amperes)',
                    hintText: 'e.g. 10.0 or 15.0',
                    prefixIcon: Icon(Icons.bolt_rounded),
                  ),
                ),
                const SizedBox(height: 14),

                // Number of Pumps
                _labelWithTag('Number of Pumps', '$_numPumps'),
                const SizedBox(height: 6),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 1, label: Text('1')),
                    ButtonSegment(value: 2, label: Text('2')),
                    ButtonSegment(value: 3, label: Text('3')),
                    ButtonSegment(value: 4, label: Text('4')),
                    ButtonSegment(value: 5, label: Text('5')),
                  ],
                  selected: {_numPumps},
                  onSelectionChanged: (set) =>
                      setState(() => _numPumps = set.first),
                ),
                const SizedBox(height: 14),

                // Number of VFD
                _labelWithTag('Number of VFD Drives', '$_numVfd'),
                const SizedBox(height: 6),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('0')),
                    ButtonSegment(value: 1, label: Text('1')),
                    ButtonSegment(value: 2, label: Text('2')),
                    ButtonSegment(value: 3, label: Text('3')),
                    ButtonSegment(value: 4, label: Text('4')),
                  ],
                  selected: {_numVfd},
                  onSelectionChanged: (set) =>
                      setState(() => _numVfd = set.first),
                ),
                const SizedBox(height: 14),

                // Bypass Option
                _dropdownField(
                  label: 'Bypass Arrangement',
                  value: _bypass,
                  items: const ['With Bypass', 'Without Bypass'],
                  onChanged: (v) => setState(() => _bypass = v!),
                ),
                const SizedBox(height: 12),

                // Panel Type & Class in Row
                Row(
                  children: [
                    Expanded(
                      child: _dropdownField(
                        label: 'Panel Type',
                        value: _panelType,
                        items: const ['Indoor', 'Outdoor'],
                        onChanged: (v) => setState(() => _panelType = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dropdownField(
                        label: 'Panel Class',
                        value: _panelClass,
                        items: const ['Industrial', 'Domestic'],
                        onChanged: (v) => setState(() => _panelClass = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Panel Size
                _dropdownField(
                  label: 'Panel Size Dimension',
                  value: _panelSize,
                  items: const [
                    '400x300',
                    '600x400',
                    '800x600',
                    '1000x800',
                    '1200x800'
                  ],
                  onChanged: (v) => setState(() => _panelSize = v!),
                ),
                const SizedBox(height: 12),

                // Main Incomer, OLR, Indicator Light
                Row(
                  children: [
                    Expanded(
                      child: _dropdownField(
                        label: 'Incomer',
                        value: _mainIncomer,
                        items: const ['Yes', 'No'],
                        onChanged: (v) => setState(() => _mainIncomer = v!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _dropdownField(
                        label: 'OLR Relay',
                        value: _olrRequired,
                        items: const ['Yes', 'No'],
                        onChanged: (v) => setState(() => _olrRequired = v!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _dropdownField(
                        label: 'Ind. Light',
                        value: _indicatorLight,
                        items: const ['Yes', 'No'],
                        onChanged: (v) => setState(() => _indicatorLight = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Actions
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2F5D9F),
                    ),
                    onPressed: _searchPrice,
                    icon: const Icon(Icons.search_rounded),
                    label: const Text(
                      'Search Product Price',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: widget.onNavigateToBOM,
                    icon: const Icon(Icons.calculate_outlined),
                    label: const Text('Open Material & Labor Calculator ->'),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Result Card
        if (_hasSearched && _searchResult != null) _buildResultCard(),
      ],
    );
  }

  Widget _buildResultCard() {
    final res = _searchResult!;
    if (res.isFound) {
      final sign = res.customerAdjustmentPercent >= 0 ? '+' : '';
      return Card(
        color: Colors.green.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.green.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Price Found in Catalog',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      res.matchedDetails ?? 'Matched',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade900,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Final Price: ₹${res.finalPrice!.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '(Base Price: ₹${res.basePrice!.toStringAsFixed(2)} | Customer Adj: $sign${res.customerAdjustmentPercent}%)',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        color: Colors.red.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Product Does Not Exist',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'This specific pump panel configuration was not found in the price list database.',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 14),
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red.shade800,
                ),
                onPressed: _openAddNewPriceDialog,
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text('Add Base Price for this Config'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _labelWithTag(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF2F5D9F).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFF2F5D9F),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: items
          .map((i) => DropdownMenuItem(
                value: i,
                child: Text(i,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
