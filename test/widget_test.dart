import 'package:flutter_test/flutter_test.dart';
import 'package:spc_sosro/core/utils/quantity_calculator.dart';

void main() {
  test('QuantityCalculator calculateTotalBoxes calculates correctly', () {
    // 2 pallets * (5 rows * 10 boxes) = 100
    // 3 loose rows * 10 boxes = 30
    // 4 loose boxes = 4
    // Total = 134
    final total = QuantityCalculator.calculateTotalBoxes(
      fullPallets: 2,
      looseRows: 3,
      looseBoxes: 4,
      rowsPerPallet: 5,
      boxesPerRow: 10,
    );

    expect(total, 134);
  });
}
