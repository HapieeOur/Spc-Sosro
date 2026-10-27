import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';
import 'package:spc_sosro/core/utils/date_formatter.dart';
import 'package:spc_sosro/core/utils/number_formatter.dart';
import 'package:spc_sosro/models/activity_log.dart';
import 'package:spc_sosro/models/dashboard_data.dart';
import 'package:spc_sosro/models/stock_summary.dart';
import 'package:spc_sosro/providers/auth_provider.dart';
import 'package:spc_sosro/providers/dashboard_provider.dart';
import 'package:spc_sosro/screens/admin/users_screen.dart';
import 'package:spc_sosro/widgets/app_button.dart';
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
          color: AppColors.merahSosro,
          onRefresh: () async {
            ref.invalidate(dashboardProvider);
            ref.invalidate(allProfilesProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Hero Sosro Merah Tua Gradasi
                SlatHeaderBackground(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 44, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/images/sosro_logo_cropped.png',
                                    height: 16,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.merahMuda,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'ADMINISTRATOR',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.merahTua,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_today, size: 11, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormatter.formatDate(DateTime.now()),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Halo, ${profile?.fullName ?? "Administrator"}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.daun,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Pusat Kontrol Tally & Inventori Pergudangan',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.merahMuda,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
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

                      // Konten Dinamis Berdasarkan Data
                      dashboardAsync.when(
                        data: (data) => _buildDashboardContent(context, ref, data),
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

  Widget _buildDashboardContent(BuildContext context, WidgetRef ref, DashboardData data) {
    final totalPallets = data.stockByProduct.fold<int>(0, (sum, item) => sum + item.fullPallets);
    final totalBoxes = data.stockByProduct.fold<int>(0, (sum, item) => sum + item.stockBoxes);
    final isBrandNew = data.stockByProduct.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Ringkasan Status Gudang Cepat (KPI Overview Bar)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.permukaan,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.garis),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildMiniOverviewItem(
                label: 'SKU Terdaftar',
                value: '${data.stockByProduct.length}',
                unit: 'Produk',
                color: AppColors.merahSosro,
                icon: Icons.inventory_2_outlined,
              ),
              Container(width: 1, height: 32, color: AppColors.garis),
              _buildMiniOverviewItem(
                label: 'Palet di Gudang',
                value: NumberFormatter.formatNumber(totalPallets),
                unit: 'Palet Utuh',
                color: AppColors.biruTruk,
                icon: Icons.grid_view_rounded,
              ),
              Container(width: 1, height: 32, color: AppColors.garis),
              _buildMiniOverviewItem(
                label: 'Total Stok Fisik',
                value: NumberFormatter.formatNumber(totalBoxes),
                unit: 'Dus',
                color: AppColors.daun,
                icon: Icons.inventory_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Panduan Memulai (Muncul jika produk masih kosong agar tidak membingungkan)
        if (isBrandNew) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.merahMuda,
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.merahSosro.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.merahSosro.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.rocket_launch_rounded, color: AppColors.merahSosro, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inisialisasi Operasional Gudang',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.merahTua,
                            ),
                          ),
                          Text(
                            'Ikuti 3 langkah awal ini untuk memulai sistem tally:',
                            style: TextStyle(fontSize: 11, color: AppColors.abuTinta),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildGuideStep(
                  step: '1',
                  title: 'Tambahkan Master Produk',
                  desc: 'Daftarkan nama produk dan konfigurasi rasio dus per palet.',
                  buttonText: '+ Tambah Produk',
                  onTap: () => context.go('/admin/products'),
                ),
                const SizedBox(height: 10),
                _buildGuideStep(
                  step: '2',
                  title: 'Masukkan Saldo Awal Opname',
                  desc: 'Input stok fisik awal gudang agar kalkulasi mutasi mulai berjalan.',
                  buttonText: 'Atur Saldo',
                  onTap: () => context.go('/admin/settings'),
                ),
                const SizedBox(height: 10),
                _buildGuideStep(
                  step: '3',
                  title: 'Verifikasi Petugas Operator',
                  desc: 'Beri persetujuan (ACC) akun operator yang akan mencatat tally.',
                  buttonText: 'Cek User',
                  onTap: () => context.go('/admin/users'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // 3. Tombol Aksi Pintasan Administrasi
        const Text(
          'Menu Pintasan Administrasi',
          style: TextStyle(
            fontSize: 14,
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
                color: AppColors.merahSosro,
                onTap: () => context.go('/admin/users'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickButton(
                icon: Icons.inventory_2_outlined,
                label: 'Master Produk',
                color: AppColors.biruTruk,
                onTap: () => context.go('/admin/products'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickButton(
                icon: Icons.receipt_long_outlined,
                label: 'Transaksi',
                color: AppColors.tinta,
                onTap: () => context.go('/admin/transactions'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickButton(
                icon: Icons.bar_chart_outlined,
                label: 'Laporan',
                color: AppColors.daun,
                onTap: () => context.go('/admin/reports'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildQuickButton(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Saldo Awal',
                color: AppColors.biruTruk,
                onTap: () => context.go('/admin/settings'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickButton(
                icon: Icons.edit_note_outlined,
                label: 'Koreksi Data',
                color: AppColors.kuningMarka,
                onTap: () => context.go('/admin/corrections'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickButton(
                icon: Icons.history_rounded,
                label: 'Log Audit',
                color: AppColors.abuTinta,
                onTap: () => context.go('/admin/activity'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 4. Aktivitas Tally Hari Ini
        const Text(
          'Mutasi Tally Hari Ini (WIB)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.tinta,
          ),
        ),
        const SizedBox(height: 10),
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

        // 5. Grafik Tren 7 Hari Terakhir
        _buildTrendChart(data.sevenDayTrend),
        const SizedBox(height: 20),

        // 6. Peringatan Stok Menipis (jika ada)
        if (data.lowStock.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.kuningMarkaMuda,
              borderRadius: BorderRadius.circular(10),
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
                      'Peringatan: ${data.lowStock.length} Produk Menipis',
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
                      '• ${item.name}: sisa ${NumberFormatter.formatNumber(item.stockBoxes)} dus (Batas Min: ${NumberFormatter.formatNumber(item.minStockBoxes)} dus)',
                      style: const TextStyle(fontSize: 12, color: AppColors.teksPeringatan),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // 7. Stok Fisik Gudang Saat Ini
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Stok Fisik Gudang Saat Ini',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.tinta,
              ),
            ),
            InkWell(
              onTap: () => context.go('/admin/products'),
              child: Text(
                isBrandNew ? '+ Tambah' : '${data.stockByProduct.length} Produk >',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.merahSosro,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (isBrandNew)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.permukaan,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.garis),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.merahMuda,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.inventory_2_outlined, color: AppColors.merahSosro, size: 36),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Katalog Produk Masih Kosong',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tinta,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tambahkan master produk Sosro untuk mulai memantau tumpukan palet dan stok fisik gudang.',
                  style: TextStyle(fontSize: 12, color: AppColors.abuTinta),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  child: AppButton(
                    text: 'Tambah Produk Sekarang',
                    icon: Icons.add,
                    onPressed: () => context.go('/admin/products'),
                  ),
                ),
              ],
            ),
          )
        else
          ...data.stockByProduct.map((summary) => _buildStockCard(summary)),
        const SizedBox(height: 20),

        // 8. Log Aktivitas Sistem Terkini
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Aktivitas Sistem Terkini',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.tinta,
              ),
            ),
            InkWell(
              onTap: () => context.go('/admin/activity'),
              child: const Text(
                'Lihat Semua >',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.merahSosro,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (data.recentActivity.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.permukaan,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.garis),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.daun.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.verified_outlined, color: AppColors.daun, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audit Trail Aktif',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.tinta),
                      ),
                      Text(
                        'Seluruh transaksi dan perubahan data akan otomatis tercatat di sini.',
                        style: TextStyle(fontSize: 11, color: AppColors.abuTinta),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ...data.recentActivity.take(4).map((activity) => _buildRecentActivityItem(activity)),
        const SizedBox(height: 24),

        // 9. Kartu Standar Operasional Gudang (SOP Tally Sosro)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.permukaan,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.garis),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.merahSosro),
                  const SizedBox(width: 6),
                  const Text(
                    'Pedoman Tally SPC Sosro',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.tinta),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                '• Gunakan palet standar 100 x 120 cm dengan batas tumpukan aman sesuai spesifikasi SKU.\n'
                '• Transaksi yang keliru dicatat wajib dibatalkan melalui menu Semua Transaksi dengan alasan resmi.\n'
                '• Tutup shift harian dengan memeriksa rekap laporan mutasi stok dan mencetak salinan PDF.',
                style: TextStyle(fontSize: 11, color: AppColors.abuTinta, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniOverviewItem({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.tinta,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.abuTinta,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep({
    required String step,
    required String title,
    required String desc,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: AppColors.merahSosro,
          child: Text(
            step,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.tinta),
              ),
              Text(
                desc,
                style: const TextStyle(fontSize: 11, color: AppColors.abuTinta),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.merahSosro,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendChart(List<DayTrend> trends) {
    // Siapkan label 7 hari terakhir
    final now = DateTime.now();
    final List<String> dayLabels = [];
    final List<BarChartGroupData> barGroups = [];

    double maxY = 50;

    const dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    for (int i = 6; i >= 0; i--) {
      final targetDate = now.subtract(Duration(days: i));
      final label = dayNames[targetDate.weekday - 1];
      dayLabels.add(label);

      final matching = trends.cast<DayTrend?>().firstWhere(
            (t) =>
                t != null &&
                t.date.year == targetDate.year &&
                t.date.month == targetDate.month &&
                t.date.day == targetDate.day,
            orElse: () => null,
          );

      final inQty = (matching?.inBoxes ?? 0).toDouble();
      final outQty = (matching?.outBoxes ?? 0).toDouble();

      if (inQty > maxY) maxY = inQty * 1.2;
      if (outQty > maxY) maxY = outQty * 1.2;

      barGroups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: inQty,
              color: AppColors.daun,
              width: 8,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
            ),
            BarChartRodData(
              toY: outQty,
              color: AppColors.biruTruk,
              width: 8,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.permukaan,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.garis),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tren Pergerakan 7 Hari Terakhir',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.tinta),
                  ),
                  Text(
                    'Perbandingan dus masuk vs keluar',
                    style: TextStyle(fontSize: 11, color: AppColors.abuTinta),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildLegend(color: AppColors.daun, label: 'Masuk'),
                  const SizedBox(width: 8),
                  _buildLegend(color: AppColors.biruTruk, label: 'Keluar'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.tinta,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final isIncoming = rodIndex == 0;
                      return BarTooltipItem(
                        '${isIncoming ? "Masuk" : "Keluar"}: ${rod.toY.toInt()} dus',
                        const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          value >= 1000 ? '${(value / 1000).toStringAsFixed(0)}k' : '${value.toInt()}',
                          style: const TextStyle(fontSize: 9, color: AppColors.abuTinta),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= dayLabels.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            dayLabels[idx],
                            style: const TextStyle(fontSize: 10, color: AppColors.abuTinta, fontWeight: FontWeight.w600),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.garis,
                    strokeWidth: 0.8,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.abuTinta, fontWeight: FontWeight.w600),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.permukaan,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.garis),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
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

  Widget _buildStockCard(StockSummary summary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
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
                        fontSize: 13,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: summary.isLowStock ? AppColors.kuningMarka : AppColors.merahSosro,
                    ),
                  ),
                  if (summary.isLowStock)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.kuningMarkaMuda,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Stok Minimum',
                        style: TextStyle(fontSize: 9, color: AppColors.teksPeringatan, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 1, color: AppColors.garis),
          const SizedBox(height: 6),

          // Palet & Baris breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ekuivalen: ${summary.fullPallets} palet + ${summary.looseRows} baris + ${summary.looseBoxes} dus',
                style: const TextStyle(fontSize: 11, color: AppColors.abuTinta),
              ),
              Text(
                'Batas Min: ${summary.minStockBoxes} dus',
                style: const TextStyle(fontSize: 11, color: AppColors.abuTinta),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityItem(ActivityLog activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.permukaan,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.garis),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.merahMuda,
            child: const Icon(Icons.person_outline, size: 16, color: AppColors.merahSosro),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activity.actorNameSnapshot,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.tinta),
                    ),
                    Text(
                      DateFormatter.formatDateTime(activity.createdAt),
                      style: const TextStyle(fontSize: 10, color: AppColors.abuTinta),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  activity.description ?? activity.action,
                  style: const TextStyle(fontSize: 11, color: AppColors.tinta),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
