import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spc_sosro/providers/auth_provider.dart';
import 'package:spc_sosro/widgets/fluid_background.dart';

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
      body: FluidSphereBackground(
        isFullScreen: true,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Brand Presentation (Direct integration without any box container)
              Image.asset(
                'assets/images/sosro_logo_white.png',
                height: 52,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 18),

              const Text(
                'SPC PALLET COUNTER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'BarlowSemiCondensed',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 6),

              Text(
                'Sistem Pencatatan Stok Gudang PT Sinar Sosro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.85),
                  letterSpacing: 0.2,
                ),
              ),

              const Spacer(flex: 3),

              // Modern Minimalist Loading Indicator
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Platform Footer
              Text(
                'PT Rekso WMS Platform • v1.0.0',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
