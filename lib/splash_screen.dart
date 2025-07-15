import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late AnimationController _rotationController;
  late AnimationController _courtController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _courtAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();

    Timer(const Duration(seconds: 4), () {
      widget.onFinish();
    });
  }

  void _initializeAnimations() {
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: -200,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.bounceOut,
    ));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _courtController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _courtAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _courtController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _courtController.forward();

    Timer(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });

    Timer(const Duration(milliseconds: 500), () {
      _bounceController.forward();
    });

    Timer(const Duration(milliseconds: 800), () {
      _rotationController.repeat();
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _fadeController.dispose();
    _rotationController.dispose();
    _courtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000), // Pure black
              Color(0xFF1A1A1A), // Dark black
              Color(0xFF2D2D2D), // Charcoal
              Color(0xFF000000), // Pure black
            ],
          ),
        ),
        child: Stack(
          children: [
            // Basketball court pattern
            AnimatedBuilder(
              animation: _courtAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: size,
                  painter: CourtPainter(_courtAnimation.value),
                );
              },
            ),

            // Floating basketballs
            ...List.generate(6, (index) => _buildFloatingBall(index, size)),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Basketball with bounce effect
                  AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: AnimatedBuilder(
                          animation: _rotationAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const RadialGradient(
                                    colors: [
                                      Color(0xFFFF8C42), // Basketball orange
                                      Color(0xFFFF6B1A), // Vibrant orange
                                      Color(0xFFE55100), // Deep orange
                                      Color(0xFFBF360C), // Dark orange
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF6B1A).withOpacity(0.8),
                                      blurRadius: 40,
                                      spreadRadius: 15,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFFFF8C42).withOpacity(0.4),
                                      blurRadius: 80,
                                      spreadRadius: 30,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Basketball lines
                                    CustomPaint(
                                      size: const Size(120, 120),
                                      painter: BasketballLinesPainter(),
                                    ),
                                    // Basketball icon
                                    const Center(
                                      child: Icon(
                                        Icons.sports_basketball,
                                        size: 70,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 60),

                  // App title
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF6B1A).withOpacity(0.3),
                            const Color(0xFFFF8C42).withOpacity(0.2),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFFFF6B1A),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B1A).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        'SlamStat',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFFF6B1A).withOpacity(0.9),
                              offset: const Offset(3, 3),
                              blurRadius: 15,
                            ),
                            const Shadow(
                              color: Colors.black,
                              offset: Offset(1, 1),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Subtitle
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFFFF6B1A).withOpacity(0.1),
                        border: Border.all(
                          color: const Color(0xFFFF6B1A).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '🏀 Basketball Scoring App 🏀',
                        style: TextStyle(
                          fontSize: 18,
                          color: const Color(0xFFFF8C42),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFFF6B1A).withOpacity(0.5),
                              offset: const Offset(1, 1),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  // Loading indicator
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFF6B1A).withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B1A).withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF6B1A),
                        ),
                        backgroundColor: Colors.transparent,
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
  }

  Widget _buildFloatingBall(int index, Size size) {
    final random = math.Random(index);
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final ballSize = 15.0 + random.nextDouble() * 25.0;
    final opacity = 0.1 + random.nextDouble() * 0.3;

    return Positioned(
      left: x,
      top: y,
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          final offset = math.sin(_rotationAnimation.value + index) * 20;
          return Transform.translate(
            offset: Offset(offset, offset * 0.5),
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: ballSize,
                height: ballSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFF8C42).withOpacity(0.9),
                      const Color(0xFFFF6B1A).withOpacity(0.6),
                      const Color(0xFFE55100).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B1A).withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ballSize > 20
                    ? Icon(
                  Icons.sports_basketball,
                  size: ballSize * 0.6,
                  color: Colors.black.withOpacity(0.7),
                )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

class CourtPainter extends CustomPainter {
  final double progress;

  CourtPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF6B1A).withOpacity(0.15 * progress)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = const Color(0xFFFF6B1A).withOpacity(0.05 * progress)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3);

    // Center circle with glow
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      80 * progress,
      glowPaint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      80 * progress,
      paint,
    );

    // Three-point lines (simplified) with glow
    final path = Path();
    path.addArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.8),
        width: 200 * progress,
        height: 200 * progress,
      ),
      -math.pi,
      math.pi,
    );
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Court lines with glow
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.1),
      Offset(size.width * 0.8, size.height * 0.1),
      glowPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.1),
      Offset(size.width * 0.8, size.height * 0.1),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.9),
      Offset(size.width * 0.8, size.height * 0.9),
      glowPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.9),
      Offset(size.width * 0.8, size.height * 0.9),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BasketballLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.9)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Vertical line
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      paint,
    );

    // Horizontal line
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      paint,
    );

    // Curved lines
    final path1 = Path();
    path1.addArc(
      Rect.fromCircle(center: center, radius: radius * 0.3),
      -math.pi / 2,
      math.pi,
    );
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.addArc(
      Rect.fromCircle(center: center, radius: radius * 0.3),
      math.pi / 2,
      math.pi,
    );
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}