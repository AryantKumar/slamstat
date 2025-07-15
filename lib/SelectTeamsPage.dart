import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'view_teams_page.dart';
import 'live_scoring_page.dart';

class SelectTeamsPage extends StatefulWidget {
  final String selectedMatchType;
  final String selectedFormat;

  const SelectTeamsPage({
    super.key,
    required this.selectedMatchType,
    required this.selectedFormat,
  });

  @override
  State<SelectTeamsPage> createState() => _SelectTeamsPageState();
}

class _SelectTeamsPageState extends State<SelectTeamsPage>
    with TickerProviderStateMixin {
  String? teamA;
  String? teamB;
  String? genderA;
  String? genderB;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    _bounceController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _selectTeam(bool isTeamA) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ViewTeamsPage(selectingTeam: true),
      ),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        if (isTeamA) {
          teamA = result['name'];
          genderA = result['gender'];
        } else {
          teamB = result['name'];
          genderB = result['gender'];
        }
      });
    }
  }

  Future<void> _startMatch() async {
    if (teamA == null || teamB == null || genderA == null || genderB == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select both teams properly."),
          backgroundColor: Colors.deepOrange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final matchRef = FirebaseDatabase.instance.ref().child("matches").push();

    await matchRef.set({
      "teamA": teamA,
      "teamB": teamB,
      "genderA": genderA,
      "genderB": genderB,
      "type": widget.selectedMatchType,
      "format": widget.selectedFormat,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "status": "upcoming",
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveScoringPage(
          matchId: matchRef.key!,
          teamA: teamA!,
          genderA: genderA!,
          teamB: teamB!,
          genderB: genderB!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryOrange = isDark ? Colors.deepOrange.shade600 : Colors.deepOrange.shade700;
    final accentOrange = isDark ? Colors.orange.shade400 : Colors.orange.shade600;
    final backgroundColor = isDark ? Colors.grey.shade900 : Colors.grey.shade100;
    final cardColor = isDark ? Colors.grey.shade800 : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: primaryOrange,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryOrange.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 2,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.black,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            const Text(
              "Select Teams",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: cardColor,
        foregroundColor: textColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight -
                40,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryOrange, accentOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryOrange.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.sports_basketball, color: Colors.white, size: 40),
                        SizedBox(height: 8),
                        Text(
                          "GAME SETUP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Team Cards
                _buildTeamCard(
                  isTeamA: true,
                  teamName: teamA,
                  gender: genderA,
                  cardColor: cardColor,
                  primaryColor: primaryOrange,
                  textColor: textColor,
                ),
                const SizedBox(height: 16),
                _buildTeamCard(
                  isTeamA: false,
                  teamName: teamB,
                  gender: genderB,
                  cardColor: cardColor,
                  primaryColor: primaryOrange,
                  textColor: textColor,
                ),
                const SizedBox(height: 16),

                if (teamA != null && teamB != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: primaryOrange, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: primaryOrange.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Text(teamA!, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(12)),
                          child: const Text("VS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: Text(teamB!, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                const Spacer(),

                // Start Match Button
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: teamA != null && teamB != null
                          ? [primaryOrange, accentOrange]
                          : [Colors.grey.shade400, Colors.grey.shade500],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: teamA != null && teamB != null ? _startMatch : null,
                      child: const Center(
                        child: Text(
                          "START MATCH",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCard({
    required bool isTeamA,
    required String? teamName,
    required String? gender,
    required Color cardColor,
    required Color primaryColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: teamName != null ? primaryColor : Colors.grey.shade300,
          width: teamName != null ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _selectTeam(isTeamA),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.group, size: 32, color: primaryColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        teamName != null ? "Team ${isTeamA ? 'A' : 'B'}: $teamName" : "Select Team ${isTeamA ? 'A' : 'B'}",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      if (gender != null)
                        Text(gender!, style: TextStyle(fontSize: 14, color: primaryColor, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: teamName != null ? primaryColor : Colors.grey.shade400, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
