class TransactionCorrection {
  final String id;
  final String originalTransactionId;
  final String correctedTransactionId;
  final String reason;
  final Map<String, dynamic> beforeData;
  final Map<String, dynamic> afterData;
  final String correctedBy;
  final DateTime correctedAt;

  const TransactionCorrection({
    required this.id,
    required this.originalTransactionId,
    required this.correctedTransactionId,
    required this.reason,
    required this.beforeData,
    required this.afterData,
    required this.correctedBy,
    required this.correctedAt,
  });

  factory TransactionCorrection.fromJson(Map<String, dynamic> json) {
    return TransactionCorrection(
      id: json['id'] as String,
      originalTransactionId: json['original_transaction_id'] as String,
      correctedTransactionId: json['corrected_transaction_id'] as String,
      reason: json['reason'] as String,
      beforeData: json['before_data'] as Map<String, dynamic>,
      afterData: json['after_data'] as Map<String, dynamic>,
      correctedBy: json['corrected_by'] as String,
      correctedAt: DateTime.parse(json['corrected_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'original_transaction_id': originalTransactionId,
      'corrected_transaction_id': correctedTransactionId,
      'reason': reason,
      'before_data': beforeData,
      'after_data': afterData,
      'corrected_by': correctedBy,
      'corrected_at': correctedAt.toIso8601String(),
    };
  }
}
