import 'package:flutter/material.dart';
import 'enter_player_names.dart';
import 'enter_team_names.dart';
import 'view_teams_page.dart';
import 'SelectTeamsPage.dart';

class SetMatchOptionsPage extends StatefulWidget {
  const SetMatchOptionsPage({super.key});

  @override
  State<SetMatchOptionsPage> createState() => _SetMatchOptionsPageState();
}

class _SetMatchOptionsPageState extends State<SetMatchOptionsPage>
    with TickerProviderStateMixin {
  String? selectedMatchType, selectedFormat;

  final matchTypes = ['Friendly Match', 'College Tournament'];
  final formats = ['1v1', '2v2', '3v3', '4v4', '5v5'];

  late AnimationController _ballBounceController;
  late AnimationController _glowController;
  late AnimationController _slideController;

  final primaryOrange = const Color(0xFFFF6B35);
  final courtOrange = const Color(0xFFE65100);

  @override
  void initState() {
    super.initState();
    _ballBounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _ballBounceController.dispose();
    _glowController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF000000), const Color(0xFF1A0F00), const Color(0xFF2D1A00)]
                : [const Color(0xFFF5F5F5), const Color(0xFFFFE0B2), const Color(0xFFFFCC80)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSexyTopBar(isDark),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildHeroSection(isDark),
                      const SizedBox(height: 30),
                      _buildMatchTypeSection(isDark),
                      const SizedBox(height: 30),
                      _buildFormatSection(isDark),
                      const SizedBox(height: 40),
                      _buildContinueButton(isDark),
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

  Widget _buildSexyTopBar(bool isDark) {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryOrange, courtOrange, const Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Basketball court pattern background
          Positioned.fill(
            child: CustomPaint(
              painter: CourtPatternPainter(),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Back button with glow effect
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3 + 0.3 * _glowController.value),
                            blurRadius: 10 + 10 * _glowController.value,
                            spreadRadius: 2 + 2 * _glowController.value,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.white.withOpacity(0.2),
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(),

                // Title with bouncing basketball
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _ballBounceController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, -4 * _ballBounceController.value),
                              child: const Text('🏀', style: TextStyle(fontSize: 20)),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'COURT SETUP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      height: 2,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Stats icon with pulse
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + 0.1 * _glowController.value,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.bar_chart, color: Colors.white, size: 16),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2A2A2A), const Color(0xFF1A1A1A)]
                : [Colors.white, const Color(0xFFF5F5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryOrange.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              '🏆 GAME SETUP',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: primaryOrange,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure your basketball match',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchTypeSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primaryOrange, courtOrange]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'GAME TYPE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...matchTypes.asMap().entries.map((e) =>
            _buildInteractiveMatchCard(e.value, e.key, isDark)),
      ],
    );
  }

  Widget _buildInteractiveMatchCard(String type, int index, bool isDark) {
    final isSelected = selectedMatchType == type;

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(index == 0 ? -1.0 : 1.0, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Interval(0.2 + index * 0.1, 0.8, curve: Curves.elasticOut),
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() => selectedMatchType = type);
              // Add haptic feedback
            },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: isSelected
                    ? LinearGradient(colors: [primaryOrange, courtOrange])
                    : LinearGradient(colors: isDark
                    ? [const Color(0xFF2A2A2A), const Color(0xFF1A1A1A)]
                    : [Colors.white, const Color(0xFFF8F8F8)]),
                border: Border.all(
                  color: isSelected ? Colors.transparent : primaryOrange.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? primaryOrange.withOpacity(0.4) : Colors.black.withOpacity(0.1),
                    blurRadius: isSelected ? 20 : 10,
                    spreadRadius: isSelected ? 2 : 0,
                    offset: Offset(0, isSelected ? 8 : 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isSelected
                          ? const LinearGradient(colors: [Colors.white, Colors.white70])
                          : LinearGradient(colors: [primaryOrange.withOpacity(0.3), courtOrange.withOpacity(0.3)]),
                      border: !isSelected ? Border.all(color: primaryOrange, width: 2) : null,
                    ),
                    child: isSelected
                        ? Icon(Icons.check, size: 18, color: primaryOrange)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : primaryOrange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type == 'Friendly Match' ? '🏀 Casual pickup games' : '🏆 Championship tournaments',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white70 : (isDark ? Colors.white60 : Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    AnimatedBuilder(
                      animation: _ballBounceController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + 0.1 * _ballBounceController.value,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.sports_basketball, size: 16, color: Colors.white),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormatSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primaryOrange, courtOrange]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.groups, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'TEAM SIZE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: formats.asMap().entries.map((e) =>
              _buildInteractiveFormatChip(e.value, e.key, isDark)).toList(),
        ),
      ],
    );
  }

  Widget _buildInteractiveFormatChip(String format, int index, bool isDark) {
    final isSelected = selectedFormat == format;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Interval(0.4 + index * 0.05, 1.0, curve: Curves.bounceOut),
      )),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => selectedFormat = selectedFormat == format ? null : format),
          borderRadius: BorderRadius.circular(25),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: isSelected
                  ? LinearGradient(colors: [primaryOrange, courtOrange])
                  : LinearGradient(colors: isDark
                  ? [const Color(0xFF2A2A2A), const Color(0xFF1A1A1A)]
                  : [Colors.white, const Color(0xFFF8F8F8)]),
              border: Border.all(
                color: isSelected ? Colors.transparent : primaryOrange.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? primaryOrange.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                  blurRadius: isSelected ? 15 : 5,
                  spreadRadius: isSelected ? 1 : 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: const Icon(Icons.sports_basketball, size: 16, color: Colors.white),
                  ),
                Text(
                  format,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 14,
                    color: isSelected ? Colors.white : primaryOrange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(bool isDark) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryOrange, courtOrange, const Color(0xFFFFB74D)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryOrange.withOpacity(0.4 + 0.2 * _glowController.value),
                blurRadius: 20 + 10 * _glowController.value,
                spreadRadius: 2 + 2 * _glowController.value,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _continue,
              borderRadius: BorderRadius.circular(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _ballBounceController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _ballBounceController.value * 0.1,
                        child: const Icon(Icons.sports_basketball, color: Colors.white, size: 24),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "HIT THE COURT",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _continue() {
    if (selectedMatchType == null) {
      _showError("Please select a match type.");
      return;
    }

    if (selectedFormat == null) {
      if (selectedMatchType == 'College Tournament') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SelectTeamsPage(
              selectedMatchType: selectedMatchType!,
              selectedFormat: '5v5',
            ),
          ),
        );
        return;
      } else {
        _showError("Please select a format for friendly match.");
        return;
      }
    }

    Widget nextPage = selectedFormat == '1v1'
        ? EnterPlayerNamesPage(format: selectedFormat!)
        : EnterTeamNamesPage(format: selectedFormat!);

    Navigator.push(context, MaterialPageRoute(builder: (_) => nextPage));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.red, Colors.redAccent]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.warning, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class CourtPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw basketball court lines
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      30,
      paint,
    );

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}