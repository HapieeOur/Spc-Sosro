import 'package:spc_sosro/core/errors/error_mapper.dart';
import 'package:spc_sosro/models/dashboard_data.dart';
import 'package:spc_sosro/models/stock_opening_balance.dart';
import 'package:spc_sosro/models/stock_summary.dart';
import 'package:spc_sosro/services/supabase_service.dart';

class StockRepository {
  Future<List<StockSummary>> getStockSummary({DateTime? asOfDate}) async {
    try {
      final response = await SupabaseService.client.rpc(
        'get_stock_summary',
        params: {
          if (asOfDate != null)
            'p_as_of_date': asOfDate.toIso8601String().split('T').first,
        },
      );

      return (response as List)
          .map((json) => StockSummary.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getDailyStockReport({
    required DateTime startDate,
    required DateTime endDate,
    String? productId,
  }) async {
    try {
      final response = await SupabaseService.client.rpc(
        'get_daily_stock_report',
        params: {
          'p_start_date': startDate.toIso8601String().split('T').first,
          'p_end_date': endDate.toIso8601String().split('T').first,
          'p_product_id': ?productId,
        },
      );

      return (response as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }

  Future<DashboardData> getDashboardSummary() async {
    try {
      final response = await SupabaseService.client.rpc('get_dashboard_summary');
      return DashboardData.fromJson(Map<String, dynamic>.from(response as Map));
    } catch (e) {
      // Fallback anggun jika RPC get_dashboard_summary di PostgreSQL belum diperbarui
      try {
        final stockList = await getStockSummary();
        final lowStock = stockList.where((p) => p.isLowStock).toList();
        return DashboardData(
          todayInBoxes: 0,
          todayOutBoxes: 0,
          todayInPalletEquivalent: 0.0,
          todayOutPalletEquivalent: 0.0,
          stockByProduct: stockList,
          lowStock: lowStock,
          recentActivity: [],
          sevenDayTrend: [],
        );
      } catch (_) {
        throw ErrorMapper.mapSupabaseError(e);
      }
    }
  }

  Future<void> adminSetOpeningBalance({
    required String productId,
    required int qtyBoxes,
    required DateTime effectiveDate,
    required String note,
  }) async {
    try {
      await SupabaseService.client.rpc(
        'admin_set_opening_balance',
        params: {
          'p_product_id': productId,
          'p_qty_boxes': qtyBoxes,
          'p_effective_date': effectiveDate.toIso8601String().split('T').first,
          'p_note': note,
        },
      );
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }

  Future<List<StockOpeningBalance>> fetchOpeningBalances() async {
    try {
      final response = await SupabaseService.client
          .from('stock_opening_balances')
          .select()
          .order('effective_date', ascending: false);

      return (response as List)
          .map((json) => StockOpeningBalance.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }
}
