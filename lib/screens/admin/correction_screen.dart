import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';
import 'package:spc_sosro/core/utils/date_formatter.dart';
import 'package:spc_sosro/models/transaction_correction.dart';
import 'package:spc_sosro/providers/transaction_form_provider.dart';
import 'package:spc_sosro/widgets/empty_state.dart';
import 'package:spc_sosro/widgets/error_view.dart';
import 'package:spc_sosro/widgets/loading_view.dart';

final correctionsProvider = FutureProvider.autoDispose<List<TransactionCorrection>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.fetchCorrections();
});

class CorrectionScreen extends ConsumerWidget {
  const CorrectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correctionsAsync = ref.watch(correctionsProvider);

    return Scaffold(
      backgroundColor: AppColors.kertas,
      appBar: AppBar(
        title: const Text(
          'Riwayat Koreksi Transaksi',
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
      body: correctionsAsync.when(
        data: (corrections) {
          if (corrections.isEmpty) {
            return const EmptyState(
              title: 'Tidak Ada Riwayat Koreksi',
              subtitle: 'Belum ada transaksi yang pernah dikoreksi oleh administrator.',
              icon: Icons.edit_note_outlined,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: corrections.length,
            separatorBuilder: (_, unused) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = corrections[index];
              return Card(
                color: AppColors.permukaan,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppColors.garis),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.kuningMarkaMuda,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.kuningMarka.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Text(
                              'KOREKSI',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.teksPeringatan,
                              ),
                            ),
                          ),
                          Text(
                            DateFormatter.formatDateTime(item.correctedAt),
                            style: const TextStyle(fontSize: 11, color: AppColors.abuTinta),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(
                        'Alasan Koreksi:',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.abuTinta,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.reason,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.tinta,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: AppColors.garis),
                      const SizedBox(height: 12),

                      // Before vs After Data Box
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.kertas,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Sebelum Koreksi:',
                                  style: TextStyle(fontSize: 11, color: AppColors.bata, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${item.beforeData['total_boxes'] ?? 0} Dus',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.bata),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Setelah Koreksi:',
                                  style: TextStyle(fontSize: 11, color: AppColors.daun, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${item.afterData['total_boxes'] ?? 0} Dus',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.daun),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingView(message: 'Memuat data koreksi...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(correctionsProvider),
        ),
      ),
    );
  }
}
