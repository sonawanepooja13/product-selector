import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_attendance_app/main.dart';

void main() {
  testWidgets('Product Manager Mobile App loads smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProductManagerMobileApp());
    expect(find.text('Product Price Lookup'), findsOneWidget);
    expect(find.text('Booster Panel Specifications'), findsOneWidget);
  });
}
