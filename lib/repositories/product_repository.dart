import 'package:spc_sosro/core/errors/error_mapper.dart';
import 'package:spc_sosro/models/product.dart';
import 'package:spc_sosro/services/supabase_service.dart';

class ProductRepository {
  Future<List<Product>> fetchActiveProducts() async {
    try {
      final response = await SupabaseService.client
          .from('products')
          .select()
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }

  Future<List<Product>> fetchAllProducts() async {
    try {
      final response = await SupabaseService.client
          .from('products')
          .select()
          .order('name');

      return (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }

  Future<void> adminSaveProduct({
    String? productId,
    required String code,
    required String name,
    required int rowsPerPallet,
    required int boxesPerRow,
    required int minStockBoxes,
    required bool isActive,
  }) async {
    try {
      await SupabaseService.client.rpc(
        'admin_save_product',
        params: {
          'p_product_id': productId,
          'p_code': code,
          'p_name': name,
          'p_rows_per_pallet': rowsPerPallet,
          'p_boxes_per_row': boxesPerRow,
          'p_min_stock_boxes': minStockBoxes,
          'p_is_active': isActive,
        },
      );
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }

  Future<void> adminSetProductStatus({
    required String productId,
    required bool isActive,
  }) async {
    try {
      await SupabaseService.client.rpc(
        'admin_set_product_status',
        params: {
          'p_product_id': productId,
          'p_is_active': isActive,
        },
      );
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }
}
