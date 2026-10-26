import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';
import 'package:spc_sosro/core/utils/date_formatter.dart';
import 'package:spc_sosro/providers/settings_provider.dart';
import 'package:spc_sosro/widgets/empty_state.dart';
import 'package:spc_sosro/widgets/error_view.dart';
import 'package:spc_sosro/widgets/loading_view.dart';

class ActivityLogScreen extends ConsumerWidget {
  const ActivityLogScreen({super.key});

  IconData _getIconForAction(String action) {
    if (action.contains('user')) return Icons.person_outline;
    if (action.contains('product')) return Icons.inventory_2_outlined;
    if (action.contains('void')) return Icons.cancel_outlined;
    if (action.contains('balance')) return Icons.account_balance_wallet_outlined;
    return Icons.history_rounded;
  }

  Color _getColorForAction(String action) {
    if (action.contains('void') || action.contains('disable')) return AppColors.bata;
    if (action.contains('approved') || action.contains('create')) return AppColors.daun;
    return AppColors.biruTruk;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(activityLogsProvider);

    return Scaffold(
      backgroundColor: AppColors.kertas,
      appBar: AppBar(
        title: const Text(
          'Log Aktivitas & Audit',
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
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const EmptyState(
              title: 'Belum Ada Log Aktivitas',
              subtitle: 'Aktivitas perubahan sistem oleh pengguna belum tercatat.',
              icon: Icons.history_toggle_off_outlined,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (_, unused) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final log = logs[index];
              final icon = _getIconForAction(log.action);
              final color = _getColorForAction(log.action);

              return Card(
                color: AppColors.permukaan,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.garis),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: color.withValues(alpha: 0.15),
                        child: Icon(icon, color: color, size: 18),
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
                                  log.actorNameSnapshot,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.tinta,
                                  ),
                                ),
                                Text(
                                  DateFormatter.formatDateTime(log.createdAt),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.abuTinta,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              log.description ?? log.action,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.tinta,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.kertas,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                log.entityType.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.abuTinta,
                                ),
                              ),
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
        loading: () => const LoadingView(message: 'Memuat riwayat log...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(activityLogsProvider),
        ),
      ),
    );
  }
}
