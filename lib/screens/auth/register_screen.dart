import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';
import 'package:spc_sosro/core/utils/validators.dart';
import 'package:spc_sosro/providers/auth_provider.dart';
import 'package:spc_sosro/widgets/app_button.dart';
import 'package:spc_sosro/widgets/app_text_field.dart';
import 'package:spc_sosro/widgets/fluid_background.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final name = _nameController.text.trim();
      final result = await ref.read(authControllerProvider.notifier).register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: name,
          );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success) {
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _showSuccessDialog(name);
      } else {
        setState(() {
          _errorMessage = result.error;
        });
      }
    }
  }

  void _showSuccessDialog(String fullName) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.permukaan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.merahMuda,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 40,
              color: AppColors.merahSosro,
            ),
          ),
          title: const Text(
            'Registrasi Berhasil!',
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
                'Akun operator atas nama $fullName telah berhasil didaftarkan.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.tinta,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.kuningMarkaMuda,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.kuningMarka.withValues(alpha: 0.5),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 22,
                      color: AppColors.teksPeringatan,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Silakan tunggu persetujuan (ACC) dari Admin gudang sebelum Anda dapat masuk ke aplikasi.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.teksPeringatan,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
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
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ref.read(authControllerProvider.notifier).clearError();
                  context.go('/login');
                },
                child: const Text(
                  'Kembali ke Halaman Masuk',
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
    final isLoading = _isLoading;
    final errorMessage = _errorMessage;

    return Scaffold(
      backgroundColor: const Color(0xFF4A080A),
      body: Column(
        children: [
          // Header Top: Fluid Wave & 3D Spheres with Clean Back Button
          FluidSphereBackground(
            height: 140,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: InkWell(
                    onTap: () {
                      ref.read(authControllerProvider.notifier).clearError();
                      context.go('/login');
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_ios_new,
                            size: 13,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Kembali ke Masuk',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Form Body: Crisp White Sheet with 32dp Top Corners
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
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sosro Brand Logo (Direct transparent integration, no box container!)
                      Image.asset(
                        'assets/images/sosro_logo_transparent.png',
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 14),

                      const Text(
                        'Pendaftaran Operator',
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
                        'Lengkapi data untuk mendaftar akun operator baru.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.abuTinta,
                        ),
                      ),
                      const SizedBox(height: 20),

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
                                color: AppColors.bata,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage,
                                  style: const TextStyle(
                                    color: AppColors.bata,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Nama Lengkap
                      AppTextField(
                        controller: _nameController,
                        label: 'Nama Lengkap',
                        hint: 'Contoh: Budi Santoso',
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: AppColors.abuTinta,
                        ),
                        validator: (v) =>
                            Validators.validateRequired(v, fieldName: 'Nama Lengkap'),
                      ),
                      const SizedBox(height: 14),

                      // Email
                      AppTextField(
                        controller: _emailController,
                        label: 'Alamat Email',
                        hint: 'nama@sosro.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          size: 20,
                          color: AppColors.abuTinta,
                        ),
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 14),

                      // Password
                      AppTextField(
                        controller: _passwordController,
                        label: 'Kata Sandi',
                        hint: 'Minimal 6 karakter',
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          size: 20,
                          color: AppColors.abuTinta,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.abuTinta,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: 14),

                      // Konfirmasi Password
                      AppTextField(
                        controller: _confirmPasswordController,
                        label: 'Konfirmasi Kata Sandi',
                        hint: 'Ketik ulang kata sandi',
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: const Icon(
                          Icons.lock_reset_outlined,
                          size: 20,
                          color: AppColors.abuTinta,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.abuTinta,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Konfirmasi kata sandi wajib diisi';
                          }
                          if (v != _passwordController.text) {
                            return 'Kata sandi tidak cocok';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Notice
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
                              Icons.admin_panel_settings_outlined,
                              size: 18,
                              color: AppColors.merahSosro,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Akun yang baru didaftarkan wajib disetujui (ACC) oleh Administrator sebelum dapat digunakan untuk masuk.',
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
                      const SizedBox(height: 24),

                      // Tombol Daftar
                      AppButton(
                        text: 'Daftar Akun Operator',
                        onPressed: _submit,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Link Kembali ke Login
                      Center(
                        child: TextButton(
                          onPressed: () {
                            ref.read(authControllerProvider.notifier).clearError();
                            context.go('/login');
                          },
                          child: const Text.rich(
                            TextSpan(
                              text: 'Sudah punya akun? ',
                              style: TextStyle(color: AppColors.abuTinta),
                              children: [
                                TextSpan(
                                  text: 'Masuk di sini',
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
