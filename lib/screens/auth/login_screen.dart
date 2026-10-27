import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';
import 'package:spc_sosro/core/utils/validators.dart';
import 'package:spc_sosro/providers/auth_provider.dart';
import 'package:spc_sosro/widgets/app_button.dart';
import 'package:spc_sosro/widgets/app_text_field.dart';
import 'package:spc_sosro/widgets/fluid_background.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentAuth = ref.read(authControllerProvider);
      if (currentAuth is AuthStateDenied) {
        _showPendingApprovalDialog(currentAuth.message);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final result = await ref.read(authControllerProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (!mounted) return;
      if (result.isDenied) {
        _showPendingApprovalDialog(result.message ?? '');
      }
    }
  }

  void _showPendingApprovalDialog(String message) {
    if (_isDialogOpen) return;
    _isDialogOpen = true;

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.permukaan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.kuningMarka.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_clock_rounded,
              size: 44,
              color: AppColors.kuningMarka,
            ),
          ),
          title: const Text(
            'Akun Belum Teraktivasi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.tinta,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.isNotEmpty
                    ? message
                    : 'Akun Anda saat ini belum aktif atau masih menunggu persetujuan (ACC) dari Administrator gudang.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.tinta,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.kertas,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.garis),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: AppColors.kuningMarka,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Silakan hubungi Administrator gudang untuk mengaktivasi akun Anda sebelum dapat masuk ke aplikasi.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.abuTinta,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.merahSosro,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Mengerti',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      _isDialogOpen = false;
      ref.read(authControllerProvider.notifier).clearError();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthStateDenied) {
        _showPendingApprovalDialog(next.message);
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthStateLoading;
    String? errorMessage;

    // HANYA tampilkan notif error inline jika BUKAN masalah akun belum aktif
    if (authState is AuthStateError) {
      errorMessage = authState.message;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF4A080A),
      body: Column(
        children: [
          // Top Header: Fluid Wave & 3D Spheres Background
          FluidSphereBackground(
            height: 220,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warehouse_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'WMS PALLET COUNTER',
                            style: TextStyle(
                              fontFamily: 'BarlowSemiCondensed',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'PT Sinar Sosro',
                      style: TextStyle(
                        fontFamily: 'BarlowSemiCondensed',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Pusat Distribusi & Kontrol Stok Palet',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Sheet: White surface with 32dp top rounded corners
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.permukaan,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sosro Brand Logo (Direct transparent integration, no box container!)
                      Image.asset(
                        'assets/images/sosro_logo_transparent.png',
                        height: 38,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 14),

                      const Text(
                        'Masuk ke Akun',
                        style: TextStyle(
                          fontFamily: 'BarlowSemiCondensed',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tinta,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),

                      const Text(
                        'Silakan masuk untuk mencatat dan memantau stok gudang.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.abuTinta,
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.bataMuda,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.bata.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 20,
                                color: AppColors.bata,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  errorMessage,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.bata,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'nama@sosro.com',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          size: 20,
                          color: AppColors.abuTinta,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 16),

                      AppTextField(
                        controller: _passwordController,
                        label: 'Kata Sandi',
                        hint: 'Masukkan kata sandi',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          size: 20,
                          color: AppColors.abuTinta,
                        ),
                        obscureText: _obscurePassword,
                        validator: Validators.validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.abuTinta,
                          ),
                          tooltip: _obscurePassword
                              ? 'Tampilkan kata sandi'
                              : 'Sembunyikan kata sandi',
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 28),

                      AppButton(
                        text: 'Masuk',
                        isLoading: isLoading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            ref.read(authControllerProvider.notifier).clearError();
                            context.go('/register');
                          },
                          child: const Text.rich(
                            TextSpan(
                              text: 'Belum punya akun? ',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.abuTinta,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Daftar Operator',
                                  style: TextStyle(
                                    color: AppColors.merahSosro,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
