import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_attendance_app/services/bom_calculation_engine.dart';

void main() {
  group('BOM Calculation Engine Tests', () {
    test('Calculates correct HP and total current for 10A 2-pump system', () {
      final res = BomCalculationEngine.calculateBom(
        pumpCurrent: 10.0,
        numPumps: 2,
        numVfd: 1,
        mainIncomerRequired: true,
        doorMountSwitchRequired: true,
        panelSizeLevel: 2,
        olrRequired: true,
        indicatorLightRequired: true,
      );

      // 10A * 0.625 = 6.25 HP
      expect(res.pumpHp, closeTo(6.25, 0.01));
      // 10A * 2 = 20A
      expect(res.totalPanelCurrent, 20.0);

      // Contactors with VFD: 2 pumps * 2 = 4 contactors
      final contactorItem =
          res.items.firstWhere((item) => item.category == 'CONTACTOR');
      expect(contactorItem.qty, 4);

      // Breaker for 20A load is MCB (< 63A)
      final breakerItem = res.items.firstWhere(
          (item) => item.category == 'MCB' || item.category == 'MCCB');
      expect(breakerItem.category, 'MCB');

      // Grand total should equal material cost + labor cost
      expect(res.grandTotal, res.totalMaterialCost + res.laborCost);
      expect(res.items.isNotEmpty, true);
    });

    test('Switches to MCCB when total panel current exceeds 63A', () {
      // 25A * 3 pumps = 75A total current (> 63A threshold)
      final res = BomCalculationEngine.calculateBom(
        pumpCurrent: 25.0,
        numPumps: 3,
        numVfd: 1,
        mainIncomerRequired: true,
        doorMountSwitchRequired: false,
        panelSizeLevel: 4,
        olrRequired: true,
        indicatorLightRequired: false,
      );

      expect(res.totalPanelCurrent, 75.0);
      final breakerItem = res.items.firstWhere(
          (item) => item.category == 'MCB' || item.category == 'MCCB');
      expect(breakerItem.category, 'MCCB');
    });

    test('Uses num_pumps contactors when numVfd is 0 (direct on line)', () {
      final res = BomCalculationEngine.calculateBom(
        pumpCurrent: 8.0,
        numPumps: 3,
        numVfd: 0,
        mainIncomerRequired: false,
        doorMountSwitchRequired: false,
        panelSizeLevel: 1,
        olrRequired: false,
        indicatorLightRequired: false,
      );

      final contactorItem =
          res.items.firstWhere((item) => item.category == 'CONTACTOR');
      expect(contactorItem.qty, 3); // 3 pumps * 1 = 3 contactors
    });
  });
}
