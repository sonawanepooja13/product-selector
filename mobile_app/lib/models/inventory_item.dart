class InventoryItem {
  final String sku;
  final String itemName;
  final String category;
  final int currentStock;
  final int minStockLevel;
  final double unitPrice;
  final String binLocation;

  const InventoryItem({
    required this.sku,
    required this.itemName,
    required this.category,
    required this.currentStock,
    required this.minStockLevel,
    required this.unitPrice,
    required this.binLocation,
  });

  bool get isLowStock => currentStock <= minStockLevel;

  InventoryItem copyWith({
    String? sku,
    String? itemName,
    String? category,
    int? currentStock,
    int? minStockLevel,
    double? unitPrice,
    String? binLocation,
  }) {
    return InventoryItem(
      sku: sku ?? this.sku,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      currentStock: currentStock ?? this.currentStock,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      unitPrice: unitPrice ?? this.unitPrice,
      binLocation: binLocation ?? this.binLocation,
    );
  }
}
