import 'package:spc_sosro/core/errors/app_exception.dart';
import 'package:spc_sosro/core/errors/error_mapper.dart';
import 'package:spc_sosro/models/profile.dart';
import 'package:spc_sosro/services/supabase_service.dart';

class ProfileRepository {
  Future<Profile> fetchCurrentProfile() async {
    try {
      final user = SupabaseService.auth.currentUser;
      if (user == null) {
        throw const AuthException('Pengguna belum masuk', code: 'SPC01');
      }

      final response = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ErrorMapper.mapSupabaseError(e);
    }
  }

  Future<List<Profile>> fetchAllProfiles() async {
    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select()
          .order('full_name');

      return (response as List)
          .map((json) => Profile.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }

  Future<void> setUserStatus({
    required String userId,
    required bool isActive,
  }) async {
    try {
      await SupabaseService.client.rpc(
        'admin_set_user_status',
        params: {
          'p_user_id': userId,
          'p_is_active': isActive,
        },
      );
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }

  Future<void> adminUpdateProfile({
    required String userId,
    required String fullName,
    required String role,
    required bool isActive,
  }) async {
    try {
      try {
        await SupabaseService.client.rpc(
          'admin_update_profile',
          params: {
            'p_user_id': userId,
            'p_full_name': fullName,
            'p_role': role,
            'p_is_active': isActive,
          },
        );
      } catch (_) {
        // Fallback update langsung ke tabel profiles
        await SupabaseService.client.from('profiles').update({
          'full_name': fullName,
          'role': role,
          'is_active': isActive,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
      }
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }
}
