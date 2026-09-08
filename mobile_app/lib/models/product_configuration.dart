class ProductConfiguration {
  final double pumpCurrent;
  final int numPumps;
  final int numVfd;
  final String bypass; // "With Bypass", "Without Bypass"
  final String panelType; // "Indoor", "Outdoor"
  final String panelSize; // "400x300", "600x400", "800x600", "1000x800", "1200x800"
  final String panelClass; // "Industrial", "Domestic"
  final String mainIncomer; // "Yes", "No"
  final String olrRequired; // "Yes", "No"
  final String indicatorLight; // "Yes", "No"
  final double price;

  const ProductConfiguration({
    required this.pumpCurrent,
    required this.numPumps,
    required this.numVfd,
    required this.bypass,
    required this.panelType,
    required this.panelSize,
    required this.panelClass,
    required this.mainIncomer,
    required this.olrRequired,
    required this.indicatorLight,
    required this.price,
  });

  ProductConfiguration copyWith({
    double? pumpCurrent,
    int? numPumps,
    int? numVfd,
    String? bypass,
    String? panelType,
    String? panelSize,
    String? panelClass,
    String? mainIncomer,
    String? olrRequired,
    String? indicatorLight,
    double? price,
  }) {
    return ProductConfiguration(
      pumpCurrent: pumpCurrent ?? this.pumpCurrent,
      numPumps: numPumps ?? this.numPumps,
      numVfd: numVfd ?? this.numVfd,
      bypass: bypass ?? this.bypass,
      panelType: panelType ?? this.panelType,
      panelSize: panelSize ?? this.panelSize,
      panelClass: panelClass ?? this.panelClass,
      mainIncomer: mainIncomer ?? this.mainIncomer,
      olrRequired: olrRequired ?? this.olrRequired,
      indicatorLight: indicatorLight ?? this.indicatorLight,
      price: price ?? this.price,
    );
  }
}

class Customer {
  final String name;
  final double percentage; // e.g. 10.0 for +10% markup, -5.0 for 5% discount

  const Customer({
    required this.name,
    required this.percentage,
  });
}

class CatalogItem {
  final String category;
  final String subCategory;
  final String itemName;
  final String capacity;
  final String unit;
  final String supplier;
  final double listPrice;
  final double discount;
  final double dp; // Dealer Price

  const CatalogItem({
    required this.category,
    required this.subCategory,
    required this.itemName,
    required this.capacity,
    this.unit = 'Nos',
    this.supplier = 'Saark Exploration Pvt Ltd',
    this.listPrice = 0.0,
    this.discount = 0.0,
    required this.dp,
  });
}

class BomItem {
  final String itemName;
  final String category;
  final String subCategory;
  final String capacity;
  final int qty;
  final double dp;

  const BomItem({
    required this.itemName,
    required this.category,
    required this.subCategory,
    required this.capacity,
    required this.qty,
    required this.dp,
  });

  double get totalDp => qty * dp;
}
