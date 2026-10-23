import 'package:spc_sosro/core/constants/app_constants.dart';

class ReportFilter {
  final String reportType;
  final DateTime startDate;
  final DateTime endDate;
  final String? productId;
  final String? operatorId;
  final TransactionType? transactionType;
  final int page;
  final int pageSize;

  const ReportFilter({
    required this.reportType,
    required this.startDate,
    required this.endDate,
    this.productId,
    this.operatorId,
    this.transactionType,
    this.page = 1,
    this.pageSize = 20,
  });

  ReportFilter copyWith({
    String? reportType,
    DateTime? startDate,
    DateTime? endDate,
    String? Function()? productId,
    String? Function()? operatorId,
    TransactionType? Function()? transactionType,
    int? page,
    int? pageSize,
  }) {
    return ReportFilter(
      reportType: reportType ?? this.reportType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      productId: productId != null ? productId() : this.productId,
      operatorId: operatorId != null ? operatorId() : this.operatorId,
      transactionType: transactionType != null
          ? transactionType()
          : this.transactionType,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_type': reportType,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'product_id': productId,
      'operator_id': operatorId,
      'transaction_type': transactionType?.name,
      'page': page,
      'page_size': pageSize,
    };
  }
}
