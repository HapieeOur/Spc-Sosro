import 'package:flutter/material.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';

class PalletMeter extends StatelessWidget {
  final int totalBoxes;
  final int rowsPerPallet;
  final int boxesPerRow;
  final int minBoxes;
  final int maxBlocks;

  const PalletMeter({
    super.key,
    required this.totalBoxes,
    required this.rowsPerPallet,
    required this.boxesPerRow,
    this.minBoxes = 0,
    this.maxBlocks = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (rowsPerPallet <= 0 || boxesPerRow <= 0) return const SizedBox.shrink();

    final boxesPerPallet = rowsPerPallet * boxesPerRow;
    final fullPallets = totalBoxes ~/ boxesPerPallet;
    final remainder = totalBoxes % boxesPerPallet;
    final looseRows = remainder ~/ boxesPerRow;
    final looseBoxes = remainder % boxesPerRow;
    final hasPartial = remainder > 0;
    final totalPalletBlocks = fullPallets + (hasPartial ? 1 : 0);

    final isBelowMin = minBoxes > 0 && totalBoxes < minBoxes;
    final fillColor = isBelowMin ? AppColors.kuningMarka : AppColors.daun;

    final displayCount = totalPalletBlocks > maxBlocks ? maxBlocks : totalPalletBlocks;
    final overflowCount = totalPalletBlocks - displayCount;

    if (totalBoxes == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: const Size(28, 24),
            painter: _SinglePalletPainter(
              rowsPerPallet: rowsPerPallet,
              filledRows: 0,
              partialFraction: 0,
              fillColor: fillColor,
              isEmpty: true,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Kosong',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.abuTinta,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < displayCount; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          if (i < fullPallets)
            CustomPaint(
              size: const Size(28, 24),
              painter: _SinglePalletPainter(
                rowsPerPallet: rowsPerPallet,
                filledRows: rowsPerPallet,
                partialFraction: 1.0,
                fillColor: fillColor,
              ),
            )
          else
            CustomPaint(
              size: const Size(28, 24),
              painter: _SinglePalletPainter(
                rowsPerPallet: rowsPerPallet,
                filledRows: looseRows,
                partialFraction: looseBoxes / boxesPerRow,
                fillColor: fillColor,
              ),
            ),
        ],
        if (overflowCount > 0) ...[
          const SizedBox(width: 6),
          Text(
            '+$overflowCount',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.abuTinta,
            ),
          ),
        ],
      ],
    );
  }
}

class _SinglePalletPainter extends CustomPainter {
  final int rowsPerPallet;
  final int filledRows;
  final double partialFraction;
  final Color fillColor;
  final bool isEmpty;

  _SinglePalletPainter({
    required this.rowsPerPallet,
    required this.filledRows,
    required this.partialFraction,
    required this.fillColor,
    this.isEmpty = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double baseHeight = 4.0;
    final double stackHeight = size.height - baseHeight;
    final double sliceHeight = (stackHeight - (rowsPerPallet - 1) * 1.0) / rowsPerPallet;

    // 1. Draw Wood Pallet Base (4dp)
    final woodPaint = Paint()..color = AppColors.kayu;
    final woodDarkPaint = Paint()..color = AppColors.kayuTua;

    // Top beam of wooden pallet
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - baseHeight, size.width, 1.5),
      woodPaint,
    );
    // Left notch leg
    canvas.drawRect(
      Rect.fromLTWH(2, size.height - baseHeight + 1.5, 5, baseHeight - 1.5),
      woodDarkPaint,
    );
    // Center notch leg
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2 - 2.5, size.height - baseHeight + 1.5, 5, baseHeight - 1.5),
      woodDarkPaint,
    );
    // Right notch leg
    canvas.drawRect(
      Rect.fromLTWH(size.width - 7, size.height - baseHeight + 1.5, 5, baseHeight - 1.5),
      woodDarkPaint,
    );

    // 2. Draw Carton Slices (bottom to top)
    if (isEmpty) {
      final borderPaint = Paint()
        ..color = AppColors.garis
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRect(Rect.fromLTWH(0.5, 0.5, size.width - 1, stackHeight - 1), borderPaint);
      return;
    }

    final activePaint = Paint()..color = fillColor;
    final emptyPaint = Paint()..color = AppColors.garis;

    for (int r = 0; r < rowsPerPallet; r++) {
      // Row index from bottom (r = 0 is bottom row)
      final double y = stackHeight - (r + 1) * sliceHeight - r * 1.0;
      final rect = Rect.fromLTWH(0, y, size.width, sliceHeight);

      if (r < filledRows) {
        // Fully filled row
        canvas.drawRect(rect, activePaint);
      } else if (r == filledRows && partialFraction > 0) {
        // Partially filled row
        final filledWidth = size.width * partialFraction;
        canvas.drawRect(Rect.fromLTWH(0, y, filledWidth, sliceHeight), activePaint);
        canvas.drawRect(
          Rect.fromLTWH(filledWidth, y, size.width - filledWidth, sliceHeight),
          emptyPaint,
        );
      } else {
        // Empty row
        canvas.drawRect(rect, emptyPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SinglePalletPainter oldDelegate) {
    return oldDelegate.rowsPerPallet != rowsPerPallet ||
        oldDelegate.filledRows != filledRows ||
        oldDelegate.partialFraction != partialFraction ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.isEmpty != isEmpty;
  }
}
