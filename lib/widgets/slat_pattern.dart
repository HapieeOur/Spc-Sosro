import 'package:flutter/material.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';

/// Pola papan kayu palet dengan gradasi merah Sinar Sosro & aksen slat halus
class SlatPatternPainter extends CustomPainter {
  final double slatHeight;
  final double gap;
  final Color baseColor;
  final Color slatColor;
  final Gradient? gradient;

  const SlatPatternPainter({
    this.slatHeight = 10.0,
    this.gap = 1.0,
    this.baseColor = AppColors.merahTua,
    this.slatColor = const Color(0x0AFFFFFF), // Putih 4% sangat halus
    this.gradient = AppColors.heroGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Background base dengan gradasi merah hangat
    final bgPaint = Paint();
    if (gradient != null) {
      bgPaint.shader = gradient!.createShader(rect);
    } else {
      bgPaint.color = baseColor;
    }
    canvas.drawRect(rect, bgPaint);

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
        oldDelegate.slatColor != slatColor ||
        oldDelegate.gradient != gradient;
  }
}

class SlatHeaderBackground extends StatelessWidget {
  final Widget child;
  final double? height;
  final Gradient? gradient;

  const SlatHeaderBackground({
    super.key,
    required this.child,
    this.height,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SlatPatternPainter(gradient: gradient ?? AppColors.heroGradient),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: child,
      ),
    );
  }
}
