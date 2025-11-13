import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const warmSand = Color(0xFFF5E6D3);
    const richBrown = Color(0xFF6B4423);
    const deepTerracotta = Color(0xFF8B4513);
    const earthGreen = Color(0xFF4A7C59);
    const sunsetOrange = Color(0xFFD2691E);

    return Scaffold(
      backgroundColor: warmSand,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [deepTerracotta, richBrown],
                ),
                boxShadow: [
                  BoxShadow(
                    color: deepTerracotta.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.home_rounded,
                size: 50,
                color: Color(0xFFFFF8E7),
              ),
            ),

            const SizedBox(height: 40),

            // App name
            const Text(
              'Karibu Tanzania BnB',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3E2723),
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 8),

            // Tagline
            Text(
              'Your Home Away From Home',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8D6E63),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 50),

            // Unique Loading Animation
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(60, 60),
                  painter: TanzanianLoadingPainter(
                    animationValue: _controller.value,
                    terracotta: deepTerracotta,
                    green: earthGreen,
                    orange: sunsetOrange,
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Loading text
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final dots = '.' * ((_controller.value * 3).floor() + 1);
                return Text(
                  'Loading$dots',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF8D6E63),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TanzanianLoadingPainter extends CustomPainter {
  final double animationValue;
  final Color terracotta;
  final Color green;
  final Color orange;

  TanzanianLoadingPainter({
    required this.animationValue,
    required this.terracotta,
    required this.green,
    required this.orange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw 3 rotating arcs (like iOS but with our colors)
    for (int i = 0; i < 3; i++) {
      final rotation = (animationValue * 2 * math.pi) + (i * 2 * math.pi / 3);
      final arcPaint = Paint()
        ..color = i == 0
            ? terracotta
            : i == 1
            ? green
            : orange
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final startAngle = rotation;
      final sweepAngle = math.pi * 0.6; // 108 degrees

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - (i * 8)),
        startAngle,
        sweepAngle,
        false,
        arcPaint,
      );
    }

    // Center dot (pulsing)
    final pulse = (math.sin(animationValue * 2 * math.pi) + 1) / 2;
    final dotPaint = Paint()
      ..color = terracotta.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 4 + (pulse * 2), dotPaint);
  }

  @override
  bool shouldRepaint(TanzanianLoadingPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
