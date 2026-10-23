class StockSummary {
  final String productId;
  final String code;
  final String name;
  final int rowsPerPallet;
  final int boxesPerRow;
  final int boxesPerPallet;
  final int minStockBoxes;
  final int openingBoxes;
  final int inBoxes;
  final int outBoxes;
  final int stockBoxes;
  final int fullPallets;
  final int looseRows;
  final int looseBoxes;
  final bool isLowStock;

  const StockSummary({
    required this.productId,
    required this.code,
    required this.name,
    required this.rowsPerPallet,
    required this.boxesPerRow,
    required this.boxesPerPallet,
    required this.minStockBoxes,
    required this.openingBoxes,
    required this.inBoxes,
    required this.outBoxes,
    required this.stockBoxes,
    required this.fullPallets,
    required this.looseRows,
    required this.looseBoxes,
    required this.isLowStock,
  });

  factory StockSummary.fromJson(Map<String, dynamic> json) {
    return StockSummary(
      productId: json['product_id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      rowsPerPallet: json['rows_per_pallet'] as int,
      boxesPerRow: json['boxes_per_row'] as int,
      boxesPerPallet: json['boxes_per_pallet'] as int,
      minStockBoxes: json['min_stock_boxes'] as int,
      openingBoxes: json['opening_boxes'] as int,
      inBoxes: json['in_boxes'] as int,
      outBoxes: json['out_boxes'] as int,
      stockBoxes: json['stock_boxes'] as int,
      fullPallets: json['full_pallets'] as int,
      looseRows: json['loose_rows'] as int,
      looseBoxes: json['loose_boxes'] as int,
      isLowStock: json['is_low_stock'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'code': code,
      'name': name,
      'rows_per_pallet': rowsPerPallet,
      'boxes_per_row': boxesPerRow,
      'boxes_per_pallet': boxesPerPallet,
      'min_stock_boxes': minStockBoxes,
      'opening_boxes': openingBoxes,
      'in_boxes': inBoxes,
      'out_boxes': outBoxes,
      'stock_boxes': stockBoxes,
      'full_pallets': fullPallets,
      'loose_rows': looseRows,
      'loose_boxes': looseBoxes,
      'is_low_stock': isLowStock,
    };
  }
}
