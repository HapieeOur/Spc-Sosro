import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.kertas,
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: AppColors.permukaan,
        foregroundColor: AppColors.tinta,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Dashboard Admin SPC Sosro',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.tinta,
          ),
        ),
      ),
    );
  }
}
