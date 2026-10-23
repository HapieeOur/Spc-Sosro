import 'package:flutter/material.dart';
import 'package:spc_sosro/core/constants/app_constants.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  final TransactionStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == TransactionStatus.posted) {
      // Kondisi normal tercatat tidak diberi chip agar mengurangi kebisingan visual
      return const SizedBox.shrink();
    }

    final (label, icon, bgColor, textColor) = switch (status) {
      TransactionStatus.voided => (
          'Dibatalkan',
          Icons.block,
          AppColors.bataMuda,
          AppColors.bata,
        ),
      TransactionStatus.corrected => (
          'Dikoreksi',
          Icons.edit_note,
          AppColors.kuningMarkaMuda,
          AppColors.teksPeringatan,
        ),
      TransactionStatus.posted => (
          'Tercatat',
          Icons.check_circle_outline,
          AppColors.daunMuda,
          AppColors.daunTua,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
