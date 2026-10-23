import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spc_sosro/core/constants/app_constants.dart';
import 'package:spc_sosro/core/errors/app_exception.dart';
import 'package:spc_sosro/models/profile.dart';
import 'package:spc_sosro/repositories/auth_repository.dart';
import 'package:spc_sosro/repositories/profile_repository.dart';

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
        state = const AuthStateDenied('Akun Anda dinonaktifkan. Hubungi administrator.');
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
        state = const AuthStateDenied('Akun Anda dinonaktifkan. Hubungi administrator.');
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
