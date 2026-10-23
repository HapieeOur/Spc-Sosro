class AppConstants {
  AppConstants._();

  static const appName = 'SPC Pallet Counter';
  static const maxProductsPerTransaction = 5;
  static const minCorrectionReasonLength = 10;
  static const timezone = 'Asia/Jakarta';
  static const transactionNoPrefix = 'SPC';
}

enum AppRole { admin, operator }

enum TransactionType {
  stockIn('in'),
  stockOut('out');

  const TransactionType(this.value);
  final String value;
}

enum TransactionStatus { posted, voided, corrected }
