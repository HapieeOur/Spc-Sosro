import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';
import 'package:spc_sosro/core/utils/date_formatter.dart';
import 'package:spc_sosro/core/utils/number_formatter.dart';
import 'package:spc_sosro/models/dashboard_data.dart';
import 'package:spc_sosro/models/stock_summary.dart';
import 'package:spc_sosro/providers/auth_provider.dart';
import 'package:spc_sosro/providers/dashboard_provider.dart';
import 'package:spc_sosro/screens/admin/users_screen.dart';
import 'package:spc_sosro/widgets/error_view.dart';
import 'package:spc_sosro/widgets/loading_view.dart';
import 'package:spc_sosro/widgets/slat_pattern.dart';
import 'package:spc_sosro/widgets/stat_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final dashboardAsync = ref.watch(dashboardProvider);
    final profilesAsync = ref.watch(allProfilesProvider);

    final pendingCount = profilesAsync.maybeWhen(
      data: (list) => list.where((p) => !p.isActive).length,
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: AppColors.kertas,
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.daun,
          onRefresh: () async {
            ref.invalidate(dashboardProvider);
            ref.invalidate(allProfilesProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Hero Sosro Daun Tua
                SlatHeaderBackground(
                  height: 190,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.daunMuda,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PANEL ADMINISTRATOR',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.daunTua,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Text(
                              DateFormatter.formatDate(DateTime.now()),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.daunMuda,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Halo, ${profile?.fullName ?? "Administrator"}',
                          style: const TextStyle(
                            fontFamily: 'BarlowSemiCondensed',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Ringkasan kontrol dan stok gudang SPC Sosro',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.daunMuda,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Antrean ACC Operator
                      if (pendingCount > 0) ...[
                        InkWell(
                          onTap: () => context.go('/admin/users'),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.kuningMarkaMuda,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.kuningMarka.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.person_add_alt_1, color: AppColors.teksPeringatan, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$pendingCount Operator Menunggu ACC',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: AppColors.teksPeringatan,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Ketuk untuk melihat dan menyetujui akun baru.',
                                        style: TextStyle(fontSize: 12, color: AppColors.teksPeringatan),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.teksPeringatan),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Quick Shortcut Buttons
                      const Text(
                        'Aksi Cepat',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tinta,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickButton(
                              icon: Icons.people_outline,
                              label: 'Kelola User',
                              color: AppColors.daun,
                              onTap: () => context.go('/admin/users'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildQuickButton(
                              icon: Icons.inventory_2_outlined,
                              label: 'Master Produk',
                              color: AppColors.biruTruk,
                              onTap: () => context.go('/admin/products'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildQuickButton(
                              icon: Icons.receipt_long_outlined,
                              label: 'Semua Transaksi',
                              color: AppColors.tinta,
                              onTap: () => context.go('/admin/transactions'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Ringkasan Hari Ini
                      const Text(
                        'Aktivitas Tally Hari Ini',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tinta,
                        ),
                      ),
                      const SizedBox(height: 10),

                      dashboardAsync.when(
                        data: (data) => _buildDashboardContent(context, data),
                        loading: () => const LoadingView(message: 'Memuat data analitik stok...'),
                        error: (err, _) => ErrorView(
                          message: err.toString(),
                          onRetry: () => ref.invalidate(dashboardProvider),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.permukaan,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.garis),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.tinta,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kartu Metrik Masuk & Keluar Hari Ini
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Barang Masuk',
                value: NumberFormatter.formatNumber(data.todayInBoxes),
                subtitle: '${NumberFormatter.formatDecimal(data.todayInPalletEquivalent)} palet',
                color: AppColors.daun,
                icon: Icons.south_west_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Barang Keluar',
                value: NumberFormatter.formatNumber(data.todayOutBoxes),
                subtitle: '${NumberFormatter.formatDecimal(data.todayOutPalletEquivalent)} palet',
                color: AppColors.biruTruk,
                icon: Icons.north_east_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Peringatan Stok Menipis
        if (data.lowStock.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.kuningMarkaMuda,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.kuningMarka.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.teksPeringatan, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Peringatan: ${data.lowStock.length} Produk di Bawah Batas Minimum!',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.teksPeringatan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...data.lowStock.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '• ${item.name}: sisa ${NumberFormatter.formatNumber(item.stockBoxes)} dus (Min: ${NumberFormatter.formatNumber(item.minStockBoxes)} dus)',
                      style: const TextStyle(fontSize: 12, color: AppColors.teksPeringatan),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Daftar Stok Produk Gudang Saat Ini
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Stok Fisik Gudang Saat Ini',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.tinta,
              ),
            ),
            Text(
              '${data.stockByProduct.length} Produk',
              style: const TextStyle(fontSize: 12, color: AppColors.abuTinta),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (data.stockByProduct.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.permukaan,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.garis),
            ),
            child: const Center(
              child: Text(
                'Belum ada data stok produk tercatat.',
                style: TextStyle(color: AppColors.abuTinta),
              ),
            ),
          )
        else
          ...data.stockByProduct.map((summary) => _buildStockCard(summary)),
      ],
    );
  }

  Widget _buildStockCard(StockSummary summary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.permukaan,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: summary.isLowStock ? AppColors.kuningMarka : AppColors.garis,
          width: summary.isLowStock ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tinta,
                      ),
                    ),
                    Text(
                      summary.code,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.abuTinta,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${NumberFormatter.formatNumber(summary.stockBoxes)} Dus',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: summary.isLowStock ? AppColors.kuningMarka : AppColors.daun,
                    ),
                  ),
                  if (summary.isLowStock)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.kuningMarkaMuda,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Di bawah minimum',
                        style: TextStyle(fontSize: 10, color: AppColors.teksPeringatan, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.garis),
          const SizedBox(height: 8),

          // Palet & Baris breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ekuivalen: ${summary.fullPallets} palet + ${summary.looseRows} baris + ${summary.looseBoxes} dus',
                style: const TextStyle(fontSize: 11, color: AppColors.abuTinta),
              ),
              Text(
                'Min: ${summary.minStockBoxes} dus',
                style: const TextStyle(fontSize: 11, color: AppColors.abuTinta),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
