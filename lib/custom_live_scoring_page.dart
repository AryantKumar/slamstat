import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomLiveScoringPage extends StatefulWidget {
  final String teamA, teamB, genderA, genderB;
  final List<String> playersA, playersB;
  final String matchId;

  const CustomLiveScoringPage({
    super.key,
    required this.teamA,
    required this.teamB,
    required this.genderA,
    required this.genderB,
    required this.playersA,
    required this.playersB,
    required this.matchId,
  });

  @override
  State<CustomLiveScoringPage> createState() => _CustomLiveScoringPageState();
}

class _CustomLiveScoringPageState extends State<CustomLiveScoringPage> with TickerProviderStateMixin {
  late DatabaseReference _db;


  final manualA = TextEditingController();
  final manualB = TextEditingController();
  final manualMinuteController = TextEditingController();
  final manualSecondController = TextEditingController();



  bool isLive = false;
  int scoreA = 0, scoreB = 0, quarter = 1;
  Duration matchTime = const Duration(minutes: 10);
  Timer? _timer;
  bool isTimerRunning = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize _db here, now widget.matchId is allowed
    _db = FirebaseDatabase.instance
        .ref()
        .child('custom_live_score')
        .child(widget.matchId);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }


  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    manualA.dispose();
    manualB.dispose();
    manualMinuteController.dispose();
    manualSecondController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (isTimerRunning) return;
    HapticFeedback.lightImpact();
    _pulseController.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (matchTime.inSeconds > 0) {
        setState(() => matchTime -= const Duration(seconds: 1));
        _updateLiveData();
      } else {
        _pauseTimer();
        if (quarter >= 4) {
          _finishMatch(); // 🔥 Finish match after final quarter
        }
      }
    });
    setState(() => isTimerRunning = true);
  }


  void _pauseTimer() {
    _timer?.cancel();
    _pulseController.stop();
    HapticFeedback.lightImpact();
    setState(() => isTimerRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    _pulseController.stop();
    HapticFeedback.mediumImpact();
    setState(() {
      matchTime = const Duration(minutes: 10);
      isTimerRunning = false;
    });
    _updateLiveData();
  }

  void _toggleLive(bool live) {
    HapticFeedback.lightImpact();
    setState(() => isLive = live);
    _updateLiveData();
  }

  void _resetLiveMatch() async {
    HapticFeedback.heavyImpact();
    await _db.remove();
    setState(() {
      isLive = false;
      scoreA = scoreB = quarter = 0;
      quarter = 1;
      matchTime = const Duration(minutes: 10);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("🏀 Match reset!", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _updateLiveData() {
    _db.set({
      'teamA': widget.playersA.isNotEmpty ? widget.playersA.first : widget.teamA,
      'teamB': widget.playersB.isNotEmpty ? widget.playersB.first : widget.teamB,
      'scoreA': scoreA,
      'scoreB': scoreB,
      'quarter': quarter,
      'live': isLive,
      'time': _formatTime(matchTime),
    });
  }

  void _finishMatch() async {
    // Stop timer and live status
    _pauseTimer();
    setState(() => isLive = false);

    final matchSummary = {
      'finalScoreA': scoreA,
      'finalScoreB': scoreB,
      'status': 'completed',
      'endedAt': DateTime.now().toIso8601String(),
      'quarter': quarter,
      'duration': _formatTime(matchTime),
      'live': false,
    };

    await FirebaseDatabase.instance
        .ref()
        .child('matches')
        .child(widget.matchId)
        .update(matchSummary);

    // Also update live data to reflect completion
    _updateLiveData();
  }

  void _manualSetTimer() {
    final minText = manualMinuteController.text.trim();
    final secText = manualSecondController.text.trim();

    final minutes = int.tryParse(minText) ?? 0;
    final seconds = int.tryParse(secText) ?? 0;

    if (minutes < 0 || seconds < 0 || seconds >= 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter valid minutes and seconds (0–59)'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      matchTime = Duration(minutes: minutes, seconds: seconds);
    });

    _updateLiveData();
    HapticFeedback.lightImpact();
  }


  String _formatTime(Duration d) => '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  Widget _buildTeamScore(String team, String player, int score, Function(int) onScore, TextEditingController controller, bool isTeamA) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teamColor = isTeamA ? Colors.blue : Colors.orange;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [teamColor.withOpacity(0.1), teamColor.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: teamColor.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: teamColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: isDark ? ColorFilter.mode(Colors.white.withOpacity(0.05), BlendMode.overlay) : ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.overlay),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: teamColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.sports_basketball, color: teamColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(team, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: teamColor), overflow: TextOverflow.ellipsis),
                          if (player.isNotEmpty && player != team)
                            Text(player, style: GoogleFonts.poppins(fontSize: 14, color: teamColor.withOpacity(0.7)), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Score Display
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: teamColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: teamColor.withOpacity(0.3)),
                  ),
                  child: Text('$score', style: GoogleFonts.orbitron(fontSize: 48, fontWeight: FontWeight.w900, color: teamColor, letterSpacing: 2)),
                ),
                const SizedBox(height: 20),
                // Quick Score Buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [1, 2, 3, -1, -2, -3].map((val) => _scoreButton(val > 0 ? '+$val' : '$val', () {
                    onScore(val);
                    HapticFeedback.lightImpact();
                  }, teamColor, val > 0 ? Icons.add : Icons.remove)).toList(),
                ),
                const SizedBox(height: 16),
                // Manual Score Entry
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: teamColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            labelText: 'Manual Score Entry',
                            labelStyle: GoogleFonts.poppins(color: teamColor),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.edit, color: teamColor),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(color: teamColor, borderRadius: BorderRadius.circular(10)),
                        child: IconButton(
                          icon: const Icon(Icons.check, color: Colors.white),
                          onPressed: isLive ? () {
                            final val = int.tryParse(controller.text);
                            if (val != null && val >= 0) {
                              onScore(val - score);
                              controller.clear();
                              HapticFeedback.lightImpact();
                            }
                          } : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _scoreButton(String label, VoidCallback onPressed, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ElevatedButton.icon(
        onPressed: isLive ? onPressed : null,
        icon: Icon(icon, size: 16),
        label: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildControlButton({required String label, required IconData icon, required VoidCallback onPressed, Color? color, bool isDestructive = false}) {
    final buttonColor = isDestructive ? Colors.red : (color ?? Colors.blue);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [buttonColor, buttonColor.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: buttonColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final playerA = widget.playersA.isNotEmpty ? widget.playersA.first : widget.teamA;
    final playerB = widget.playersB.isNotEmpty ? widget.playersB.first : widget.teamB;
    final timeText = _formatTime(matchTime);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrange]), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.sports_basketball, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Custom Live Scoring', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: isDark ? [const Color(0xFF1A1A1A), const Color(0xFF2D2D2D)] : [Colors.white, Colors.grey.shade50]),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Game Status Header
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.purple.withOpacity(0.1), Colors.blue.withOpacity(0.1)]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                  boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Column(
                  children: [
                    // Timer Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.timer, color: Colors.purple, size: 28),
                        const SizedBox(width: 8),
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: isTimerRunning ? _pulseAnimation.value : 1.0,
                              child: Text(timeText, style: GoogleFonts.orbitron(fontSize: 36, fontWeight: FontWeight.w900, color: isTimerRunning ? Colors.red : Colors.purple, letterSpacing: 2)),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Quarter and Live Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.purple.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sports, color: Colors.purple, size: 20),
                              const SizedBox(width: 8),
                              Text('Quarter $quarter', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: isLive ? Colors.red.withOpacity(0.2) : Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(isLive ? Icons.circle : Icons.circle_outlined, color: isLive ? Colors.red : Colors.grey, size: 12),
                              const SizedBox(width: 4),
                              Text(isLive ? "LIVE" : "OFF", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isLive ? Colors.red : Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Manual Timer Setter UI
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: manualMinuteController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Minutes",
                          prefixIcon: const Icon(Icons.timelapse),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: manualSecondController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Seconds",
                          prefixIcon: const Icon(Icons.timer),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _manualSetTimer,
                      icon: const Icon(Icons.check),
                      label: const Text("Set Timer"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),

              // Timer Controls
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildControlButton(label: "Start Timer", icon: Icons.play_arrow, onPressed: _startTimer, color: Colors.green),
                    _buildControlButton(label: "Pause Timer", icon: Icons.pause, onPressed: _pauseTimer, color: Colors.orange),
                    _buildControlButton(label: "Reset Timer", icon: Icons.restart_alt, onPressed: _resetTimer, color: Colors.blue),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              // Live Controls
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildControlButton(label: "Start Live", icon: Icons.play_circle, onPressed: () => _toggleLive(true), color: Colors.green),
                    _buildControlButton(label: "Stop Live", icon: Icons.stop_circle, onPressed: () => _toggleLive(false), color: Colors.red),
                    _buildControlButton(label: "Reset Live", icon: Icons.delete_forever, onPressed: _resetLiveMatch, isDestructive: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),


              // Quarter Controls
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Quarter: ", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                    Container(
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: quarter > 1 ? () {
                          HapticFeedback.lightImpact();
                          setState(() => quarter--);
                          _updateLiveData();
                        } : null,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]), borderRadius: BorderRadius.circular(12)),
                      child: Text("$quarter", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() => quarter++);
                          _updateLiveData();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Team Scores
              _buildTeamScore(widget.teamA, playerA, scoreA, (delta) {
                setState(() => scoreA = (scoreA + delta).clamp(0, 999));
                _updateLiveData();
              }, manualA, true),
              _buildTeamScore(widget.teamB, playerB, scoreB, (delta) {
                setState(() => scoreB = (scoreB + delta).clamp(0, 999));
                _updateLiveData();
              }, manualB, false),

              const SizedBox(height: 16),
              // Finish Match Button
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildControlButton(
                  label: "Finish Match",
                  icon: Icons.flag,
                  color: Colors.deepPurple,
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Row(
                          children: [
                            Icon(Icons.flag, color: Colors.deepPurple),
                            const SizedBox(width: 8),
                            const Text("Finish Match?"),
                          ],
                        ),
                        content: const Text("Are you sure the match is completed? This will mark the match as finished and stop all timers."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Finish"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      _finishMatch();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("🏁 Match marked as finished!", style: TextStyle(color: Colors.white)),
                            backgroundColor: Colors.deepPurple,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}