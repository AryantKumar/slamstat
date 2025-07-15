import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;
  bool isPasswordVisible = false;
  Color? passwordBorderColor;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance.ref();

  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late AnimationController _courtController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _courtAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _courtController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _courtAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _courtController,
      curve: Curves.easeInOut,
    ));

    _bounceController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _fadeController.dispose();
    _courtController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    setState(() {
      isLoading = true;
      passwordBorderColor = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!isLogin && password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.sports_basketball, color: Colors.white),
              SizedBox(width: 8),
              Text("Password must be at least 8 characters"),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      UserCredential userCred;

      if (isLogin) {
        userCred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        setState(() => passwordBorderColor = Colors.green);

        // Navigate to Home Page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        userCred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await _db.child("users/${userCred.user!.uid}").set({
          "email": email,
          "firstName": _firstNameController.text.trim(),
          "lastName": _lastNameController.text.trim(),
          "createdAt": DateTime.now().toIso8601String(),
        });

        setState(() {
          passwordBorderColor = Colors.green;
          isLogin = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.white),
                SizedBox(width: 8),
                Text("Welcome to the Squad! 🏀"),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => passwordBorderColor = Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.block, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(e.message ?? "Blocked shot! Try again")),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.sports_basketball, color: Colors.white),
              SizedBox(width: 8),
              Text("Enter your email to reset password"),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.mail_outline, color: Colors.white),
              SizedBox(width: 8),
              Text("Reset link sent! Check your inbox 📧"),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(e.message ?? "Reset failed")),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    Color? borderColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword && !isPasswordVisible,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.2),
                    Colors.deepOrange.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.orange.shade700,
                size: 20,
              ),
            ),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() => isPasswordVisible = !isPasswordVisible);
              },
            )
                : null,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: borderColor ?? Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: borderColor ?? Colors.orange.shade600,
                width: 2.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildBasketballCourt() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final courtColor = isDark
        ? Colors.orange.withOpacity(0.1)
        : Colors.orange.withOpacity(0.08);

    return AnimatedBuilder(
      animation: _courtAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, 100),
          painter: BasketballCourtPainter(
            courtColor,
            _courtAnimation.value,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
              colorScheme.background,
              colorScheme.surface.withOpacity(0.5),
              colorScheme.primary.withOpacity(0.03),
            ]
                : [
              colorScheme.background,
              colorScheme.primaryContainer.withOpacity(0.1),
              colorScheme.secondaryContainer.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Basketball court background
              Positioned.fill(
                child: _buildBasketballCourt(),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Enhanced basketball header
                        ScaleTransition(
                          scale: _bounceAnimation,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        colors: [
                                          colorScheme.primary.withOpacity(0.2),
                                          colorScheme.primary.withOpacity(0.05),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colorScheme.primary.withOpacity(0.3),
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.primary.withOpacity(0.2),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.sports_basketball,
                                      size: 48,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Colors.orange.shade600,
                                    Colors.deepOrange.shade700,
                                    colorScheme.primary,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  "SlamStat",
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2.0,
                                    shadows: [
                                      Shadow(
                                        color: Colors.orange.withOpacity(0.4),
                                        offset: const Offset(0, 4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.withOpacity(0.8),
                                      Colors.deepOrange.withOpacity(0.6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.3),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "🏀 Elevate Your Game 🏀",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Enhanced toggle with basketball theme
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLogin = true),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      color: isLogin ? Colors.orange.shade600 : Colors.transparent,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: isLogin
                                          ? [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.login_rounded,
                                          color: isLogin ? Colors.white : colorScheme.onSurfaceVariant,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Sign In",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: isLogin ? Colors.white : colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLogin = false),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      color: !isLogin ? Colors.orange.shade600 : Colors.transparent,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: !isLogin
                                          ? [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person_add_rounded,
                                          color: !isLogin ? Colors.white : colorScheme.onSurfaceVariant,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Sign Up",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: !isLogin ? Colors.white : colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Enhanced form fields
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          child: Column(
                            children: [
                              if (!isLogin) ...[
                                _buildTextField(
                                  controller: _firstNameController,
                                  label: "First Name",
                                  icon: Icons.person_outline_rounded,
                                ),
                                _buildTextField(
                                  controller: _lastNameController,
                                  label: "Last Name",
                                  icon: Icons.person_rounded,
                                ),
                              ],
                              _buildTextField(
                                controller: _emailController,
                                label: "Email",
                                icon: Icons.email_outlined,
                              ),
                              _buildTextField(
                                controller: _passwordController,
                                label: "Password",
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                                borderColor: passwordBorderColor,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Enhanced forgot password
                        if (isLogin)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _forgotPassword,
                              icon: Icon(
                                Icons.help_outline_rounded,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              label: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Enhanced action button with basketball theme
                        Container(
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: isLoading
                              ? Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.withOpacity(0.8),
                                  Colors.deepOrange.withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    "Processing...",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              : ElevatedButton(
                            onPressed: _handleAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.shade600,
                                    Colors.deepOrange.shade700,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                height: 64,
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isLogin ? Icons.sports_basketball : Icons.emoji_events,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      isLogin ? "🏀 Enter the Court" : "🏆 Join the Squad",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Basketball court line decoration with orange
                        Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 60),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.orange.withOpacity(0.5),
                                Colors.orange.shade600,
                                Colors.deepOrange.shade700,
                                Colors.orange.shade600,
                                Colors.orange.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Basketball emoji footer with orange theme
                        Center(
                          child: Text(
                            "🏀🔥🏆",
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.orange.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class BasketballCourtPainter extends CustomPainter {
  final Color courtColor;
  final double animationValue;

  BasketballCourtPainter(this.courtColor, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = courtColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw court lines
    final centerY = size.height / 2;

    // Center line
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      paint,
    );

    // Three-point arcs
    final arcRect = Rect.fromCenter(
      center: Offset(size.width / 4, centerY),
      width: 100,
      height: 100,
    );

    canvas.drawArc(
      arcRect,
      -1.57 + (animationValue * 0.2),
      3.14,
      false,
      paint,
    );

    final arcRect2 = Rect.fromCenter(
      center: Offset(3 * size.width / 4, centerY),
      width: 100,
      height: 100,
    );

    canvas.drawArc(
      arcRect2,
      -1.57 - (animationValue * 0.2),
      3.14,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}