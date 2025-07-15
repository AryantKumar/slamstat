import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class StatTablePage extends StatefulWidget {
  const StatTablePage({super.key});

  @override
  State<StatTablePage> createState() => _StatTablePageState();
}

class _StatTablePageState extends State<StatTablePage> {
  int totalTeams = 0;
  int totalPlayers = 0;
  bool isLoading = true;

  final _db = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    try {
      final boysSnapshot = await _db.child("teams/${user.uid}/boys").get();
      final girlsSnapshot = await _db.child("teams/${user.uid}/girls").get();

      int teamCount = 0;
      int playerCount = 0;

      for (final team in boysSnapshot.children) {
        teamCount++;
        final players = team.child("players").value as List<dynamic>?;
        if (players != null) playerCount += players.length;
      }

      for (final team in girlsSnapshot.children) {
        teamCount++;
        final players = team.child("players").value as List<dynamic>?;
        if (players != null) playerCount += players.length;
      }

      setState(() {
        totalTeams = teamCount;
        totalPlayers = playerCount;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load stats: $e")),
      );
    }
  }

  Widget _buildStatCard(String title, int count, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
                Text("$count",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stat Table'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          const SizedBox(height: 20),
          _buildStatCard("Total Teams", totalTeams, Icons.groups),
          _buildStatCard("Total Players", totalPlayers, Icons.person),
        ],
      ),
    );
  }
}
