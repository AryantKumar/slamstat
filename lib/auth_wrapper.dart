import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'auth_page.dart';
import 'home_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<bool> isUserAllowed(User user) async {
    final uid = user.uid;
    final snapshot = await FirebaseDatabase.instance.ref('users/$uid').get();
    return snapshot.exists;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen(message: "Checking login status...");
        }

        // Not logged in
        if (!snapshot.hasData || snapshot.data == null) {
          return const AuthPage();
        }

        final user = snapshot.data!;
        return FutureBuilder<bool>(
          future: isUserAllowed(user),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen(message: "Verifying user access...");
            }

            if (snapshot.hasData && snapshot.data == true) {
              return const HomePage();
            } else {
              // Auto-sign out if user not allowed
              FirebaseAuth.instance.signOut();
              return const AuthPage();
            }
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatefulWidget {
  final String message;

  const _LoadingScreen({super.key, required this.message});

  @override
  State<_LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<_LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _rotationController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Basketball bounce animation
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 20.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.bounceOut,
    ));

    // Basketball rotation animation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotationController);

    // Start animations
    _bounceController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5);
    final primaryColor = isDarkMode ? Colors.orange.shade400 : Colors.orange.shade600;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
              const Color(0xFF1A1A1A),
              const Color(0xFF2D2D2D),
              const Color(0xFF1A1A1A),
            ]
                : [
              const Color(0xFFF5F5F5),
              const Color(0xFFE8E8E8),
              const Color(0xFFF5F5F5),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Basketball
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_bounceAnimation.value),
                    child: AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value * 2 * 3.14159,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  primaryColor,
                                  primaryColor.withOpacity(0.8),
                                  Colors.brown.shade800,
                                ],
                                stops: const [0.0, 0.7, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Basketball lines
                                Center(
                                  child: Container(
                                    width: 2,
                                    height: 80,
                                    color: Colors.black.withOpacity(0.8),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: 80,
                                    height: 2,
                                    color: Colors.black.withOpacity(0.8),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 2,
                                      ),
                                    ),
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

              const SizedBox(height: 40),

              // App Title
              Text(
                "🏀 HOOPS ZONE",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 2.0,
                ),
              ),

              const SizedBox(height: 20),

              // Main loading message
              Text(
                widget.message,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle messages
              Text(
                "Getting the court ready...",
                style: TextStyle(
                  fontSize: 16,
                  color: subtitleColor,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                "🏆 Champions never quit 🏆",
                style: TextStyle(
                  fontSize: 14,
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Loading dots animation
              _LoadingDots(color: primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  final Color color;

  const _LoadingDots({required this.color});

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      for (int i = 0; i < _controllers.length; i++) {
        if (mounted) {
          _controllers[i].forward();
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
      await Future.delayed(const Duration(milliseconds: 400));
      for (int i = 0; i < _controllers.length; i++) {
        if (mounted) {
          _controllers[i].reverse();
        }
      }
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: 0.5 + (_animations[index].value * 0.5),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(0.3 + (_animations[index].value * 0.7)),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}