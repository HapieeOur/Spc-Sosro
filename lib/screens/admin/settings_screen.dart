import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';
import 'package:spc_sosro/core/utils/date_formatter.dart';
import 'package:spc_sosro/core/utils/number_formatter.dart';
import 'package:spc_sosro/core/utils/validators.dart';
import 'package:spc_sosro/models/product.dart';
import 'package:spc_sosro/models/stock_opening_balance.dart';
import 'package:spc_sosro/providers/dashboard_provider.dart';
import 'package:spc_sosro/providers/products_provider.dart';
import 'package:spc_sosro/widgets/app_button.dart';
import 'package:spc_sosro/widgets/app_text_field.dart';
import 'package:spc_sosro/widgets/empty_state.dart';
import 'package:spc_sosro/widgets/error_view.dart';
import 'package:spc_sosro/widgets/loading_view.dart';

final openingBalancesProvider = FutureProvider.autoDispose<List<StockOpeningBalance>>((ref) async {
  final repo = ref.watch(stockRepositoryProvider);
  return repo.fetchOpeningBalances();
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _openSetOpeningBalanceDialog(List<Product> products) {
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan master produk terlebih dahulu.'),
          backgroundColor: AppColors.bata,
        ),
      );
      return;
    }

    String selectedProductId = products.first.id;
    final qtyController = TextEditingController(text: '0');
    final noteController = TextEditingController(text: 'Stok awal gudang');
    DateTime effectiveDate = DateTime.now();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.permukaan,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Atur Saldo Awal Stok',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.tinta,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Dropdown Pilih Produk
                      const Text(
                        'Pilih Produk',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tinta,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.permukaan,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.garis),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedProductId,
                            isExpanded: true,
                            items: products.map((p) {
                              return DropdownMenuItem<String>(
                                value: p.id,
                                child: Text('${p.name} (${p.code})'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setSheetState(() => selectedProductId = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Jumlah Dus
                      AppTextField(
                        controller: qtyController,
                        label: 'Jumlah Stok Awal (Dus)',
                        hint: 'Contoh: 500',
                        keyboardType: TextInputType.number,
                        validator: (v) => Validators.validatePositiveInt(v, fieldName: 'Jumlah stok'),
                      ),
                      const SizedBox(height: 14),

                      // Tanggal Efektif
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: effectiveDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setSheetState(() => effectiveDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.kertas,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.garis),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tanggal Efektif Saldo',
                                    style: TextStyle(fontSize: 11, color: AppColors.abuTinta),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormatter.formatDate(effectiveDate),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.tinta),
                                  ),
                                ],
                              ),
                              const Icon(Icons.calendar_today, size: 18, color: AppColors.daun),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Catatan
                      AppTextField(
                        controller: noteController,
                        label: 'Catatan Saldo Awal',
                        hint: 'Contoh: Stok opname awal periode',
                        validator: (v) => Validators.validateRequired(v, fieldName: 'Catatan'),
                      ),
                      const SizedBox(height: 20),

                      AppButton(
                        text: 'Simpan Saldo Awal',
                        isLoading: isSaving,
                        onPressed: () async {
                          if (formKey.currentState?.validate() ?? false) {
                            setSheetState(() => isSaving = true);
                            try {
                              await ref.read(stockRepositoryProvider).adminSetOpeningBalance(
                                    productId: selectedProductId,
                                    qtyBoxes: int.parse(qtyController.text.trim()),
                                    effectiveDate: effectiveDate,
                                    note: noteController.text.trim(),
                                  );

                              ref.invalidate(openingBalancesProvider);
                              ref.invalidate(stockSummaryProvider);
                              ref.invalidate(dashboardProvider);

                              if (context.mounted) {
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Saldo awal produk berhasil diperbarui!'),
                                    backgroundColor: AppColors.daun,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal menyimpan: $e'),
                                    backgroundColor: AppColors.bata,
                                  ),
                                );
                              }
                            } finally {
                              if (context.mounted) setSheetState(() => isSaving = false);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final balancesAsync = ref.watch(openingBalancesProvider);
    final productsAsync = ref.watch(activeProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.kertas,
      appBar: AppBar(
        title: const Text(
          'Saldo Awal Gudang',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.tinta,
          ),
        ),
        backgroundColor: AppColors.permukaan,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          productsAsync.maybeWhen(
            data: (products) => IconButton(
              tooltip: 'Set Saldo Awal',
              icon: const Icon(Icons.add_circle, color: AppColors.daun, size: 28),
              onPressed: () => _openSetOpeningBalanceDialog(products),
            ),
            orElse: () => const SizedBox(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: balancesAsync.when(
        data: (balances) {
          if (balances.isEmpty) {
            return EmptyState(
              title: 'Belum Ada Saldo Awal',
              subtitle: 'Atur saldo awal produk untuk memulai kalkulasi mutasi stok.',
              icon: Icons.account_balance_wallet_outlined,
              actionText: 'Atur Saldo Awal',
              onAction: () {
                productsAsync.whenData((products) => _openSetOpeningBalanceDialog(products));
              },
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: balances.length,
            separatorBuilder: (_, unused) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = balances[index];
              return Card(
                color: AppColors.permukaan,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppColors.garis),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.note,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.tinta,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Efektif: ${DateFormatter.formatDate(item.effectiveDate)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.abuTinta),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${NumberFormatter.formatNumber(item.qtyBoxes)} Dus',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.daun,
                            ),
                          ),
                          const Text(
                            'Saldo Awal',
                            style: TextStyle(fontSize: 11, color: AppColors.abuTinta),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingView(message: 'Memuat data saldo awal...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(openingBalancesProvider),
        ),
      ),
    );
  }
}
