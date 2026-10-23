import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spc_sosro/core/constants/app_constants.dart';
import 'package:spc_sosro/providers/auth_provider.dart';
import 'package:spc_sosro/screens/admin/admin_dashboard_screen.dart';
import 'package:spc_sosro/screens/auth/login_screen.dart';
import 'package:spc_sosro/screens/auth/register_screen.dart';
import 'package:spc_sosro/screens/shared/profile_screen.dart';
import 'package:spc_sosro/screens/splash_screen.dart';
import 'package:spc_sosro/screens/user/transaction_history_screen.dart';
import 'package:spc_sosro/screens/user/user_dashboard_screen.dart';
import 'package:spc_sosro/screens/user/user_shell.dart';

class AppRouterNotifier extends ChangeNotifier {
  final Ref _ref;

  AppRouterNotifier(this._ref) {
    _ref.listen(authControllerProvider, (_, _) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<AppRouterNotifier>((ref) {
  return AppRouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isOnLogin = state.matchedLocation == '/login';
      final isOnRegister = state.matchedLocation == '/register';
      final isOnSplash = state.matchedLocation == '/splash';

      // Selama pengecekan sesi awal, tetap di splash
      if (authState is AuthStateInitial || authState is AuthStateLoading) {
        return isOnSplash ? null : '/splash';
      }

      // Jika belum autentikasi, izinkan login dan register
      if (authState is! AuthStateAuthenticated) {
        if (isOnLogin || isOnRegister) return null;
        return '/login';
      }

      final profile = authState.profile;
      final isAdmin = profile.role == AppRole.admin;
      final isOnAuthScreen = isOnLogin || isOnRegister || isOnSplash;

      if (isOnAuthScreen) {
        return isAdmin ? '/admin/dashboard' : '/user/dashboard';
      }

      // Pembatasan akses jika operator mencoba masuk ke route admin
      if (!isAdmin && state.matchedLocation.startsWith('/admin')) {
        return '/user/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) => UserShell(child: child),
        routes: [
          GoRoute(
            path: '/user/dashboard',
            builder: (context, state) => const UserDashboardScreen(),
          ),
          GoRoute(
            path: '/user/history',
            builder: (context, state) => const TransactionHistoryScreen(),
          ),
          GoRoute(
            path: '/user/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
