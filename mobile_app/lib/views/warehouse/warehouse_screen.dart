import 'package:flutter/material.dart';
import '../../models/inventory_item.dart';
import '../../services/warehouse_service.dart';
import '../widgets/mobile_header.dart';

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({super.key});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  final WarehouseService _service = WarehouseService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _service,
      builder: (context, _) {
        final items = _service.inventory.where((item) {
          if (_searchQuery.isEmpty) return true;
          return item.itemName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.sku.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        final lowStockCount = _service.lowStockItems.length;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F9),
          appBar: const MobileHeader(
            title: 'Stores & Warehouse',
            subtitle: 'Inventory Stock & Reorder Levels',
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (lowStockCount > 0)
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.amber.shade900, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '$lowStockCount Item(s) below minimum stock threshold! Reorder required.',
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  hintText: 'Search SKU or component name...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 16),

              ...items.map((item) => Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.itemName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                              if (item.isLowStock)
                                Chip(
                                  label: const Text('LOW STOCK',
                                      style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red)),
                                  backgroundColor: Colors.red.shade50,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'SKU: ${item.sku} • Bin: ${item.binLocation}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'In Stock: ${item.currentStock} Units (Min: ${item.minStockLevel})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: item.isLowStock
                                      ? Colors.red
                                      : Colors.grey.shade800,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _service.adjustStock(item.sku, -1),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline,
                                        color: Colors.green),
                                    onPressed: () =>
                                        _service.adjustStock(item.sku, 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
