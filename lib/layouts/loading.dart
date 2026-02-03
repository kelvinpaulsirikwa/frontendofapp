import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/utility/componet.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Loading {
  const Loading._(); // prevents instantiation
   static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Align(
            alignment: Alignment.bottomCenter, // Align to the bottom
            child: Container(
              margin: const EdgeInsets.all(
                20,
              ), // Optional: Add margin if needed
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 30,
              ), // Optional: Add padding if needed
             
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoadingAnimationWidget(size: 80),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

 

  static Widget splashLoading({
    required Future<void> Function() onInit,
    required Widget Function(bool isLoggedIn) onComplete,
  }) {
    return SplashLoadingPage(
      onInit: onInit,
      onComplete: onComplete,
    );
  }
}

/// Reusable animated loading spinner used in dialogs and splash.
class LoadingAnimationWidget extends StatefulWidget {
  final double size;

  const LoadingAnimationWidget({super.key, this.size = 80});

  @override
  State<LoadingAnimationWidget> createState() => _LoadingAnimationWidgetState();
}

class _LoadingAnimationWidgetState extends State<LoadingAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: LoadingDots(
              progress: _controller.value,
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
}

class SplashLoadingPage extends StatefulWidget {
  final Future<void> Function() onInit;
  final Widget Function(bool isLoggedIn) onComplete;
  /// When true, never navigates away - useful for development

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
    // Navigate when initialized (unless keeping splash visible for development)
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
      appBar: KivuliAppBar(),      backgroundColor: Colors.white,

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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                            // Animated Logo
               
                
                const SizedBox(height: 32),
                
              
                _buildLoadingAnimation(),
                
                const SizedBox(height: 24),
                
                // Loading Text
                _buildLoadingText(),
                
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
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
            painter: LoadingDots(
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

 }

class LoadingDots extends CustomPainter {
  final double progress;
  final Color terracotta;
  final Color green;
  final Color orange;
  final Color gold;

  LoadingDots({
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
  bool shouldRepaint(LoadingDots oldDelegate) {
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
