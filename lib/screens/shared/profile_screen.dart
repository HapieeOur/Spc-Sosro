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
    final isAdmin = profile?.role == AppRole.admin;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: AppColors.tinta,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: profile == null
          ? const Center(child: Text('Profil tidak ditemukan'))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              child: Column(
                children: [
                  // 1. Hero Profile Card (Gaya Kartu "Profile" pada referensi gambar)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundColor: AppColors.merahMuda,
                              child: Text(
                                profile.fullName.isNotEmpty
                                    ? profile.fullName[0].toUpperCase()
                                    : 'A',
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.merahSosro,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.merahSosro,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          profile.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.tinta,
                            letterSpacing: -0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.merahMuda,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.merahSosro.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            isAdmin ? 'Administrator Gudang' : 'Operator Tally Lapangan',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.merahSosro,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 14),
                        Image.asset(
                          'assets/images/sosro_logo_cropped.png',
                          height: 22,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Grouped Settings Section (Gaya "Settings" pada referensi gambar)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSettingItem(
                          icon: Icons.shield_outlined,
                          title: 'Peran Akun',
                          subtitle: isAdmin ? 'Akses Penuh Administrator' : 'Pencatatan Tally Operator',
                          trailingText: isAdmin ? 'Admin' : 'Operator',
                        ),
                        const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                        _buildSettingItem(
                          icon: Icons.verified_user_outlined,
                          title: 'Status Akun',
                          subtitle: 'Terverifikasi & Diizinkan Masuk',
                          trailingText: 'Aktif',
                          trailingColor: AppColors.merahSosro,
                        ),
                        const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                        _buildSettingItem(
                          icon: Icons.lock_outline_rounded,
                          title: 'Kata Sandi',
                          subtitle: 'Terenkripsi aman oleh sistem autentikasi',
                          trailingText: '••••••••',
                        ),
                        const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                        _buildSettingItem(
                          icon: Icons.info_outline_rounded,
                          title: 'Versi Aplikasi',
                          subtitle: 'SPC Pallet Counter PT Sinar Sosro',
                          trailingText: 'v1.0.0',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Tombol Keluar (Merah-Putih Bersih)
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: 'Keluar dari Aplikasi',
                      variant: AppButtonVariant.danger,
                      icon: Icons.logout_rounded,
                      onPressed: () async {
                        final confirmed = await ConfirmDialog.show(
                          context,
                          title: 'Konfirmasi Keluar',
                          message: 'Apakah Anda yakin ingin keluar dari akun ini?',
                          confirmText: 'Ya, Keluar',
                          isDestructive: true,
                        );
                        if (confirmed == true) {
                          ref.read(authControllerProvider.notifier).logout();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String trailingText,
    Color? trailingColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.merahMuda,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.merahSosro),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tinta,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Text(
            trailingText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: trailingColor ?? AppColors.abuTinta,
            ),
          ),
        ],
      ),
    );
  }
}
