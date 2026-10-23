import 'package:spc_sosro/core/constants/app_constants.dart';
import 'package:spc_sosro/core/errors/error_mapper.dart';
import 'package:spc_sosro/models/stock_transaction.dart';
import 'package:spc_sosro/services/supabase_service.dart';

class TransactionRepository {
  Future<Map<String, dynamic>> createTransaction({
    required TransactionType type,
    String? note,
    required String clientRequestId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await SupabaseService.client.rpc(
        'create_stock_transaction',
        params: {
          'p_type': type.value,
          'p_note': note,
          'p_client_request_id': clientRequestId,
          'p_items': items,
        },
      );
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }

  Future<Map<String, dynamic>> voidTransaction({
    required String transactionId,
    required String reason,
  }) async {
    try {
      final response = await SupabaseService.client.rpc(
        'void_stock_transaction',
        params: {
          'p_transaction_id': transactionId,
          'p_reason': reason,
        },
      );
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }

  Future<Map<String, dynamic>> correctTransaction({
    required String transactionId,
    required String reason,
    String? note,
    required String clientRequestId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await SupabaseService.client.rpc(
        'correct_stock_transaction',
        params: {
          'p_transaction_id': transactionId,
          'p_reason': reason,
          'p_note': note,
          'p_client_request_id': clientRequestId,
          'p_items': items,
        },
      );
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }

  Future<List<StockTransaction>> fetchTransactions({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    TransactionStatus? status,
    String? operatorId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = SupabaseService.client
          .from('stock_transactions')
          .select('*, stock_transaction_details(*)');

      if (startDate != null) {
        query = query.gte('transaction_date', startDate.toIso8601String().split('T').first);
      }
      if (endDate != null) {
        query = query.lte('transaction_date', endDate.toIso8601String().split('T').first);
      }
      if (type != null) {
        query = query.eq('transaction_type', type.value);
      }
      if (status != null) {
        query = query.eq('status', status.name);
      }
      if (operatorId != null) {
        query = query.eq('operator_id', operatorId);
      }

      final response = await query
          .order('transaction_date', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => StockTransaction.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }

  Future<StockTransaction> fetchTransactionById(String id) async {
    try {
      final response = await SupabaseService.client
          .from('stock_transactions')
          .select('*, stock_transaction_details(*)')
          .eq('id', id)
          .single();

      return StockTransaction.fromJson(response);
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }
}
