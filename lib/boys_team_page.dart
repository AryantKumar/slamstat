import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BoysTeamPage extends StatefulWidget {
  final bool selectingTeam;
  const BoysTeamPage({super.key, this.selectingTeam = false});
  @override
  State<BoysTeamPage> createState() => _BoysTeamPageState();
}

class _BoysTeamPageState extends State<BoysTeamPage> with TickerProviderStateMixin {
  late DatabaseReference _db;
  Map<String, dynamic> teams = {};
  late AnimationController _fadeController, _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _slideController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _db = FirebaseDatabase.instance.ref().child('teams/$userId/boys');
      _db.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
        setState(() => teams = data.map((key, value) => MapEntry(key.toString(), value)));
      });
    }

    _fadeController.forward();
    _slideController.forward();
  }
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _showAddTeamDialog() {
    final nameController = TextEditingController();
    final totalPlayersController = TextEditingController();
    final List<TextEditingController> playerControllers = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFAF9F6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isDark ? const Color(0xFFFF6B35) : const Color(0xFFE65100), width: 2)),
            title: Row(children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isDark ? const Color(0xFFFF6B35) : const Color(0xFFE65100), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.sports_basketball, color: Colors.white, size: 24)),
              const SizedBox(width: 12),
              Text('Add Boys Team', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF2C3E50), fontWeight: FontWeight.bold, fontSize: 20)),
            ]),
            content: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(child: Column(children: [
                _buildTextField(nameController, 'Team Name', Icons.group, isDark),
                const SizedBox(height: 16),
                _buildTextField(totalPlayersController, 'Total Players', Icons.people, isDark, TextInputType.number, (val) {
                  final count = int.tryParse(val) ?? 0;
                  playerControllers.clear();
                  for (int i = 0; i < count; i++) playerControllers.add(TextEditingController());
                  setState(() {});
                }),
                if (playerControllers.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: isDark ? const Color(0xFF0F3460).withOpacity(0.3) : const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xFF16213E) : const Color(0xFFBBDEFB))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Icon(Icons.sports_basketball, color: isDark ? const Color(0xFFFF6B35) : const Color(0xFFE65100), size: 20),
                        const SizedBox(width: 8),
                        Text('Player Roster', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2C3E50))),
                      ]),
                      const SizedBox(height: 12),
                      ...playerControllers.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTextField(entry.value, 'Player ${entry.key + 1}', Icons.person, isDark),
                      )),
                    ]),
                  ),
                ],
              ])),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(foregroundColor: isDark ? Colors.grey[400] : Colors.grey[600], padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600))),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty && playerControllers.isNotEmpty) {
                    final players = playerControllers.map((c) => {'name': c.text.trim(), 'score': 0}).toList();
                    _db.child(name).set({'teamName': name, 'totalPlayers': players.length, 'players': players});
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: isDark ? const Color(0xFFFF6B35) : const Color(0xFFE65100), foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 3),
                child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.add, size: 18), const SizedBox(width: 8), const Text('Add Team', style: TextStyle(fontWeight: FontWeight.bold))]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isDark, [TextInputType? keyboardType, void Function(String)? onChanged]) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]),
      child: TextField(
        controller: controller, keyboardType: keyboardType, onChanged: onChanged,
        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF2C3E50), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label, labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: isDark ? const Color(0xFFFF6B35) : const Color(0xFFE65100)),
          filled: true, fillColor: isDark ? const Color(0xFF16213E) : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF16213E) : const Color(0xFFE0E0E0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF16213E) : const Color(0xFFE0E0E0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFFFF6B35) : const Color(0xFFE65100), width: 2)),
        ),
      ),
    );
  }

  void _deleteTeam(String teamName) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFAF9F6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.red.withOpacity(0.5), width: 2)),
          title: Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.warning, color: Colors.white, size: 24)),
            const SizedBox(width: 12),
            Text('Delete Team', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF2C3E50), fontWeight: FontWeight.bold)),
          ]),
          content: Text('Are you sure you want to delete "$teamName"? This action cannot be undone.',
              style: TextStyle(color: isDark ? Colors.grey[300] : const Color(0xFF546E7A))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w600))),
            ElevatedButton(
              onPressed: () { _db.child(teamName).remove(); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F23) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFE65100), foregroundColor: Colors.white, elevation: 0,
        title: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.sports_basketball, size: 24)),
          const SizedBox(width: 12),
          const Text('Boys Teams', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        ]),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(
            colors: isDark ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)] : [const Color(0xFFE65100), const Color(0xFFFF8F00)],
            begin: Alignment.topLeft, end: Alignment.bottomRight))),
      ),
      floatingActionButton: widget.selectingTeam ? null : ScaleTransition(scale: _fadeAnimation,
          child: FloatingActionButton.extended(onPressed: _showAddTeamDialog, backgroundColor: isDark ? const Color(0xFFFF6B35) : const Color(0xFFE65100),
              foregroundColor: Colors.white, elevation: 8, icon: const Icon(Icons.add), label: const Text('Add Team', style: TextStyle(fontWeight: FontWeight.bold)))),
      body: teams.isEmpty ? FadeTransition(opacity: _fadeAnimation, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: isDark ? const Color(0xFF1A1A2E) : Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: isDark ? Colors.black38 : Colors.grey.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))]),
          child: Column(children: [
            Icon(Icons.sports_basketball, size: 80, color: isDark ? const Color(0xFFFF6B35) : const Color(0xFFE65100)),
            const SizedBox(height: 16),
            Text('No Boys Teams Yet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2C3E50))),
            const SizedBox(height: 8),
            Text('Add your first team to get started!', style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          ]),
        ),
      ]))) : FadeTransition(opacity: _fadeAnimation, child: SlideTransition(position: _slideAnimation,
          child: ListView(padding: const EdgeInsets.all(16), children: teams.entries.map((entry) {
            final data = entry.value;
            final players = data['players'] as List<dynamic>? ?? [];

            if (widget.selectingTeam) {
              return Container(margin: const EdgeInsets.only(bottom: 12), child: Material(color: Colors.transparent,
                  child: InkWell(onTap: () => Navigator.pop(context, data['teamName']), borderRadius: BorderRadius.circular(16),
                      child: Container(padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: isDark ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)] : [Colors.white, const Color(0xFFFAF9F6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? const Color(0xFF16213E) : const Color(0xFFE0E0E0)),
                            boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))]),
                        child: Row(children: [
                          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? const Color(0xFFFF6B35) : const Color(0xFFE65100), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.sports_basketball, color: Colors.white, size: 24)),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(data['teamName'] ?? entry.key, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2C3E50))),
                            const SizedBox(height: 4),
                            Text('${data['totalPlayers']} players', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                          ])),
                          Icon(Icons.chevron_right, color: isDark ? const Color(0xFFFF6B35) : const Color(0xFFE65100), size: 28),
                        ]),
                      ))));
            }

            return Container(margin: const EdgeInsets.only(bottom: 16), child: Card(elevation: 8, color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isDark ? const Color(0xFF16213E) : const Color(0xFFE0E0E0))),
                child: Theme(data: Theme.of(context).copyWith(dividerColor: Colors.transparent), child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), childrenPadding: const EdgeInsets.only(bottom: 16),
                  leading: Container(padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(gradient: LinearGradient(colors: isDark ? [const Color(0xFFFF6B35), const Color(0xFFFF8F00)] : [const Color(0xFFE65100), const Color(0xFFFF8F00)]),
                          borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: (isDark ? const Color(0xFFFF6B35) : const Color(0xFFE65100)).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
                      child: const Icon(Icons.sports_basketball, color: Colors.white, size: 24)),
                  title: Text(data['teamName'] ?? entry.key, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2C3E50))),
                  subtitle: Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF0F3460).withOpacity(0.3) : const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(20)),
                      child: Text('${data['totalPlayers']} Players', style: TextStyle(color: isDark ? const Color(0xFFFF6B35) : const Color(0xFFE65100), fontWeight: FontWeight.w600))),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.delete, color: Colors.red, size: 20)), onPressed: () => _deleteTeam(entry.key)),
                    Icon(Icons.expand_more, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ]),
                  children: [Container(margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF0F3460).withOpacity(0.3) : const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? const Color(0xFF16213E) : const Color(0xFFE9ECEF))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Icon(Icons.people, color: isDark ? const Color(0xFFFF6B35) : const Color(0xFFE65100), size: 20),
                          const SizedBox(width: 8),
                          Text('Team Roster', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2C3E50), fontSize: 16)),
                        ]),
                        const SizedBox(height: 12),
                        ...players.map((player) {
                          final name = player['name'] ?? player.toString();
                          final score = player['score'] ?? 0;
                          return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: isDark ? const Color(0xFF16213E) : Colors.white, borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]),
                              child: Row(children: [
                                Container(padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: isDark ? const Color(0xFFFF6B35).withOpacity(0.2) : const Color(0xFFE65100).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                    child: Icon(Icons.person, color: isDark ? const Color(0xFFFF6B35) : const Color(0xFFE65100), size: 18)),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(name, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF2C3E50))),
                                  Text('Score: $score', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                                ])),
                                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: isDark ? const Color(0xFF0F3460) : const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
                                    child: Text('$score', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFFF6B35) : const Color(0xFFE65100)))),
                              ]));
                        }),
                      ]))],
                ))));
          }).toList()))),
    );
  }
}