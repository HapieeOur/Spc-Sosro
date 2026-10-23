class Product {
  final String id;
  final String code;
  final String name;
  final int rowsPerPallet;
  final int boxesPerRow;
  final int boxesPerPallet;
  final int minStockBoxes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.code,
    required this.name,
    required this.rowsPerPallet,
    required this.boxesPerRow,
    required this.boxesPerPallet,
    required this.minStockBoxes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      rowsPerPallet: json['rows_per_pallet'] as int,
      boxesPerRow: json['boxes_per_row'] as int,
      boxesPerPallet: json['boxes_per_pallet'] as int,
      minStockBoxes: json['min_stock_boxes'] as int,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'rows_per_pallet': rowsPerPallet,
      'boxes_per_row': boxesPerRow,
      'boxes_per_pallet': boxesPerPallet,
      'min_stock_boxes': minStockBoxes,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
