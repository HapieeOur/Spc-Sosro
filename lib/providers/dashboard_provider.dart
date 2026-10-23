import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spc_sosro/models/dashboard_data.dart';
import 'package:spc_sosro/models/stock_summary.dart';
import 'package:spc_sosro/repositories/stock_repository.dart';

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return StockRepository();
});

final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  final repo = ref.watch(stockRepositoryProvider);
  return repo.getDashboardSummary();
});

final stockSummaryProvider = FutureProvider.autoDispose<List<StockSummary>>((ref) async {
  final repo = ref.watch(stockRepositoryProvider);
  return repo.getStockSummary();
});
