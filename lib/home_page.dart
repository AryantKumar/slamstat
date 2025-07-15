import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'auth_page.dart';
import 'set_match_options.dart';
import 'view_teams_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final _db = FirebaseDatabase.instance.ref();
  int totalTeams = 0, totalPlayers = 0;
  bool isLoadingStats = true;
  StreamSubscription<DatabaseEvent>? _statsSubscription;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation, _slideAnimation;

  static const _gradients = {
    'primary': [Color(0xFFFF6B35), Color(0xFFFF8E53), Color(0xFFFFB347)],
    'secondary': [Color(0xFF2C2C2C), Color(0xFF1A1A1A), Color(0xFF404040)],
    'header': [Color(0xFF1A1A1A), Color(0xFF2C2C2C), Color(0xFF404040), Color(0xFFFF6B35)],
  };

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _listenToStats();
  }

  void _initAnimations() {
    _animationController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.3, 1.0, curve: Curves.elasticOut)),
    );
    _animationController.forward();
  }

  void _listenToStats() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _statsSubscription = _db.child("teams/$uid").onValue.listen((event) {
      int teamCount = 0, playerCount = 0;
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      data?.forEach((genderKey, teamGroup) {
        if (teamGroup is Map) {
          teamCount += teamGroup.length;
          teamGroup.forEach((teamKey, teamData) {
            if (teamData is Map && teamData["players"] is List) {
              playerCount += (teamData["players"] as List).length;
            }
          });
        }
      });

      setState(() {
        totalTeams = teamCount;
        totalPlayers = playerCount;
        isLoadingStats = false;
      });
    });
  }

  @override
  void dispose() {
    _statsSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthPage()));
  }

Widget _buildAnimatedCard({required Widget child, int delay = 0}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) => Transform.translate(
        offset: Offset(0, _slideAnimation.value * (delay + 1)),
        child: Opacity(opacity: _fadeAnimation.value, child: child),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required String gradientKey,
    int delay = 0,
  }) {
    final colors = _gradients[gradientKey]!;
    return _buildAnimatedCard(
      delay: delay,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [
            BoxShadow(color: colors[0].withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Icon(icon, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
                    child: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({required String title, required int value, required IconData icon, required String gradientKey, int delay = 0}) {
    final colors = _gradients[gradientKey]!;
    return _buildAnimatedCard(
      delay: delay,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [
            BoxShadow(color: colors[0].withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Icon(icon, size: 28, color: Colors.white),
                  ),
                  Icon(Icons.sports_basketball, size: 24, color: Colors.white.withOpacity(0.3)),
                ],
              ),
              const SizedBox(height: 20),
              Text(title, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('$value', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBasketball() {
    return Positioned(
      right: -40,
      top: -40,
      child: TweenAnimationBuilder(
        duration: const Duration(seconds: 4),
        tween: Tween<double>(begin: 0, end: 2 * 3.14159),
        builder: (context, double angle, child) => Transform.rotate(
          angle: angle,
          child: Opacity(opacity: 0.1, child: const Icon(Icons.sports_basketball, size: 120, color: Colors.white)),
        ),
        onEnd: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('SlamStat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
              background: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: _gradients['header']!, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    ),
                  ),
                  _buildFloatingBasketball(),
                  const Positioned(
                    left: -30,
                    bottom: -20,
                    child: Opacity(opacity: 0.1, child: Icon(Icons.sports_basketball, size: 80, color: Colors.white)),
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: _gradients['primary']!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(onPressed: () => _logout(context), icon: const Icon(Icons.logout, color: Colors.white)),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Welcome Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(colors: [_gradients['primary']![0].withOpacity(0.1), _gradients['primary']![1].withOpacity(0.05)]),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: _gradients['primary']!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.waving_hand, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Welcome Back!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                              Text('Ready to dominate the court? 🏀', style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Action Cards
                  _buildActionCard(
                    icon: Icons.sports_basketball,
                    title: 'Start New Match',
                    subtitle: 'Set up teams and begin the game',
                    gradientKey: 'primary',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SetMatchOptionsPage())),
                  ),
                  _buildActionCard(
                    icon: Icons.groups,
                    title: 'Manage Teams',
                    subtitle: 'View and organize your squads',
                    gradientKey: 'secondary',
                    delay: 1,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewTeamsPage())),
                  ),
                  const SizedBox(height: 40),
                  // Stats Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: _gradients['primary']!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text('Game Statistics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stats Cards or Loading
                  isLoadingStats
                      ? Container(
                    margin: const EdgeInsets.all(40),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(colors: _gradients['primary']!),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          SizedBox(height: 16),
                          Text('Loading your stats...', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  )
                      : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(child: _buildStatCard(title: "Total Teams", value: totalTeams, icon: Icons.group, gradientKey: 'primary', delay: 2)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard(title: "Total Players", value: totalPlayers, icon: Icons.person, gradientKey: 'secondary', delay: 3)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}