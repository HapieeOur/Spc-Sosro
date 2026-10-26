import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';
import 'package:spc_sosro/core/utils/date_formatter.dart';
import 'package:spc_sosro/core/utils/number_formatter.dart';
import 'package:spc_sosro/models/stock_summary.dart';
import 'package:spc_sosro/providers/dashboard_provider.dart';
import 'package:spc_sosro/widgets/empty_state.dart';
import 'package:spc_sosro/widgets/error_view.dart';
import 'package:spc_sosro/widgets/loading_view.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  final DateTime _endDate = DateTime.now();

  Future<void> _exportCsv(List<StockSummary> data) async {
    try {
      final rows = <List<dynamic>>[];
      // Header CSV
      rows.add([
        'Kode Produk',
        'Nama Produk',
        'Stok Awal (Dus)',
        'Masuk (Dus)',
        'Keluar (Dus)',
        'Stok Akhir (Dus)',
        'Palet Utuh',
        'Baris Sisa',
        'Karton Sisa',
        'Status Stok'
      ]);

      // Data Rows
      for (final item in data) {
        rows.add([
          item.code,
          item.name,
          item.openingBoxes,
          item.inBoxes,
          item.outBoxes,
          item.stockBoxes,
          item.fullPallets,
          item.looseRows,
          item.looseBoxes,
          item.isLowStock ? 'DI BAWAH MINIMUM' : 'AMAN'
        ]);
      }

      final csvData = const ListToCsvConverter().convert(rows);
      final directory = await getTemporaryDirectory();
      final dateStr = DateFormatter.formatDate(_endDate).replaceAll(' ', '_');
      final path = '${directory.path}/Laporan_Mutasi_Stok_$dateStr.csv';
      final file = File(path);
      await file.writeAsString(csvData);

      await Share.shareXFiles(
        [XFile(path)],
        text: 'Laporan Rekapitulasi Stok SPC Sosro ($dateStr)',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengekspor CSV: $e'),
            backgroundColor: AppColors.bata,
          ),
        );
      }
    }
  }

  Future<void> _exportPdf(List<StockSummary> data) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return [
              // Header Formal Dokumen
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SPC SOSRO PALLET COUNTER',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Laporan Rekapitulasi Mutasi Stok Gudang',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Tanggal Cetak: ${DateFormatter.formatDate(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Periode: ${DateFormatter.formatDate(_startDate)} - ${DateFormatter.formatDate(_endDate)}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 12),

              // Tabel Data
              pw.TableHelper.fromTextArray(
                headers: [
                  'Kode',
                  'Nama Produk',
                  'Awal',
                  'Masuk',
                  'Keluar',
                  'Akhir',
                  'Palet',
                  'Status'
                ],
                data: data.map((item) {
                  return [
                    item.code,
                    item.name,
                    '${item.openingBoxes}',
                    '${item.inBoxes}',
                    '${item.outBoxes}',
                    '${item.stockBoxes}',
                    '${item.fullPallets}P+${item.looseRows}B+${item.looseBoxes}D',
                    item.isLowStock ? 'MENIPIS' : 'AMAN',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFBA0202), // Merah Sinar Sosro
                ),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                  ),
                ),
              ),

              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Dicetak oleh Admin Gudang',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 40),
                      pw.Text(
                        '( ___________________ )',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Laporan_Rekap_Stok_Sosro.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencetak PDF: $e'),
            backgroundColor: AppColors.bata,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stockDataAsync = ref.watch(stockSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.kertas,
      appBar: AppBar(
        title: const Text(
          'Laporan Rekapitulasi Stok',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.tinta,
          ),
        ),
        backgroundColor: AppColors.permukaan,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: stockDataAsync.when(
        data: (stockList) {
          if (stockList.isEmpty) {
            return const EmptyState(
              title: 'Belum Ada Data Stok',
              subtitle: 'Data mutasi stok gudang belum tersedia.',
              icon: Icons.bar_chart_outlined,
            );
          }

          final totalAwal = stockList.fold<int>(0, (sum, i) => sum + i.openingBoxes);
          final totalMasuk = stockList.fold<int>(0, (sum, i) => sum + i.inBoxes);
          final totalKeluar = stockList.fold<int>(0, (sum, i) => sum + i.outBoxes);
          final totalAkhir = stockList.fold<int>(0, (sum, i) => sum + i.stockBoxes);

          return Column(
            children: [
              // Panel Tombol Ekspor
              Container(
                color: AppColors.permukaan,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.daun,
                          side: const BorderSide(color: AppColors.daun),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        icon: const Icon(Icons.table_chart_outlined, size: 18),
                        label: const Text('Ekspor CSV', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () => _exportCsv(stockList),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.daun,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                        label: const Text('Cetak PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () => _exportPdf(stockList),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.garis),

              // Kartu Ringkasan Mutasi Total
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.permukaan,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.garis),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem('Stok Awal', '$totalAwal', AppColors.abuTinta),
                      Container(width: 1, height: 32, color: AppColors.garis),
                      _buildSummaryItem('Total Masuk', '+$totalMasuk', AppColors.daun),
                      Container(width: 1, height: 32, color: AppColors.garis),
                      _buildSummaryItem('Total Keluar', '-$totalKeluar', AppColors.biruTruk),
                      Container(width: 1, height: 32, color: AppColors.garis),
                      _buildSummaryItem('Sisa Akhir', '$totalAkhir', AppColors.tinta),
                    ],
                  ),
                ),
              ),

              // Daftar Laporan Per Produk
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: stockList.length,
                  separatorBuilder: (_, unused) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = stockList[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.permukaan,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: item.isLowStock ? AppColors.kuningMarka : AppColors.garis,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.tinta,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: item.isLowStock
                                      ? AppColors.kuningMarkaMuda
                                      : AppColors.daunMuda,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.isLowStock ? 'STOK MENIPIS' : 'AMAN',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: item.isLowStock
                                        ? AppColors.teksPeringatan
                                        : AppColors.daunTua,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Awal: ${item.openingBoxes} | +${item.inBoxes} | -${item.outBoxes}',
                                style: const TextStyle(fontSize: 12, color: AppColors.abuTinta),
                              ),
                              Text(
                                'Akhir: ${NumberFormatter.formatNumber(item.stockBoxes)} Dus',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.tinta,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Susunan: ${item.fullPallets} palet + ${item.looseRows} baris + ${item.looseBoxes} dus',
                            style: const TextStyle(fontSize: 11, color: AppColors.abuTinta),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingView(message: 'Membuat rekapitulasi laporan...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(stockSummaryProvider),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.abuTinta)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
