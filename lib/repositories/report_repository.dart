import 'package:spc_sosro/core/errors/error_mapper.dart';
import 'package:spc_sosro/models/report_filter.dart';
import 'package:spc_sosro/services/supabase_service.dart';

class ReportRepository {
  Future<List<Map<String, dynamic>>> getReportData(ReportFilter filter) async {
    try {
      final response = await SupabaseService.client.rpc(
        'get_report_data',
        params: {
          'p_report_type': filter.reportType,
          'p_start_date': filter.startDate.toIso8601String().split('T').first,
          'p_end_date': filter.endDate.toIso8601String().split('T').first,
          if (filter.productId != null) 'p_product_id': filter.productId,
          if (filter.operatorId != null) 'p_operator_id': filter.operatorId,
          if (filter.transactionType != null)
            'p_transaction_type': filter.transactionType!.value,
          'p_page': filter.page,
          'p_page_size': filter.pageSize,
        },
      );

      return (response as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }
}
