import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashLoadingPage extends StatefulWidget {
  final Future<void> Function() onInit;
  final Widget Function(bool isLoggedIn) onComplete;

  const SplashLoadingPage({
    super.key,
    required this.onInit,
    required this.onComplete,
  });

  @override
  State<SplashLoadingPage> createState() => _SplashLoadingPageState();
}

class _SplashLoadingPageState extends State<SplashLoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isInitialized = false;
  bool _isLoggedIn = false;

  // Tanzania BnB colors
  static const warmSand = Color(0xFFF5E6D3);
  static const richBrown = Color(0xFF6B4423);
  static const deepTerracotta = Color(0xFF8B4513);
  static const earthGreen = Color(0xFF4A7C59);
  static const sunsetOrange = Color(0xFFD2691E);
  static const softCream = Color(0xFFFFF8E7);
  static const textDark = Color(0xFF3E2723);
  static const textLight = Color(0xFF8D6E63);
  static const accentGold = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    
    // Spinning loader animation
    _spinController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Fade-in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Scale animation for logo
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    
    // Initialize app
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Minimum splash duration for smooth UX
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Run the initialization callback
    await widget.onInit();
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Navigate when initialized
    if (_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                widget.onComplete(_isLoggedIn),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              warmSand,
              Color(0xFFF0DCC4), // Slightly darker sand
              softCream,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Animated Logo
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildLogo(),
                ),
                
                const SizedBox(height: 32),
                
                // App Name with subtle animation
                _buildAppName(),
                
                const SizedBox(height: 12),
                
                // Tagline
                _buildTagline(),
                
                const Spacer(flex: 2),
                
                // Loading Animation
                _buildLoadingAnimation(),
                
                const SizedBox(height: 24),
                
                // Loading Text
                _buildLoadingText(),
                
                const Spacer(flex: 1),
                
                // Footer
                _buildFooter(),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [deepTerracotta, richBrown],
        ),
        boxShadow: [
          BoxShadow(
            color: deepTerracotta.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 12),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: sunsetOrange.withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 0),
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner glow
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  softCream.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Icon
          const Icon(
            Icons.home_rounded,
            size: 56,
            color: softCream,
          ),
        ],
      ),
    );
  }

  Widget _buildAppName() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [textDark, richBrown, deepTerracotta],
        stops: [0.0, 0.5, 1.0],
      ).createShader(bounds),
      child: const Text(
        'Tanzania BnB',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -1,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: earthGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: earthGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 16,
            color: earthGreen,
          ),
          SizedBox(width: 6),
          Text(
            'Your Home Away From Home',
            style: TextStyle(
              fontSize: 14,
              color: earthGreen,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return AnimatedBuilder(
      animation: _spinController,
      builder: (context, child) {
        return SizedBox(
          width: 80,
          height: 80,
          child: CustomPaint(
            painter: _TanzaniaSpinnerPainter(
              progress: _spinController.value,
              terracotta: deepTerracotta,
              green: earthGreen,
              orange: sunsetOrange,
              gold: accentGold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingText() {
    return AnimatedBuilder(
      animation: _spinController,
      builder: (context, child) {
        final dotCount = ((_spinController.value * 4).floor() % 4);
        final dots = '.' * dotCount;
        final spaces = ' ' * (3 - dotCount);
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: richBrown.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.hourglass_top_rounded,
                    size: 18,
                    color: textLight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Preparing your experience$dots$spaces',
                    style: const TextStyle(
                      fontSize: 14,
                      color: textLight,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFooterIcon(Icons.bed_rounded),
            const SizedBox(width: 24),
            _buildFooterIcon(Icons.map_outlined),
            const SizedBox(width: 24),
            _buildFooterIcon(Icons.favorite_outline_rounded),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Discover • Book • Enjoy',
          style: TextStyle(
            fontSize: 12,
            color: textLight.withOpacity(0.7),
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        shape: BoxShape.circle,
        border: Border.all(
          color: earthGreen.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Icon(
        icon,
        size: 22,
        color: earthGreen.withOpacity(0.8),
      ),
    );
  }
}

class _TanzaniaSpinnerPainter extends CustomPainter {
  final double progress;
  final Color terracotta;
  final Color green;
  final Color orange;
  final Color gold;

  _TanzaniaSpinnerPainter({
    required this.progress,
    required this.terracotta,
    required this.green,
    required this.orange,
    required this.gold,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseAngle = progress * 2 * math.pi;

    // Outer ring - Track
    final trackPaint = Paint()
      ..color = terracotta.withOpacity(0.15)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 36, trackPaint);

    // Arc configurations
    final arcs = [
      _ArcConfig(color: terracotta, radius: 36, offset: 0, sweepAngle: 0.8),
      _ArcConfig(color: green, radius: 28, offset: math.pi * 0.7, sweepAngle: 0.6),
      _ArcConfig(color: orange, radius: 20, offset: math.pi * 1.4, sweepAngle: 0.5),
    ];

    for (var arc in arcs) {
      final paint = Paint()
        ..color = arc.color
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final startAngle = baseAngle + arc.offset;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arc.radius),
        startAngle,
        arc.sweepAngle * math.pi,
        false,
        paint,
      );
    }

    // Center pulsing dot
    final pulse = (math.sin(progress * 4 * math.pi) + 1) / 2;
    final dotPaint = Paint()
      ..color = Color.lerp(terracotta, gold, pulse)!
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 5 + (pulse * 3), dotPaint);

    // Sparkle effect
    final sparkleAngle = baseAngle * 1.5;
    final sparkleRadius = 36.0;
    final sparklePos = Offset(
      center.dx + math.cos(sparkleAngle) * sparkleRadius,
      center.dy + math.sin(sparkleAngle) * sparkleRadius,
    );
    
    final sparklePaint = Paint()
      ..color = gold.withOpacity(0.6 + (pulse * 0.4))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sparklePos, 3, sparklePaint);
  }

  @override
  bool shouldRepaint(_TanzaniaSpinnerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ArcConfig {
  final Color color;
  final double radius;
  final double offset;
  final double sweepAngle;

  _ArcConfig({
    required this.color,
    required this.radius,
    required this.offset,
    required this.sweepAngle,
  });
}
