import 'package:spc_sosro/core/errors/error_mapper.dart';
import 'package:spc_sosro/models/activity_log.dart';
import 'package:spc_sosro/services/supabase_service.dart';

class SettingsRepository {
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await SupabaseService.client
          .from('app_settings')
          .select('key, value');

      final result = <String, dynamic>{};
      for (final row in response as List) {
        result[row['key'] as String] = row['value'];
      }
      return result;
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }

  Future<void> adminUpdateSettings({
    required String key,
    required dynamic value,
  }) async {
    try {
      await SupabaseService.client.rpc(
        'admin_update_settings',
        params: {
          'p_key': key,
          'p_value': value,
        },
      );
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }

  Future<List<ActivityLog>> fetchActivityLogs({int limit = 50}) async {
    try {
      final response = await SupabaseService.client
          .from('activity_logs')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => ActivityLog.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }
}
