import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spc_sosro/core/constants/app_constants.dart';
import 'package:spc_sosro/models/stock_transaction.dart';
import 'package:spc_sosro/providers/dashboard_provider.dart';
import 'package:spc_sosro/providers/transaction_form_provider.dart';

class HistoryFilterState {
  final DateTime? startDate;
  final DateTime? endDate;
  final TransactionType? type;
  final TransactionStatus? status;
  final String? operatorId;
  final String searchQuery;

  const HistoryFilterState({
    this.startDate,
    this.endDate,
    this.type,
    this.status,
    this.operatorId,
    this.searchQuery = '',
  });

  HistoryFilterState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    TransactionStatus? status,
    String? operatorId,
    String? searchQuery,
  }) {
    return HistoryFilterState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      status: status ?? this.status,
      operatorId: operatorId ?? this.operatorId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final historyFilterProvider = StateProvider.autoDispose<HistoryFilterState>((ref) {
  return const HistoryFilterState();
});

final transactionHistoryProvider = FutureProvider.autoDispose<List<StockTransaction>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final filter = ref.watch(historyFilterProvider);

  final transactions = await repo.fetchTransactions(
    startDate: filter.startDate,
    endDate: filter.endDate,
    type: filter.type,
    status: filter.status,
    operatorId: filter.operatorId,
  );

  if (filter.searchQuery.isEmpty) return transactions;

  final q = filter.searchQuery.toLowerCase();
  return transactions.where((t) {
    return t.transactionNo.toLowerCase().contains(q) ||
        (t.note?.toLowerCase().contains(q) ?? false) ||
        t.operatorNameSnapshot.toLowerCase().contains(q);
  }).toList();
});

final dailyStockReportProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(stockRepositoryProvider);
  final filter = ref.watch(historyFilterProvider);

  final now = DateTime.now();
  final start = filter.startDate ?? DateTime(now.year, now.month, 1);
  final end = filter.endDate ?? now;

  return repo.getDailyStockReport(
    startDate: start,
    endDate: end,
  );
});
