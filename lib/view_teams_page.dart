import 'package:flutter/material.dart';
import 'boys_team_page.dart';
import 'girls_team_page.dart';

class ViewTeamsPage extends StatefulWidget {
  final bool selectingTeam;

  const ViewTeamsPage({super.key, this.selectingTeam = false});

  @override
  State<ViewTeamsPage> createState() => _ViewTeamsPageState();
}

class _ViewTeamsPageState extends State<ViewTeamsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _boysController;
  late AnimationController _girlsController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _boysController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _girlsController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _boysController.dispose();
    _girlsController.dispose();
    super.dispose();
  }

  void _navigateToTeamPage(BuildContext context, bool isBoys) async {
    final selectedTeamName = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => isBoys
            ? BoysTeamPage(selectingTeam: widget.selectingTeam)
            : GirlsTeamPage(selectingTeam: widget.selectingTeam),
      ),
    );

    if (widget.selectingTeam && selectedTeamName != null && selectedTeamName is String) {
      Navigator.pop(context, {
        'name': selectedTeamName,
        'gender': isBoys ? 'boys' : 'girls',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.orange.shade600 : Colors.orange.shade700;
    final accentColor = isDark ? Colors.deepOrange.shade500 : Colors.deepOrange.shade600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
              const Color(0xFF1A1A1A),
              const Color(0xFF2D2D2D),
              const Color(0xFF1A1A1A),
            ]
                : [
              Colors.orange.shade50,
              Colors.white,
              Colors.orange.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '🏀 TEAMS',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              letterSpacing: 2,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.sports_basketball,
                              color: primaryColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Basketball Court Animation
                      AnimatedBuilder(
                        animation: _slideAnimation,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _slideAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                height: 180,
                                margin: const EdgeInsets.only(bottom: 40),
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      primaryColor.withOpacity(0.2),
                                      primaryColor.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Court Lines
                                    CustomPaint(
                                      size: const Size(200, 120),
                                      painter: BasketballCourtPainter(
                                        color: primaryColor.withOpacity(0.3),
                                      ),
                                    ),
                                    // Basketball
                                    TweenAnimationBuilder<double>(
                                      duration: const Duration(seconds: 2),
                                      tween: Tween(begin: 0, end: 1),
                                      builder: (context, value, child) {
                                        return Transform.translate(
                                          offset: Offset(0, -20 * (1 - value)),
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              gradient: RadialGradient(
                                                colors: [
                                                  primaryColor,
                                                  accentColor,
                                                ],
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: primaryColor.withOpacity(0.4),
                                                  blurRadius: 20,
                                                  spreadRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.sports_basketball,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Team Selection Buttons
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: Column(
                              children: [
                                // Boys Team Button
                                GestureDetector(
                                  onTapDown: (_) => _boysController.forward(),
                                  onTapUp: (_) => _boysController.reverse(),
                                  onTapCancel: () => _boysController.reverse(),
                                  onTap: () => _navigateToTeamPage(context, true),
                                  child: AnimatedBuilder(
                                    animation: _boysController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: 1.0 - (_boysController.value * 0.05),
                                        child: Container(
                                          width: double.infinity,
                                          height: 80,
                                          margin: const EdgeInsets.only(bottom: 24),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.blue.shade600,
                                                Colors.blue.shade700,
                                                Colors.blue.shade800,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blue.withOpacity(0.4),
                                                blurRadius: 20,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            children: [
                                              // Background Pattern
                                              Positioned.fill(
                                                child: CustomPaint(
                                                  painter: BasketballPatternPainter(
                                                    color: Colors.white.withOpacity(0.1),
                                                  ),
                                                ),
                                              ),
                                              // Content
                                              Center(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: const Icon(
                                                        Icons.boy,
                                                        color: Colors.white,
                                                        size: 28,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    const Text(
                                                      'BOYS TEAMS',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        letterSpacing: 1.2,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    const Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Girls Team Button
                                GestureDetector(
                                  onTapDown: (_) => _girlsController.forward(),
                                  onTapUp: (_) => _girlsController.reverse(),
                                  onTapCancel: () => _girlsController.reverse(),
                                  onTap: () => _navigateToTeamPage(context, false),
                                  child: AnimatedBuilder(
                                    animation: _girlsController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: 1.0 - (_girlsController.value * 0.05),
                                        child: Container(
                                          width: double.infinity,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.purple.shade600,
                                                Colors.purple.shade700,
                                                Colors.purple.shade800,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.purple.withOpacity(0.4),
                                                blurRadius: 20,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            children: [
                                              // Background Pattern
                                              Positioned.fill(
                                                child: CustomPaint(
                                                  painter: BasketballPatternPainter(
                                                    color: Colors.white.withOpacity(0.1),
                                                  ),
                                                ),
                                              ),
                                              // Content
                                              Center(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: const Icon(
                                                        Icons.girl,
                                                        color: Colors.white,
                                                        size: 28,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    const Text(
                                                      'GIRLS TEAMS',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        letterSpacing: 1.2,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    const Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for Basketball Court
class BasketballCourtPainter extends CustomPainter {
  final Color color;

  BasketballCourtPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // Center circle
    canvas.drawCircle(center, 30, paint);

    // Court outline
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: size.width * 0.8, height: size.height * 0.7),
        const Radius.circular(8),
      ),
      paint,
    );

    // Center line
    canvas.drawLine(
      Offset(size.width * 0.1, center.dy),
      Offset(size.width * 0.9, center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Basketball Pattern
class BasketballPatternPainter extends CustomPainter {
  final Color color;

  BasketballPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw basketball texture lines
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(size.width * 0.2 + (i * size.width * 0.3), 0),
        Offset(size.width * 0.2 + (i * size.width * 0.3), size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}