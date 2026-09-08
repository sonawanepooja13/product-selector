import '../models/product_configuration.dart';

class BomCalculationResult {
  final List<BomItem> items;
  final double pumpHp;
  final double totalPanelCurrent;
  final double totalMaterialCost;
  final double laborCost;
  final double grandTotal;

  const BomCalculationResult({
    required this.items,
    required this.pumpHp,
    required this.totalPanelCurrent,
    required this.totalMaterialCost,
    required this.laborCost,
    required this.grandTotal,
  });
}

class BomCalculationEngine {
  // Built-in component pricing catalog (matching price_list_clean.csv values)
  static final List<CatalogItem> defaultCatalog = [
    // Controllers
    const CatalogItem(
      category: 'Controller',
      subCategory: '1',
      itemName: 'AI-PCU02 WITH HMI DISPLAY',
      capacity: '1',
      dp: 25000,
    ),
    const CatalogItem(
      category: 'Controller',
      subCategory: '2',
      itemName: 'AI-PCU02 CONTROLLER STANDARD',
      capacity: '2',
      dp: 19500,
    ),

    // Power Supplies
    const CatalogItem(
      category: 'POWER SUPPLY',
      subCategory: '1',
      itemName: 'SMPS POWER SUPPLY 24V 2.5A',
      capacity: '24V',
      dp: 1250,
    ),

    // Switches - Load Breaker
    const CatalogItem(
      category: 'switch',
      subCategory: 'LOAD BREAKER',
      itemName: 'LOAD BREAKER SWITCH 25A 3P',
      capacity: '25',
      dp: 720,
    ),
    const CatalogItem(
      category: 'switch',
      subCategory: 'LOAD BREAKER',
      itemName: 'LOAD BREAKER SWITCH 40A 3P',
      capacity: '40',
      dp: 950,
    ),
    const CatalogItem(
      category: 'switch',
      subCategory: 'LOAD BREAKER',
      itemName: 'LOAD BREAKER SWITCH 63A 3P',
      capacity: '63',
      dp: 1450,
    ),

    // Door Mount Switches
    const CatalogItem(
      category: 'switch',
      subCategory: 'DOOR MOUNT',
      itemName: '3 POLE SWITCH DOOR MOUNT (YELLOW) 32A',
      capacity: '32',
      dp: 680,
    ),
    const CatalogItem(
      category: 'switch',
      subCategory: 'DOOR MOUNT',
      itemName: '3 POLE SWITCH DOOR MOUNT (YELLOW) 63A',
      capacity: '63',
      dp: 1150,
    ),

    // MCB 3P
    const CatalogItem(
      category: 'MCB',
      subCategory: '3P',
      itemName: 'MCB 3 POLE 16A C-CURVE 10KA',
      capacity: '16',
      dp: 450,
    ),
    const CatalogItem(
      category: 'MCB',
      subCategory: '3P',
      itemName: 'MCB 3 POLE 25A C-CURVE 10KA',
      capacity: '25',
      dp: 520,
    ),
    const CatalogItem(
      category: 'MCB',
      subCategory: '3P',
      itemName: 'MCB 3 POLE 32A C-CURVE 10KA',
      capacity: '32',
      dp: 610,
    ),
    const CatalogItem(
      category: 'MCB',
      subCategory: '3P',
      itemName: 'MCB 3 POLE 40A C-CURVE 10KA',
      capacity: '40',
      dp: 780,
    ),
    const CatalogItem(
      category: 'MCB',
      subCategory: '3P',
      itemName: 'MCB 3 POLE 63A C-CURVE 10KA',
      capacity: '63',
      dp: 990,
    ),

    // MCCB 3P
    const CatalogItem(
      category: 'MCCB',
      subCategory: 'MCCB 3P',
      itemName: 'MCCB 3 POLE 100A 16KA',
      capacity: '100',
      dp: 3800,
    ),
    const CatalogItem(
      category: 'MCCB',
      subCategory: 'MCCB 3P',
      itemName: 'MCCB 3 POLE 160A 25KA',
      capacity: '160',
      dp: 5600,
    ),

    // VFD Drives
    const CatalogItem(
      category: 'VFD',
      subCategory: 'VFD 3 PHASE',
      itemName: 'VARIABLE FREQUENCY DRIVE 3HP 415V',
      capacity: '3',
      dp: 11500,
    ),
    const CatalogItem(
      category: 'VFD',
      subCategory: 'VFD 3 PHASE',
      itemName: 'VARIABLE FREQUENCY DRIVE 5HP 415V',
      capacity: '5',
      dp: 14200,
    ),
    const CatalogItem(
      category: 'VFD',
      subCategory: 'VFD 3 PHASE',
      itemName: 'VARIABLE FREQUENCY DRIVE 7.5HP 415V',
      capacity: '7.5',
      dp: 18500,
    ),
    const CatalogItem(
      category: 'VFD',
      subCategory: 'VFD 3 PHASE',
      itemName: 'VARIABLE FREQUENCY DRIVE 10HP 415V',
      capacity: '10',
      dp: 23000,
    ),
    const CatalogItem(
      category: 'VFD',
      subCategory: 'VFD 3 PHASE',
      itemName: 'VARIABLE FREQUENCY DRIVE 15HP 415V',
      capacity: '15',
      dp: 31000,
    ),

    // Contactors 3 Pole
    const CatalogItem(
      category: 'CONTACTOR',
      subCategory: '3 POLE',
      itemName: 'POWER CONTACTOR 3 POLE 9A (24V/220V)',
      capacity: '9',
      dp: 720,
    ),
    const CatalogItem(
      category: 'CONTACTOR',
      subCategory: '3 POLE',
      itemName: 'POWER CONTACTOR 3 POLE 12A (24V/220V)',
      capacity: '12',
      dp: 860,
    ),
    const CatalogItem(
      category: 'CONTACTOR',
      subCategory: '3 POLE',
      itemName: 'POWER CONTACTOR 3 POLE 18A (24V/220V)',
      capacity: '18',
      dp: 1120,
    ),
    const CatalogItem(
      category: 'CONTACTOR',
      subCategory: '3 POLE',
      itemName: 'POWER CONTACTOR 3 POLE 25A (24V/220V)',
      capacity: '25',
      dp: 1450,
    ),
    const CatalogItem(
      category: 'CONTACTOR',
      subCategory: '3 POLE',
      itemName: 'POWER CONTACTOR 3 POLE 32A (24V/220V)',
      capacity: '32',
      dp: 1980,
    ),
    const CatalogItem(
      category: 'CONTACTOR',
      subCategory: '3 POLE',
      itemName: 'POWER CONTACTOR 3 POLE 40A (24V/220V)',
      capacity: '40',
      dp: 2450,
    ),

    // Overload Relays (OLR)
    const CatalogItem(
      category: 'OLR',
      subCategory: 'THERMAL',
      itemName: 'THERMAL OVERLOAD RELAY 9-13A',
      capacity: '13',
      dp: 680,
    ),
    const CatalogItem(
      category: 'OLR',
      subCategory: 'THERMAL',
      itemName: 'THERMAL OVERLOAD RELAY 12-18A',
      capacity: '18',
      dp: 790,
    ),
    const CatalogItem(
      category: 'OLR',
      subCategory: 'THERMAL',
      itemName: 'THERMAL OVERLOAD RELAY 17-25A',
      capacity: '25',
      dp: 920,
    ),

    // Fan & Filter
    const CatalogItem(
      category: 'FAN',
      subCategory: 'COOLING',
      itemName: 'PANEL COOLING AXIAL FAN 120MM 230VAC',
      capacity: '120MM',
      dp: 450,
    ),
    const CatalogItem(
      category: 'FILTER',
      subCategory: 'FAN FILTER',
      itemName: 'DUST FILTER ASSEMBLY WITH LOUVER 120MM',
      capacity: '120MM',
      dp: 280,
    ),

    // Indicator Lights
    const CatalogItem(
      category: 'INDICATOR',
      subCategory: 'LED',
      itemName: 'LED PILOT INDICATOR LIGHT 22MM 24V/230V',
      capacity: '22MM',
      dp: 85,
    ),
  ];

