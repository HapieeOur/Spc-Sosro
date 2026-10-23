import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spc_sosro/core/constants/app_constants.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';
import 'package:spc_sosro/providers/auth_provider.dart';
import 'package:spc_sosro/widgets/app_button.dart';
import 'package:spc_sosro/widgets/confirm_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: profile == null
          ? const Center(child: Text('Profil tidak ditemukan'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primary100,
                          child: Text(
                            profile.fullName.isNotEmpty
                                ? profile.fullName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: profile.role == AppRole.admin
                                ? AppColors.primary100
                                : AppColors.infoBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            profile.role == AppRole.admin
                                ? 'Administrator'
                                : 'Operator Gudang',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: profile.role == AppRole.admin
                                  ? AppColors.primary700
                                  : AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Keluar',
                    variant: AppButtonVariant.danger,
                    icon: Icons.logout_rounded,
                    onPressed: () async {
                      final confirmed = await ConfirmDialog.show(
                        context,
                        title: 'Konfirmasi Keluar',
                        message: 'Apakah Anda yakin ingin keluar dari aplikasi?',
                        confirmText: 'Keluar',
                        isDestructive: true,
                      );
                      if (confirmed == true) {
                        ref.read(authControllerProvider.notifier).logout();
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
