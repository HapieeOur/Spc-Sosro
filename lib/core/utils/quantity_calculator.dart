class QuantityCalculator {
  QuantityCalculator._();

  static int calculateTotalBoxes({
    required int fullPallets,
    required int looseRows,
    required int looseBoxes,
    required int rowsPerPallet,
    required int boxesPerRow,
  }) {
    _assertNonNegative(fullPallets, 'fullPallets');
    _assertNonNegative(looseRows, 'looseRows');
    _assertNonNegative(looseBoxes, 'looseBoxes');
    _assertNonNegative(rowsPerPallet, 'rowsPerPallet');
    _assertNonNegative(boxesPerRow, 'boxesPerRow');

    return (fullPallets * rowsPerPallet * boxesPerRow) +
        (looseRows * boxesPerRow) +
        looseBoxes;
  }

  static ({int pallets, int rows, int boxes}) convertBoxesToDisplay({
    required int totalBoxes,
    required int rowsPerPallet,
    required int boxesPerRow,
  }) {
    _assertNonNegative(totalBoxes, 'totalBoxes');
    _assertNonNegative(rowsPerPallet, 'rowsPerPallet');
    _assertNonNegative(boxesPerRow, 'boxesPerRow');

    if (boxesPerRow == 0 || rowsPerPallet == 0) {
      return (pallets: 0, rows: 0, boxes: totalBoxes);
    }

    final perPallet = rowsPerPallet * boxesPerRow;
    final pallets = totalBoxes ~/ perPallet;
    final remaining = totalBoxes % perPallet;
    final rows = remaining ~/ boxesPerRow;
    final boxes = remaining % boxesPerRow;

    return (pallets: pallets, rows: rows, boxes: boxes);
  }

  static int boxesPerPallet({
    required int rowsPerPallet,
    required int boxesPerRow,
  }) {
    _assertNonNegative(rowsPerPallet, 'rowsPerPallet');
    _assertNonNegative(boxesPerRow, 'boxesPerRow');

    return rowsPerPallet * boxesPerRow;
  }

  static void _assertNonNegative(int value, String name) {
    if (value < 0) {
      throw ArgumentError.value(value, name, 'must be non-negative');
    }
  }
}
