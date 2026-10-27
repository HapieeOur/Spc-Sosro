import 'package:flutter/material.dart';

class FluidSphereBackground extends StatelessWidget {
  final Widget? child;
  final double? height;
  final bool showSpheres;
  final bool isFullScreen;

  const FluidSphereBackground({
    super.key,
    this.child,
    this.height,
    this.showSpheres = true,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRect(
        child: Stack(
          children: [
            // 1. Base Gradient Merah Ruby Sosro (Deep Wine to Ruby Crimson)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF4A080A),
                    Color(0xFF7A0F13),
                    Color(0xFF9E171B),
                    Color(0xFF5E0A0D),
                  ],
                ),
              ),
            ),

            // 2. Custom Painter untuk Ombak / Gelombang Organik Halus
            Positioned.fill(
              child: CustomPaint(
                painter: _FluidWavePainter(isFullScreen: isFullScreen),
              ),
            ),

            // 3. Bola 3D Mengambang (Floating Spheres seperti referensi visual)
            if (showSpheres) ...[
              if (isFullScreen) ...[
                // Mode Layar Penuh (Splash / Welcome Screen)
                Positioned(
                  top: -20,
                  right: -25,
                  child: _buildSphere(size: 130, lightIntensity: 0.9),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: _buildSphere(size: 60, lightIntensity: 0.85),
                ),
                Positioned(
                  top: 210,
                  left: 32,
                  child: _buildSphere(size: 42, lightIntensity: 0.8),
                ),
                Positioned(
                  top: 310,
                  right: -15,
                  child: _buildSphere(size: 96, lightIntensity: 0.75),
                ),
                Positioned(
                  bottom: 210,
                  left: 70,
                  child: _buildSphere(size: 36, lightIntensity: 0.85),
                ),
                Positioned(
                  bottom: 120,
                  left: -20,
                  child: _buildSphere(size: 110, lightIntensity: 0.8),
                ),
                Positioned(
                  bottom: 75,
                  right: 32,
                  child: _buildSphere(size: 52, lightIntensity: 0.9),
                ),
              ] else ...[
                // Mode Header (Login & Register Screen)
                Positioned(
                  top: 18,
                  left: 20,
                  child: _buildSphere(size: 44, lightIntensity: 0.85),
                ),
                Positioned(
                  top: -15,
                  right: 36,
                  child: _buildSphere(size: 74, lightIntensity: 0.9),
                ),
                Positioned(
                  top: 60,
                  right: 16,
                  child: _buildSphere(size: 84, lightIntensity: 0.8),
                ),
                Positioned(
                  top: 125,
                  left: 28,
                  child: _buildSphere(size: 34, lightIntensity: 0.85),
                ),
                Positioned(
                  top: 155,
                  left: 52,
                  child: _buildSphere(size: 72, lightIntensity: 0.75),
                ),
              ],
            ],

            // 4. Foreground Content
            if (child != null) Positioned.fill(child: child!),
          ],
        ),
      ),
    );
  }

  Widget _buildSphere({required double size, double lightIntensity = 0.8}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: size * 0.35,
            offset: Offset(size * 0.1, size * 0.15),
          ),
        ],
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.35),
          radius: 0.85,
          colors: [
            Color.lerp(const Color(0xFFFFD4D6), Colors.white, lightIntensity)!,
            const Color(0xFFC8102E),
            const Color(0xFF800B0E),
            const Color(0xFF400406),
          ],
          stops: const [0.0, 0.45, 0.8, 1.0],
        ),
      ),
    );
  }
}

class _FluidWavePainter extends CustomPainter {
  final bool isFullScreen;

  _FluidWavePainter({this.isFullScreen = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Gelombang 1: Soft Translucent Rose (Sweep Kanan Atas)
    final paint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Colors.white.withValues(alpha: 0.3),
          const Color(0xFFFEE2E2).withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(w * 0.35, 0)
      ..cubicTo(w * 0.55, h * 0.35, w * 0.75, h * 0.18, w, h * 0.5)
      ..lineTo(w, 0)
      ..close();
    canvas.drawPath(path1, paint1);

    // Gelombang 2: Deep Crimson Wave (Kurva Kiri)
    final paint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFB91C1C).withValues(alpha: 0.42),
          const Color(0xFF660B0E).withValues(alpha: 0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(0, h * 0.22)
      ..cubicTo(w * 0.32, h * 0.12, w * 0.5, h * 0.52, w * 0.36, h * 0.88)
      ..cubicTo(w * 0.26, h * 1.0, 0, h * 0.92, 0, h * 0.92)
      ..close();
    canvas.drawPath(path2, paint2);

    // Gelombang 3: Translucent Ribbon Diagonal
    final paint3 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Colors.transparent,
          const Color(0xFFFDA4AF).withValues(alpha: 0.16),
          Colors.white.withValues(alpha: 0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final path3 = Path()
      ..moveTo(0, h * 0.55)
      ..cubicTo(w * 0.4, h * 0.45, w * 0.6, h * 0.8, w, h * 0.7)
      ..lineTo(w, h * 0.85)
      ..cubicTo(w * 0.55, h * 0.95, w * 0.35, h * 0.6, 0, h * 0.7)
      ..close();
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant _FluidWavePainter oldDelegate) =>
      oldDelegate.isFullScreen != isFullScreen;
}
