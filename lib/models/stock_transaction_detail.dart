class StockTransactionDetail {
  final String id;
  final String transactionId;
  final int lineNo;
  final String productId;
  final String productCodeSnapshot;
  final String productNameSnapshot;
  final int rowsPerPalletSnapshot;
  final int boxesPerRowSnapshot;
  final int fullPallets;
  final int looseRows;
  final int looseBoxes;
  final int totalBoxes;

  const StockTransactionDetail({
    required this.id,
    required this.transactionId,
    required this.lineNo,
    required this.productId,
    required this.productCodeSnapshot,
    required this.productNameSnapshot,
    required this.rowsPerPalletSnapshot,
    required this.boxesPerRowSnapshot,
    required this.fullPallets,
    required this.looseRows,
    required this.looseBoxes,
    required this.totalBoxes,
  });

  factory StockTransactionDetail.fromJson(Map<String, dynamic> json) {
    return StockTransactionDetail(
      id: json['id'] as String,
      transactionId: json['transaction_id'] as String,
      lineNo: json['line_no'] as int,
      productId: json['product_id'] as String,
      productCodeSnapshot: json['product_code_snapshot'] as String,
      productNameSnapshot: json['product_name_snapshot'] as String,
      rowsPerPalletSnapshot: json['rows_per_pallet_snapshot'] as int,
      boxesPerRowSnapshot: json['boxes_per_row_snapshot'] as int,
      fullPallets: json['full_pallets'] as int,
      looseRows: json['loose_rows'] as int,
      looseBoxes: json['loose_boxes'] as int,
      totalBoxes: json['total_boxes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'line_no': lineNo,
      'product_id': productId,
      'product_code_snapshot': productCodeSnapshot,
      'product_name_snapshot': productNameSnapshot,
      'rows_per_pallet_snapshot': rowsPerPalletSnapshot,
      'boxes_per_row_snapshot': boxesPerRowSnapshot,
      'full_pallets': fullPallets,
      'loose_rows': looseRows,
      'loose_boxes': looseBoxes,
      'total_boxes': totalBoxes,
    };
  }
}
