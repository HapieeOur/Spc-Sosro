import 'package:flutter/material.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';

/// Pola papan kayu palet untuk header dan hero screen (Daun Tua dengan garis slat putih 5%)
class SlatPatternPainter extends CustomPainter {
  final double slatHeight;
  final double gap;
  final Color baseColor;
  final Color slatColor;

  const SlatPatternPainter({
    this.slatHeight = 10.0,
    this.gap = 1.0,
    this.baseColor = AppColors.daunTua,
    this.slatColor = const Color(0x0DFFFFFF), // Putih 5%
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background base
    final bgPaint = Paint()..color = baseColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Horizontal slats
    final slatPaint = Paint()..color = slatColor;
    double y = 0;
    while (y < size.height) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, slatHeight), slatPaint);
      y += slatHeight + gap;
    }
  }

  @override
  bool shouldRepaint(covariant SlatPatternPainter oldDelegate) {
    return oldDelegate.slatHeight != slatHeight ||
        oldDelegate.gap != gap ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.slatColor != slatColor;
  }
}

class SlatHeaderBackground extends StatelessWidget {
  final Widget child;
  final double? height;

  const SlatHeaderBackground({
    super.key,
    required this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const SlatPatternPainter(),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: child,
      ),
    );
  }
}
