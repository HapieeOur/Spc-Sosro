import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spc_sosro/core/errors/error_mapper.dart';
import 'package:spc_sosro/services/supabase_service.dart';

class AuthRepository {
  Session? get currentSession => SupabaseService.auth.currentSession;
  Stream<AuthState> get authStateChanges => SupabaseService.auth.onAuthStateChange;
  User? get currentUser => SupabaseService.auth.currentUser;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await SupabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }

  Future<void> signOut() async {
    try {
      await SupabaseService.auth.signOut();
    } catch (e) {
      throw ErrorMapper.mapSupabaseError(e);
    }
  }
}
