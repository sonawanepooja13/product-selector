import 'package:flutter/material.dart';
import '../../models/product_configuration.dart';
import '../../services/product_catalog_service.dart';

class PriceListCatalogTab extends StatefulWidget {
  const PriceListCatalogTab({super.key});

  @override
  State<PriceListCatalogTab> createState() => _PriceListCatalogTabState();
}

class _PriceListCatalogTabState extends State<PriceListCatalogTab> {
  final ProductCatalogService _catalogService = ProductCatalogService();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Controller',
    'VFD',
    'MCB',
    'MCCB',
    'CONTACTOR',
    'OLR',
    'switch',
    'POWER SUPPLY',
    'FAN',
    'INDICATOR',
  ];

  List<CatalogItem> get _filteredItems {
    return _catalogService.catalogItems.where((item) {
      final matchesSearch = item.itemName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.capacity.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _openAddItemDialog() {
    final catController = TextEditingController(text: 'CONTACTOR');
    final subCatController = TextEditingController(text: '3 POLE');
    final nameController = TextEditingController();
    final capController = TextEditingController(text: '18');
    final dpController = TextEditingController(text: '1200');

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Component to Price List',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Appends a new equipment row to price_list_clean.csv catalog.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: catController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subCatController,
                  decoration: const InputDecoration(labelText: 'Sub Category'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'e.g. POWER CONTACTOR 3P 18A',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: capController,
                        decoration:
                            const InputDecoration(labelText: 'Capacity (Rating)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: dpController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Dealer Price (₹ DP)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2F5D9F),
                    ),
                    onPressed: () {
                      final name = nameController.text.trim();
                      final dp = double.tryParse(dpController.text.trim());
                      if (name.isEmpty || dp == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter valid item name and price.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      _catalogService.addCatalogItem(CatalogItem(
                        category: catController.text.trim(),
                        subCategory: subCatController.text.trim(),
                        itemName: name,
                        capacity: capController.text.trim(),
                        dp: dp,
                      ));

                      Navigator.pop(ctx);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added $name to catalog!')),
                      );
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Save to Catalog'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredItems;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddItemDialog,
        backgroundColor: const Color(0xFF2F5D9F),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Component'),
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBar(
              hintText: 'Search category, item or rating...',
              leading: const Icon(Icons.search_rounded, size: 20),
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: const WidgetStatePropertyAll(Colors.white),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // Horizontal Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(cat),
                    selectedColor:
                        const Color(0xFF2F5D9F).withValues(alpha: 0.15),
                    checkmarkColor: const Color(0xFF2F5D9F),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFF2F5D9F)
                          : Colors.grey.shade700,
                    ),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Catalog List
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No components found',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return Card(
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF2F5D9F)
                                .withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.precision_manufacturing_rounded,
                              color: Color(0xFF2F5D9F),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            item.itemName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${item.category} • Cap: ${item.capacity}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                          trailing: Text(
                            '₹${item.dp.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2F5D9F),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
