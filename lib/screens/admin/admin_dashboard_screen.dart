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
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.merahSosro,
          onRefresh: () async {
            ref.invalidate(dashboardProvider);
            ref.invalidate(allProfilesProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Header Bar (Modern Clean Bar)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/sosro_logo_cropped.png',
                                height: 18,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'SPC Pallet Counter',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.abuTinta,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.tinta,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),

                    // Tombol Refresh / Notifikasi
                    InkWell(
                      onTap: () {
                        ref.invalidate(dashboardProvider);
                        ref.invalidate(allProfilesProvider);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.tinta,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Greeting Card (seperti "Your greeting!" pada referensi gambar)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.merahMuda,
                        child: Text(
                          (profile?.fullName.isNotEmpty ?? false)
                              ? profile!.fullName[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.merahSosro,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selamat Bertugas,',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.abuTinta,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              profile?.fullName ?? 'Administrator Gudang',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.tinta,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.merahMuda,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Admin Gudang',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.merahTua,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormatter.formatDate(DateTime.now()),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.abuTinta,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.warehouse_outlined,
                          size: 20,
                          color: AppColors.merahSosro,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Banner Antrean ACC Operator (Jika Ada Akun Baru)
                if (pendingCount > 0) ...[
                  InkWell(
                    onTap: () => context.go('/admin/users'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.kuningMarkaMuda,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.kuningMarka.withValues(alpha: 0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.kuningMarka.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.hourglass_top_rounded,
                              color: AppColors.teksPeringatan,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$pendingCount Akun Operator Menunggu ACC',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    color: AppColors.teksPeringatan,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Ketuk untuk memeriksa dan menyetujui akun operator baru.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.teksPeringatan,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.teksPeringatan,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 4. Konten Dinamis Data Dashboard
                dashboardAsync.when(
                  data: (data) => _buildModernDashboardContent(context, ref, data, pendingCount),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: LoadingView(message: 'Memuat data analitik stok...'),
                  ),
                  error: (err, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: ErrorView(
                      message: err.toString(),
                      onRetry: () => ref.invalidate(dashboardProvider),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernDashboardContent(
    BuildContext context,
    WidgetRef ref,
    DashboardData data,
    int pendingCount,
  ) {
    final totalPallets = data.stockByProduct.fold<int>(0, (sum, item) => sum + item.fullPallets);
    final totalBoxes = data.stockByProduct.fold<int>(0, (sum, item) => sum + item.stockBoxes);
    final isBrandNew = data.stockByProduct.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Grid 2x2 Metric Cards (Gaya Taktil Modern dengan Squircle Icon Badge)
        Row(
          children: [
            Expanded(
              child: _buildTactileCard(
                label: 'Barang Masuk',
                value: '${NumberFormatter.formatNumber(data.todayInBoxes)} Dus',
                subtitle: '≈ ${NumberFormatter.formatDecimal(data.todayInPalletEquivalent)} Palet',
                icon: Icons.south_west_rounded,
                iconColor: const Color(0xFF15803D),
                iconBgColor: const Color(0xFFDCFCE7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTactileCard(
                label: 'Barang Keluar',
                value: '${NumberFormatter.formatNumber(data.todayOutBoxes)} Dus',
                subtitle: '≈ ${NumberFormatter.formatDecimal(data.todayOutPalletEquivalent)} Palet',
                icon: Icons.north_east_rounded,
                iconColor: AppColors.merahSosro,
                iconBgColor: const Color(0xFFFEE2E2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTactileCard(
                label: 'Stok Fisik Gudang',
                value: '${NumberFormatter.formatNumber(totalBoxes)} Dus',
                subtitle: '${NumberFormatter.formatNumber(totalPallets)} Palet Utuh',
                icon: Icons.inventory_2_outlined,
                iconColor: AppColors.biruTruk,
                iconBgColor: const Color(0xFFDBEAFE),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTactileCard(
                label: 'Antrean ACC',
                value: '$pendingCount Akun',
                subtitle: pendingCount > 0 ? 'Perlu ACC Admin' : 'Semua Terverifikasi',
                icon: Icons.people_alt_outlined,
                iconColor: const Color(0xFFD97706),
                iconBgColor: const Color(0xFFFEF3C7),
                onTap: () => context.go('/admin/users'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 2. Analytics Card (Gaya Layar "analytics" pada referensi)
        _buildAnalyticsCard(data.sevenDayTrend),
        const SizedBox(height: 20),

        // 3. Quick Action Grid (Gaya 4 Kartu "Quick Action" pada referensi)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.tinta,
              ),
            ),
            InkWell(
              onTap: () => context.go('/admin/transactions'),
              child: const Text(
                'Lihat Riwayat >',
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
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.receipt_long_outlined,
                label: 'Transaksi',
                subtitle: 'Pencatatan',
                tintColor: AppColors.merahSosro,
                tintBg: const Color(0xFFFEE2E2),
                onTap: () => context.go('/admin/transactions'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                icon: Icons.inventory_2_outlined,
                label: 'Produk',
                subtitle: 'Master SKU',
                tintColor: AppColors.biruTruk,
                tintBg: const Color(0xFFDBEAFE),
                onTap: () => context.go('/admin/products'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                icon: Icons.bar_chart_outlined,
                label: 'Laporan',
                subtitle: 'PDF & CSV',
                tintColor: const Color(0xFF15803D),
                tintBg: const Color(0xFFDCFCE7),
                onTap: () => context.go('/admin/reports'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                icon: Icons.people_outline_rounded,
                label: 'Pengguna',
                subtitle: 'ACC Operator',
                tintColor: const Color(0xFFD97706),
                tintBg: const Color(0xFFFEF3C7),
                onTap: () => context.go('/admin/users'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // 4. Peringatan Stok Menipis (Jika Ada)
        if (data.lowStock.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.kuningMarkaMuda,
              borderRadius: BorderRadius.circular(18),
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
                      'Peringatan: ${data.lowStock.length} Varian Stok Menipis',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
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
                      '• ${item.name}: sisa ${NumberFormatter.formatNumber(item.stockBoxes)} dus (Batas Minimum: ${NumberFormatter.formatNumber(item.minStockBoxes)} dus)',
                      style: const TextStyle(fontSize: 12, color: AppColors.teksPeringatan),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // 5. Ringkasan Stok Produk (Gaya "Product Feed" pada referensi)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Stok Produk Gudang',
              style: TextStyle(
                fontSize: 15,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
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
                  'Tambahkan master produk Sosro untuk mulai memantau tumpukan palet dan mutasi gudang.',
                  style: TextStyle(fontSize: 12, color: AppColors.abuTinta),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  child: AppButton(
                    text: 'Tambah Produk',
                    icon: Icons.add,
                    onPressed: () => context.go('/admin/products'),
                  ),
                ),
              ],
            ),
          )
        else
          ...data.stockByProduct.take(5).map((summary) => _buildModernStockCard(summary)),
        const SizedBox(height: 20),

        // 6. Aktivitas Sistem Terkini (Gaya "Project Feed" pada referensi)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Aktivitas Terkini',
              style: TextStyle(
                fontSize: 15,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_outlined, color: Color(0xFF15803D), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Audit trail aktif: setiap mutasi transaksi dan persetujuan akun akan tercatat di sini.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.abuTinta),
                  ),
                ),
              ],
            ),
          )
        else
          ...data.recentActivity.take(4).map((activity) => _buildModernActivityItem(activity)),
      ],
    );
  }

  // Komponen Kartu Metrik Taktil (2x2 Grid)
  Widget _buildTactileCard({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.tinta,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.abuTinta,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10.5,
                color: Color(0xFF94A3B8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Komponen Kartu Grafik Analitik 7 Hari
  Widget _buildAnalyticsCard(List<DayTrend> trends) {
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
              color: const Color(0xFF16A34A),
              width: 9,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            BarChartRodData(
              toY: outQty,
              color: AppColors.merahSosro,
              width: 9,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                    'Analisis Mutasi Stok',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tinta,
                    ),
                  ),
                  Text(
                    'Perbandingan arus dus masuk & keluar',
                    style: TextStyle(fontSize: 11, color: AppColors.abuTinta),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '7 Hari Terakhir',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.abuTinta,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 145,
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
                          padding: const EdgeInsets.only(top: 6),
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
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Color(0xFFF1F5F9),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendPill(color: const Color(0xFF16A34A), label: 'Stok Masuk'),
              const SizedBox(width: 14),
              _buildLegendPill(color: AppColors.merahSosro, label: 'Stok Keluar'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendPill({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.abuTinta, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // Komponen Action Tile Cepat
  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color tintColor,
    required Color tintBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tintBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: tintColor, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.tinta,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 9.5,
                color: Color(0xFF94A3B8),
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

  // Komponen Kartu Stok Produk Modern
  Widget _buildModernStockCard(StockSummary summary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: summary.isLowStock ? AppColors.kuningMarka : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        summary.code,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tinta,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary.name,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tinta,
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
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.kuningMarkaMuda,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Stok Menipis',
                        style: TextStyle(fontSize: 9.5, color: AppColors.teksPeringatan, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ekuivalen: ${summary.fullPallets} palet + ${summary.looseRows} baris + ${summary.looseBoxes} dus',
                style: const TextStyle(fontSize: 11, color: AppColors.abuTinta),
              ),
              Text(
                'Batas Min: ${summary.minStockBoxes} dus',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Komponen Riwayat Aktivitas Modern
  Widget _buildModernActivityItem(ActivityLog activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.merahMuda,
            child: const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.merahSosro),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activity.actorNameSnapshot,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.tinta),
                    ),
                    Text(
                      DateFormatter.formatDateTime(activity.createdAt),
                      style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  activity.description ?? activity.action,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.abuTinta),
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
