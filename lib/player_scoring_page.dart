import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PlayerScoringPage extends StatefulWidget {
  final String teamName;
  final String gender;

  const PlayerScoringPage({
    super.key,
    required this.teamName,
    required this.gender,
  });

  @override
  State<PlayerScoringPage> createState() => _PlayerScoringPageState();
}

class _PlayerScoringPageState extends State<PlayerScoringPage> {
  final _db = FirebaseDatabase.instance.ref();
  List<String> players = [];
  Map<String, int> scores = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    try {
      setState(() => _isLoading = true);

      final snapshot = await _db.child('teams/${widget.gender}/${widget.teamName}/players').get();
      final playerDataList = snapshot.value as List<dynamic>? ?? [];

      setState(() {
        players = playerDataList.map<String>((playerMap) {
          final map = playerMap as Map<dynamic, dynamic>;
          return map['name']?.toString() ?? '';
        }).where((name) => name.isNotEmpty).toList();

        for (var player in players) {
          scores[player] = 0;
        }
      });

      final scoresSnapshot =
      await _db.child('teams/${widget.gender}/${widget.teamName}/playerScores').get();
      final existingScores = (scoresSnapshot.value as Map?)?.cast<String, dynamic>() ?? {};

      setState(() {
        for (var entry in existingScores.entries) {
          scores[entry.key] = int.tryParse(entry.value.toString()) ?? 0;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading players: $e")),
        );
      }
    }
  }

  void _updateScore(String player, int delta) {
    setState(() {
      scores[player] = (scores[player] ?? 0) + delta;
    });
  }

  void _manualScoreDialog(String player) {
    final controller = TextEditingController(text: scores[player]?.toString() ?? "0");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Set score for $player"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Enter score",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null) {
                setState(() {
                  scores[player] = val;
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveScoresToFirebase() async {
    try {
      final teamRef = _db.child('teams/${widget.gender}/${widget.teamName}/players');
      final snapshot = await teamRef.get();

      final playersData = snapshot.value as List<dynamic>? ?? [];

      for (int i = 0; i < playersData.length; i++) {
        final player = playersData[i] as Map;
        final name = player['name']?.toString() ?? '';
        final currentScore = player['score'] ?? 0;
        final newScore = scores[name] ?? 0;

        // Add new score to existing score
        final updatedScore = (currentScore is int ? currentScore : 0) + newScore;

        // Update score in Firebase
        await teamRef.child('$i/score').set(updatedScore);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Scores added to previous values!"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving scores: $e"),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _resetScores() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset All Scores"),
        content: const Text("Are you sure you want to reset all player scores to 0?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Reset"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final teamRef = _db.child('teams/${widget.gender}/${widget.teamName}/players');
      final snapshot = await teamRef.get();

      final playersData = snapshot.value as List<dynamic>? ?? [];

      for (int i = 0; i < playersData.length; i++) {
        await teamRef.child('$i/score').set(0);
      }

      setState(() {
        for (var player in scores.keys) {
          scores[player] = 0;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("All player scores reset to 0!"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error resetting scores: $e"),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildScoreButton({
    required String label,
    required VoidCallback onPressed,
    required bool isDecrease,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 36,
      height: 36,
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: isDecrease
              ? colorScheme.errorContainer.withOpacity(0.3)
              : colorScheme.primaryContainer.withOpacity(0.3),
          foregroundColor: isDecrease
              ? colorScheme.onErrorContainer
              : colorScheme.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPlayerCard(String player) {
    final colorScheme = Theme.of(context).colorScheme;
    final score = scores[player] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: score >= 0
                              ? colorScheme.primaryContainer.withOpacity(0.3)
                              : colorScheme.errorContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Score: $score',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: score >= 0
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _manualScoreDialog(player),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit score manually',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                    foregroundColor: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildScoreButton(
                    label: "-3",
                    onPressed: () => _updateScore(player, -3),
                    isDecrease: true,
                  ),
                  const SizedBox(width: 8),
                  _buildScoreButton(
                    label: "-2",
                    onPressed: () => _updateScore(player, -2),
                    isDecrease: true,
                  ),
                  const SizedBox(width: 8),
                  _buildScoreButton(
                    label: "-1",
                    onPressed: () => _updateScore(player, -1),
                    isDecrease: true,
                  ),
                  const SizedBox(width: 16),
                  _buildScoreButton(
                    label: "+1",
                    onPressed: () => _updateScore(player, 1),
                    isDecrease: false,
                  ),
                  const SizedBox(width: 8),
                  _buildScoreButton(
                    label: "+2",
                    onPressed: () => _updateScore(player, 2),
                    isDecrease: false,
                  ),
                  const SizedBox(width: 8),
                  _buildScoreButton(
                    label: "+3",
                    onPressed: () => _updateScore(player, 3),
                    isDecrease: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Player Scores',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              widget.teamName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveScoresToFirebase,
            tooltip: 'Save Scores',
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer.withOpacity(0.3),
              foregroundColor: colorScheme.onPrimaryContainer,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt_outlined),
            onPressed: _resetScores,
            tooltip: 'Reset All Scores',
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.errorContainer.withOpacity(0.3),
              foregroundColor: colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading players...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      )
          : players.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No players found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add players to your team first',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadPlayers,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: players.length,
          itemBuilder: (context, index) => _buildPlayerCard(players[index]),
        ),
      ),
    );
  }
}