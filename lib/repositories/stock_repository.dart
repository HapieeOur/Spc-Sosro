import 'package:spc_sosro/core/errors/error_mapper.dart';
import 'package:spc_sosro/models/dashboard_data.dart';
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
      throw ErrorMapper.mapSupabaseError(e);
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
}
