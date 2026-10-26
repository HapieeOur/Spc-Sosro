import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spc_sosro/core/constants/app_constants.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';
import 'package:spc_sosro/core/utils/date_formatter.dart';
import 'package:spc_sosro/core/utils/number_formatter.dart';
import 'package:spc_sosro/core/utils/validators.dart';
import 'package:spc_sosro/models/stock_transaction.dart';
import 'package:spc_sosro/providers/transaction_form_provider.dart';
import 'package:spc_sosro/widgets/app_button.dart';
import 'package:spc_sosro/widgets/app_text_field.dart';
import 'package:spc_sosro/widgets/empty_state.dart';
import 'package:spc_sosro/widgets/error_view.dart';
import 'package:spc_sosro/widgets/loading_view.dart';
import 'package:spc_sosro/widgets/status_chip.dart';

final adminSelectedTypeProvider = StateProvider.autoDispose<TransactionType?>((ref) => null);

final adminTransactionsProvider = FutureProvider.autoDispose<List<StockTransaction>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final filterType = ref.watch(adminSelectedTypeProvider);
  return repo.fetchTransactions(type: filterType, limit: 50);
});

class AllTransactionsScreen extends ConsumerWidget {
  const AllTransactionsScreen({super.key});

  void _showVoidDialog(BuildContext context, WidgetRef ref, StockTransaction tx) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.permukaan,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.bata),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Batalkan Transaksi (Void)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tinta,
                      ),
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaksi: ${tx.transactionNo}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.tinta,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${NumberFormatter.formatNumber(tx.totalBoxes)} dus (${NumberFormatter.formatDecimal(tx.totalPalletEquivalent)} palet)',
                      style: const TextStyle(fontSize: 12, color: AppColors.abuTinta),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: reasonController,
                      label: 'Alasan Pembatalan',
                      hint: 'Minimal 10 karakter...',
                      maxLines: 3,
                      validator: Validators.validateCorrectionReason,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('Batal', style: TextStyle(color: AppColors.abuTinta)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bata,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() ?? false) {
                            setState(() => isSubmitting = true);
                            try {
                              await ref.read(transactionRepositoryProvider).voidTransaction(
                                    transactionId: tx.id,
                                    reason: reasonController.text.trim(),
                                  );
                              if (context.mounted) {
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Transaksi berhasil dibatalkan (VOID).'),
                                    backgroundColor: AppColors.bata,
                                  ),
                                );
                                ref.invalidate(adminTransactionsProvider);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal membatalkan transaksi: $e'),
                                    backgroundColor: AppColors.bata,
                                  ),
                                );
                              }
                            } finally {
                              if (context.mounted) setState(() => isSubmitting = false);
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Ya, Batalkan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDetailSheet(BuildContext context, WidgetRef ref, StockTransaction tx) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.permukaan,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tx.transactionNo,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tinta,
                    ),
                  ),
                  StatusChip(status: tx.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Waktu: ${DateFormatter.formatDateTime(tx.createdAt)} WIB',
                style: const TextStyle(fontSize: 12, color: AppColors.abuTinta),
              ),
              Text(
                'Operator: ${tx.operatorNameSnapshot}',
                style: const TextStyle(fontSize: 12, color: AppColors.abuTinta),
              ),
              if (tx.note != null && tx.note!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Catatan: ${tx.note}',
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.tinta),
                ),
              ],
              const SizedBox(height: 16),
              const Divider(color: AppColors.garis),
              const SizedBox(height: 12),

              const Text(
                'Rincian Lembar Tally:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.tinta),
              ),
              const SizedBox(height: 8),

              ...tx.details.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.kertas,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.garis),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productNameSnapshot,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.tinta),
                            ),
                            Text(
                              '${item.fullPallets} palet + ${item.looseRows} baris + ${item.looseBoxes} dus',
                              style: const TextStyle(fontSize: 11, color: AppColors.abuTinta),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${NumberFormatter.formatNumber(item.totalBoxes)} Dus',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.tinta),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.daunMuda,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Transaksi:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.daunTua),
                    ),
                    Text(
                      '${NumberFormatter.formatNumber(tx.totalBoxes)} Dus (${NumberFormatter.formatDecimal(tx.totalPalletEquivalent)} Palet)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.daunTua),
                    ),
                  ],
                ),
              ),

              if (tx.status == TransactionStatus.posted) ...[
                const SizedBox(height: 20),
                AppButton(
                  text: 'Batalkan Transaksi (Void)',
                  variant: AppButtonVariant.danger,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _showVoidDialog(context, ref, tx);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(adminSelectedTypeProvider);
    final transactionsAsync = ref.watch(adminTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.kertas,
      appBar: AppBar(
        title: const Text(
          'Semua Transaksi Gudang',
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
      body: Column(
        children: [
          // Filter Bar
          Container(
            color: AppColors.permukaan,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua',
                  isSelected: selectedType == null,
                  onSelected: () => ref.read(adminSelectedTypeProvider.notifier).state = null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Masuk',
                  isSelected: selectedType == TransactionType.stockIn,
                  color: AppColors.daun,
                  onSelected: () =>
                      ref.read(adminSelectedTypeProvider.notifier).state = TransactionType.stockIn,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Keluar',
                  isSelected: selectedType == TransactionType.stockOut,
                  color: AppColors.biruTruk,
                  onSelected: () =>
                      ref.read(adminSelectedTypeProvider.notifier).state = TransactionType.stockOut,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.garis),

          // Transaction List
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const EmptyState(
                    title: 'Belum Ada Transaksi',
                    subtitle: 'Tidak ada data transaksi yang tercatat untuk filter ini.',
                    icon: Icons.receipt_long_outlined,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: transactions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isStockIn = tx.transactionType == TransactionType.stockIn;

                    return Card(
                      color: AppColors.permukaan,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.garis),
                      ),
                      child: InkWell(
                        onTap: () => _showDetailSheet(context, ref, tx),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isStockIn ? AppColors.daunMuda : AppColors.biruTrukMuda,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isStockIn ? 'MASUK' : 'KELUAR',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isStockIn ? AppColors.daunTua : AppColors.biruTruk,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        tx.transactionNo,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.tinta,
                                        ),
                                      ),
                                    ],
                                  ),
                                  StatusChip(status: tx.status),
                                ],
                              ),
                              const SizedBox(height: 10),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Operator: ${tx.operatorNameSnapshot}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.tinta),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        DateFormatter.formatDateTime(tx.createdAt),
                                        style: const TextStyle(fontSize: 11, color: AppColors.abuTinta),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${NumberFormatter.formatNumber(tx.totalBoxes)} Dus',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.tinta,
                                        ),
                                      ),
                                      Text(
                                        '${NumberFormatter.formatDecimal(tx.totalPalletEquivalent)} palet',
                                        style: const TextStyle(fontSize: 11, color: AppColors.abuTinta),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingView(message: 'Memuat data transaksi...'),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () => ref.invalidate(adminTransactionsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    Color color = AppColors.daun,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppColors.tinta,
        ),
      ),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: AppColors.kertas,
      onSelected: (_) => onSelected(),
    );
  }
}
