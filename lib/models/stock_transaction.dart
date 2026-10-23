import 'package:spc_sosro/core/constants/app_constants.dart';
import 'package:spc_sosro/models/stock_transaction_detail.dart';

class StockTransaction {
  final String id;
  final String transactionNo;
  final TransactionType transactionType;
  final DateTime transactionDate;
  final String operatorId;
  final String operatorNameSnapshot;
  final String? note;
  final TransactionStatus status;
  final int totalBoxes;
  final double totalPalletEquivalent;
  final String clientRequestId;
  final String? correctionOfId;
  final DateTime? voidedAt;
  final String? voidedBy;
  final String? voidReason;
  final DateTime createdAt;
  final List<StockTransactionDetail> details;

  const StockTransaction({
    required this.id,
    required this.transactionNo,
    required this.transactionType,
    required this.transactionDate,
    required this.operatorId,
    required this.operatorNameSnapshot,
    this.note,
    required this.status,
    required this.totalBoxes,
    required this.totalPalletEquivalent,
    required this.clientRequestId,
    this.correctionOfId,
    this.voidedAt,
    this.voidedBy,
    this.voidReason,
    required this.createdAt,
    this.details = const [],
  });

  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    return StockTransaction(
      id: json['id'] as String,
      transactionNo: json['transaction_no'] as String,
      transactionType: TransactionType.values.firstWhere(
        (e) => e.name == json['transaction_type'] as String,
      ),
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      operatorId: json['operator_id'] as String,
      operatorNameSnapshot: json['operator_name_snapshot'] as String,
      note: json['note'] as String?,
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'] as String,
      ),
      totalBoxes: json['total_boxes'] as int,
      totalPalletEquivalent:
          (json['total_pallet_equivalent'] as num).toDouble(),
      clientRequestId: json['client_request_id'] as String,
      correctionOfId: json['correction_of_id'] as String?,
      voidedAt: json['voided_at'] != null
          ? DateTime.parse(json['voided_at'] as String)
          : null,
      voidedBy: json['voided_by'] as String?,
      voidReason: json['void_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      details: (json['details'] as List<dynamic>?)
              ?.map((e) => StockTransactionDetail.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_no': transactionNo,
      'transaction_type': transactionType.name,
      'transaction_date': transactionDate.toIso8601String(),
      'operator_id': operatorId,
      'operator_name_snapshot': operatorNameSnapshot,
      'note': note,
      'status': status.name,
      'total_boxes': totalBoxes,
      'total_pallet_equivalent': totalPalletEquivalent,
      'client_request_id': clientRequestId,
      'correction_of_id': correctionOfId,
      'voided_at': voidedAt?.toIso8601String(),
      'voided_by': voidedBy,
      'void_reason': voidReason,
      'created_at': createdAt.toIso8601String(),
      'details': details.map((e) => e.toJson()).toList(),
    };
  }
}
