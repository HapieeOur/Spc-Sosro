import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';
import 'package:spc_sosro/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.permukaan,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/sosro_logo.png',
              width: 260,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            const Text(
              'SPC PALLET COUNTER',
              style: TextStyle(
                fontFamily: 'BarlowSemiCondensed',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.tinta,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sistem Pencatatan & Kontrol Palet Gudang',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.abuTinta,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.merahSosro,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