  static CatalogItem _findNextCapacityItem(
    List<CatalogItem> catalog,
    String category,
    String subCategory,
    double targetCapacity,
  ) {
    final candidates = catalog.where((item) {
      final catMatch =
          item.category.trim().toLowerCase() == category.trim().toLowerCase();
      final subMatch = item.subCategory.trim().toLowerCase() ==
          subCategory.trim().toLowerCase();
      return catMatch && subMatch;
    }).toList();

    if (candidates.isEmpty) {
      return CatalogItem(
        category: category,
        subCategory: subCategory,
        itemName: '$category $subCategory $targetCapacity',
        capacity: targetCapacity.toStringAsFixed(1),
        dp: 0.0,
      );
    }

    candidates.sort((a, b) {
      final capA = double.tryParse(a.capacity) ?? 0.0;
      final capB = double.tryParse(b.capacity) ?? 0.0;
      return capA.compareTo(capB);
    });

    for (final item in candidates) {
      final capVal = double.tryParse(item.capacity) ?? 0.0;
      if (capVal >= targetCapacity) {
        return item;
      }
    }

    return candidates.last;
  }

  static CatalogItem _findExactItem(
    List<CatalogItem> catalog,
    String category,
    String subCategory,
  ) {
    for (final item in catalog) {
      final catMatch =
          item.category.trim().toLowerCase() == category.trim().toLowerCase();
      final subMatch = item.subCategory.trim().toLowerCase() ==
          subCategory.trim().toLowerCase();
      if (catMatch && subMatch) {
        return item;
      }
    }
    return CatalogItem(
      category: category,
      subCategory: subCategory,
      itemName: '$category $subCategory',
      capacity: 'Standard',
      dp: 0.0,
    );
  }

