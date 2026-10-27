import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';
import 'package:spc_sosro/core/utils/validators.dart';
import 'package:spc_sosro/providers/auth_provider.dart';
import 'package:spc_sosro/widgets/app_button.dart';
import 'package:spc_sosro/widgets/app_text_field.dart';
import 'package:spc_sosro/widgets/slat_pattern.dart';

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

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  void _showPendingApprovalDialog(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.permukaan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.kuningMarkaMuda,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              size: 40,
              color: AppColors.teksPeringatan,
            ),
          ),
          title: const Text(
            'Akun Belum Disetujui',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
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
                    : 'Akun Anda saat ini masih menunggu persetujuan (ACC) dari Administrator gudang.',
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
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.garis),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: AppColors.teksPeringatan,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Silakan hubungi Administrator gudang untuk mengaktifkan akun Anda sebelum dapat masuk.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.abuTinta,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.merahSosro,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Mengerti',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
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

    if (authState is AuthStateError) {
      errorMessage = authState.message;
    } else if (authState is AuthStateDenied) {
      errorMessage = authState.message;
    }

    return Scaffold(
      backgroundColor: AppColors.daunTua,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Half: SlatPattern Hero with 3 pallet blocks and brand wordmark
            SlatHeaderBackground(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/sosro_logo_cropped.png',
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'SPC Pallet Counter',
                      style: TextStyle(
                        fontFamily: 'BarlowSemiCondensed',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Text(
                      'Sistem Pencatatan Stok Gudang',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.merahMuda,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Sheet: White surface with 20dp top rounded corners
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.permukaan,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Masuk untuk mencatat stok gudang.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColors.abuTinta,
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.bataMuda,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.bata.withValues(alpha: 0.3)),
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
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 16),

                        AppTextField(
                          controller: _passwordController,
                          label: 'Kata sandi',
                          hint: 'Masukkan kata sandi',
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
                                      color: AppColors.daun,
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
      ),
    );
  }
}
