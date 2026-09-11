class ProductConfiguration {
  final int? id;
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
  final String category;

  const ProductConfiguration({
    this.id,
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
    this.category = 'Booster Pump Control Panel',
  });

  ProductConfiguration copyWith({
    int? id,
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
    String? category,
  }) {
    return ProductConfiguration(
      id: id ?? this.id,
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
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'pump_current': pumpCurrent,
      'num_pumps': numPumps,
      'num_vfd': numVfd,
      'bypass': bypass,
      'panel_type': panelType,
      'panel_size': panelSize,
      'panel_class': panelClass,
      'main_incomer': mainIncomer,
      'olr_required': olrRequired,
      'indicator_light': indicatorLight,
      'price': price,
      'category': category,
    };
  }

  factory ProductConfiguration.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v, double fallback) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? fallback;
      return fallback;
    }

    int toInt(dynamic v, int fallback) {
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    return ProductConfiguration(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      pumpCurrent: toDouble(json['pump_current'], 0.0),
      numPumps: toInt(json['num_pumps'], 1),
      numVfd: toInt(json['num_vfd'], 0),
      bypass: json['bypass']?.toString() ?? 'Without Bypass',
      panelType: json['panel_type']?.toString() ?? 'Indoor',
      panelSize: json['panel_size']?.toString() ?? '400x300',
      panelClass: json['panel_class']?.toString() ?? 'Industrial',
      mainIncomer: json['main_incomer']?.toString() ?? 'Yes',
      olrRequired: json['olr_required']?.toString() ?? 'Yes',
      indicatorLight: json['indicator_light']?.toString() ?? 'Yes',
      price: toDouble(json['price'], 0.0),
      category: json['category']?.toString() ?? 'Booster Pump Control Panel',
    );
  }
}

class Customer {
  final int? id;
  final String name;
  final double percentage; // e.g. 10.0 for +10% markup, -5.0 for 5% discount
  final String? contactNumber;
  final String? email;
  final String? category;

  const Customer({
    this.id,
    required this.name,
    required this.percentage,
    this.contactNumber,
    this.email,
    this.category = 'Standard',
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'percentage': percentage,
      'contact_number': contactNumber ?? '',
      'email': email ?? '',
      'category': category ?? 'Standard',
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v, double fallback) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? fallback;
      return fallback;
    }

    return Customer(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      percentage: toDouble(json['percentage'], 0.0),
      contactNumber: json['contact_number']?.toString(),
      email: json['email']?.toString(),
      category: json['category']?.toString() ?? 'Standard',
    );
  }
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