  /// Calculates Bill of Materials following product_maneger.txt rules
  static BomCalculationResult calculateBom({
    required double pumpCurrent,
    required int numPumps,
    required int numVfd,
    required bool mainIncomerRequired,
    required bool doorMountSwitchRequired,
    required int panelSizeLevel, // 1 - 5
    required bool olrRequired,
    required bool indicatorLightRequired,
    String controllerType = 'AIPCU OR HMI',
    List<CatalogItem>? customCatalog,
  }) {
    final catalog = customCatalog ?? defaultCatalog;
    final List<BomItem> bom = [];

    // 1. Calculate HP from pump current: HP = Current * 0.625
    final pumpHp = pumpCurrent * 0.625;
    final totalPanelCurrent = pumpCurrent * numPumps;

    // 2. Controller Lookup
    final controller = controllerType == 'AIPCU OR HMI'
        ? _findExactItem(catalog, 'Controller', '1')
        : _findExactItem(catalog, 'Controller', '2');
    bom.add(BomItem(
      itemName: controller.itemName,
      category: controller.category,
      subCategory: controller.subCategory,
      capacity: '1 Unit',
      qty: 1,
      dp: controller.dp,
    ));

    // 3. Power Supply
    final ps = _findExactItem(catalog, 'POWER SUPPLY', '1');
    bom.add(BomItem(
      itemName: ps.itemName,
      category: ps.category,
      subCategory: ps.subCategory,
      capacity: ps.capacity,
      qty: 1,
      dp: ps.dp,
    ));

    // 4. Main Load Breaker Switch (if incomer required and <= 63A)
    if (mainIncomerRequired && totalPanelCurrent <= 63) {
      final sw = _findNextCapacityItem(
        catalog,
        'switch',
        'LOAD BREAKER',
        totalPanelCurrent,
      );
      bom.add(BomItem(
        itemName: sw.itemName,
        category: sw.category,
        subCategory: sw.subCategory,
        capacity: '${sw.capacity}A',
        qty: 1,
        dp: sw.dp,
      ));
    }

    // 5. 3-Pole Door Mount Switch
    if (doorMountSwitchRequired) {
      final dm = _findNextCapacityItem(
        catalog,
        'switch',
        'DOOR MOUNT',
        totalPanelCurrent,
      );
      bom.add(BomItem(
        itemName: dm.itemName,
        category: dm.category,
        subCategory: dm.subCategory,
        capacity: '${dm.capacity}A',
        qty: 1,
        dp: dm.dp,
      ));
    }

    // 6. Main Circuit Breaker (MCB vs MCCB)
    final breakerCat = totalPanelCurrent > 63 ? 'MCCB' : 'MCB';
    final breakerSubCat = breakerCat == 'MCCB' ? 'MCCB 3P' : '3P';
    final targetRating = totalPanelCurrent * 1.25;
    final breaker = _findNextCapacityItem(
      catalog,
      breakerCat,
      breakerSubCat,
      targetRating,
    );
    bom.add(BomItem(
      itemName: breaker.itemName,
      category: breaker.category,
      subCategory: breaker.subCategory,
      capacity: '${breaker.capacity}A',
      qty: 1,
      dp: breaker.dp,
    ));

    // 7. VFD Drives
    if (numVfd > 0) {
      final vfd = _findNextCapacityItem(
        catalog,
        'VFD',
        'VFD 3 PHASE',
        pumpHp,
      );
      bom.add(BomItem(
        itemName: vfd.itemName,
        category: vfd.category,
        subCategory: vfd.subCategory,
        capacity: '${vfd.capacity} HP',
        qty: numVfd,
        dp: vfd.dp,
      ));
    }

    // 8. Contactors (Power & Bypass)
    final contactorQty = numVfd > 0 ? numPumps * 2 : numPumps;
    final contactor = _findNextCapacityItem(
      catalog,
      'CONTACTOR',
      '3 POLE',
      pumpCurrent,
    );
    bom.add(BomItem(
      itemName: contactor.itemName,
      category: contactor.category,
      subCategory: contactor.subCategory,
      capacity: '${contactor.capacity}A',
      qty: contactorQty,
      dp: contactor.dp,
    ));

    // 9. Overload Relays (OLR)
    if (olrRequired) {
      final olr = _findNextCapacityItem(
        catalog,
        'OLR',
        'THERMAL',
        pumpCurrent,
      );
      bom.add(BomItem(
        itemName: olr.itemName,
        category: olr.category,
        subCategory: olr.subCategory,
        capacity: '${olr.capacity}A',
        qty: numPumps,
        dp: olr.dp,
      ));
    }

    // 10. Cooling Fans & Filters (based on panel size & VFD)
    final fanQty = numVfd > 0 ? (panelSizeLevel >= 3 ? 2 : 1) : 1;
    final fan = _findExactItem(catalog, 'FAN', 'COOLING');
    bom.add(BomItem(
      itemName: fan.itemName,
      category: fan.category,
      subCategory: fan.subCategory,
      capacity: fan.capacity,
      qty: fanQty,
      dp: fan.dp,
    ));

    final filter = _findExactItem(catalog, 'FILTER', 'FAN FILTER');
    bom.add(BomItem(
      itemName: filter.itemName,
      category: filter.category,
      subCategory: filter.subCategory,
      capacity: filter.capacity,
      qty: fanQty,
      dp: filter.dp,
    ));

    // 11. Indicator Lights
    if (indicatorLightRequired) {
      final light = _findExactItem(catalog, 'INDICATOR', 'LED');
      bom.add(BomItem(
        itemName: light.itemName,
        category: light.category,
        subCategory: light.subCategory,
        capacity: light.capacity,
        qty: 3, // R, Y, B indicators
        dp: light.dp,
      ));
    }

    // Calculate totals
    final totalMaterialCost =
        bom.fold<double>(0.0, (sum, item) => sum + item.totalDp);

    // Labor calculation ported from product_maneger.txt
    final laborCost = 1500.0 + (numPumps * 500.0) + (numVfd * 450.0);
    final grandTotal = totalMaterialCost + laborCost;

    return BomCalculationResult(
      items: bom,
      pumpHp: pumpHp,
      totalPanelCurrent: totalPanelCurrent,
      totalMaterialCost: totalMaterialCost,
      laborCost: laborCost,
      grandTotal: grandTotal,
    );
  }
}
