class StockOpeningBalance {
  final String id;
  final String productId;
  final int qtyBoxes;
  final DateTime effectiveDate;
  final String note;
  final String? createdBy;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StockOpeningBalance({
    required this.id,
    required this.productId,
    required this.qtyBoxes,
    required this.effectiveDate,
    required this.note,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockOpeningBalance.fromJson(Map<String, dynamic> json) {
    return StockOpeningBalance(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      qtyBoxes: json['qty_boxes'] as int,
      effectiveDate: DateTime.parse(json['effective_date'] as String),
      note: json['note'] as String,
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'qty_boxes': qtyBoxes,
      'effective_date': effectiveDate.toIso8601String(),
      'note': note,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
