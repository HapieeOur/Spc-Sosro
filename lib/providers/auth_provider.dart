import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spc_sosro/core/constants/app_constants.dart';
import 'package:spc_sosro/core/errors/app_exception.dart';
import 'package:spc_sosro/models/profile.dart';
import 'package:spc_sosro/repositories/auth_repository.dart';
import 'package:spc_sosro/repositories/profile_repository.dart';
import 'package:spc_sosro/services/supabase_service.dart';

sealed class AuthState {
  const AuthState();
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  final Profile profile;
  const AuthStateAuthenticated(this.profile);
}

class AuthStateDenied extends AuthState {
  final String message;
  const AuthStateDenied(this.message);
}

class AuthStateSignedOut extends AuthState {
  const AuthStateSignedOut();
}

class AuthStateError extends AuthState {
  final String message;
  const AuthStateError(this.message);
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  final ProfileRepository _profileRepo;

  AuthController(this._authRepo, this._profileRepo) : super(const AuthStateInitial()) {
    checkSession();
  }

  Future<void> checkSession() async {
    state = const AuthStateLoading();
    try {
      final session = _authRepo.currentSession;
      if (session == null) {
        state = const AuthStateSignedOut();
        return;
      }

      final profile = await _profileRepo.fetchCurrentProfile();
      if (!profile.isActive) {
        await _authRepo.signOut();
        state = const AuthStateDenied('Akun Anda dinonaktifkan atau masih menunggu persetujuan (ACC) Admin.');
        return;
      }

      state = AuthStateAuthenticated(profile);
    } catch (e) {
      if (e is AppException) {
        state = AuthStateError(e.message);
      } else {
        state = const AuthStateSignedOut();
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthStateLoading();
    try {
      await _authRepo.signIn(email: email, password: password);
      final profile = await _profileRepo.fetchCurrentProfile();

      if (!profile.isActive) {
        await _authRepo.signOut();
        state = const AuthStateDenied('Akun Anda sedang menunggu persetujuan (ACC) Admin. Silakan hubungi Administrator gudang.');
        return;
      }

      state = AuthStateAuthenticated(profile);
    } catch (e) {
      if (e is AppException) {
        state = AuthStateError(e.message);
      } else {
        state = AuthStateError(e.toString());
      }
    }
  }

  void clearError() {
    if (state is AuthStateError || state is AuthStateDenied) {
      state = const AuthStateSignedOut();
    }
  }

  Future<({bool success, String? error})> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final authResponse = await _authRepo.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      // Pastikan status akun baru adalah non-aktif (menunggu persetujuan / ACC admin)
      final user = authResponse.user;
      if (user != null) {
        try {
          await SupabaseService.client
              .from('profiles')
              .update({'is_active': false})
              .eq('id', user.id);
        } catch (_) {}
      }

      // Pastikan sesi dikeluarkan agar tidak login otomatis sebelum disetujui admin
      await _authRepo.signOut();
      state = const AuthStateSignedOut();
      return (success: true, error: null);
    } catch (e) {
      String message;
      if (e is AppException) {
        message = e.message;
      } else {
        message = e.toString();
      }
      return (success: false, error: message);
    }
  }

  Future<void> logout() async {
    state = const AuthStateLoading();
    try {
      await _authRepo.signOut();
      state = const AuthStateSignedOut();
    } catch (e) {
      state = const AuthStateSignedOut();
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final profileRepo = ref.watch(profileRepositoryProvider);
  return AuthController(authRepo, profileRepo);
});

final currentProfileProvider = Provider<Profile?>((ref) {
  final authState = ref.watch(authControllerProvider);
  if (authState is AuthStateAuthenticated) {
    return authState.profile;
  }
  return null;
});

final isAdminProvider = Provider<bool>((ref) {
  final profile = ref.watch(currentProfileProvider);
  return profile?.role == AppRole.admin;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState is AuthStateAuthenticated;
});
