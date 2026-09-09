import 'package:flutter/foundation.dart';
import '../models/inventory_item.dart';

class WarehouseService extends ChangeNotifier {
  static final WarehouseService _instance = WarehouseService._internal();
  factory WarehouseService() => _instance;

  WarehouseService._internal() {
    _initInventory();
  }

  final List<InventoryItem> _inventory = [];
  List<InventoryItem> get inventory => List.unmodifiable(_inventory);

  void _initInventory() {
    _inventory.addAll([
      const InventoryItem(
        sku: 'VFD-415V-15HP',
        itemName: 'VFD 15HP 3-Phase 415V Drive',
        category: 'VFD Drives',
        currentStock: 4,
        minStockLevel: 5,
        unitPrice: 31000,
        binLocation: 'Rack A-12',
      ),
      const InventoryItem(
        sku: 'MCB-3P-63A',
        itemName: 'MCB 3 Pole 63A C-Curve 10kA',
        category: 'Circuit Breakers',
        currentStock: 35,
        minStockLevel: 10,
        unitPrice: 990,
        binLocation: 'Bin B-04',
      ),
      const InventoryItem(
        sku: 'SMPS-24V-2.5A',
        itemName: 'Power Supply SMPS 24V 2.5A',
        category: 'Power Supply',
        currentStock: 2,
        minStockLevel: 8,
        unitPrice: 1250,
        binLocation: 'Shelf C-01',
      ),
      const InventoryItem(
        sku: 'CON-3P-25A',
        itemName: 'Power Contactor 3P 25A 24V Coiled',
        category: 'Contactors',
        currentStock: 18,
        minStockLevel: 6,
        unitPrice: 1450,
        binLocation: 'Rack B-08',
      ),
    ]);
  }

  List<InventoryItem> get lowStockItems =>
      _inventory.where((item) => item.isLowStock).toList();

  void adjustStock(String sku, int delta) {
    final idx = _inventory.indexWhere((item) => item.sku == sku);
    if (idx != -1) {
      final current = _inventory[idx];
      final newQty = (current.currentStock + delta).clamp(0, 99999);
      _inventory[idx] = current.copyWith(currentStock: newQty);
      notifyListeners();
    }
  }
}
