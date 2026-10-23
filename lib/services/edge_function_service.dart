import 'supabase_service.dart';

class EdgeFunctionService {
  Future<Map<String, dynamic>> createUser({
    required String fullName,
    required String email,
    required String temporaryPassword,
    required String role,
    bool isActive = true,
  }) async {
    final response = await SupabaseService.client.functions.invoke(
      'admin-users',
      body: {
        'action': 'create',
        'full_name': fullName,
        'email': email,
        'temporary_password': temporaryPassword,
        'role': role,
        'is_active': isActive,
      },
    );

    if (response.status != 200) {
      final errorMsg = response.data is Map
          ? response.data['error']?.toString()
          : null;
      throw Exception(errorMsg ?? 'Gagal membuat pengguna');
    }

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> disableUser({
    required String userId,
    required String reason,
  }) async {
    final response = await SupabaseService.client.functions.invoke(
      'admin-users',
      body: {
        'action': 'disable',
        'user_id': userId,
        'reason': reason,
      },
    );

    if (response.status != 200) {
      final errorMsg = response.data is Map
          ? response.data['error']?.toString()
          : null;
      throw Exception(errorMsg ?? 'Gagal menonaktifkan pengguna');
    }

    return Map<String, dynamic>.from(response.data as Map);
  }
}
