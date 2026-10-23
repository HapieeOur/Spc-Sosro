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

  @override
  Widget build(BuildContext context) {
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
                    // 3 Pallet blocks brand icon
                    Row(
                      children: [
                        _buildMiniPallet(),
                        const SizedBox(width: 4),
                        _buildMiniPallet(),
                        const SizedBox(width: 4),
                        _buildMiniPallet(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'SPC Sosro',
                      style: TextStyle(
                        fontFamily: 'BarlowSemiCondensed',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.0,
                      ),
                    ),
                    const Text(
                      'Pallet Counter',
                      style: TextStyle(
                        fontFamily: 'BarlowSemiCondensed',
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: AppColors.daunMuda,
                        height: 1.2,
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
                            onPressed: () => context.go('/register'),
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

  Widget _buildMiniPallet() {
    return Container(
      width: 18,
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.daunMuda,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 3,
          color: AppColors.kayu,
        ),
      ),
    );
  }
}
