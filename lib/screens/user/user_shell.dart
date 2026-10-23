import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';

class UserShell extends StatelessWidget {
  final Widget child;

  const UserShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/user/history')) return 1;
    if (location.startsWith('/user/profile')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/user/dashboard');
        break;
      case 1:
        context.go('/user/history');
        break;
      case 2:
        context.go('/user/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        backgroundColor: AppColors.permukaan,
        indicatorColor: AppColors.daunMuda,
        elevation: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2, color: AppColors.daun),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: AppColors.daun),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.daun),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
