import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddMatchScreen extends StatefulWidget {
  const AddMatchScreen({super.key});

  @override
  State<AddMatchScreen> createState() => _AddMatchScreenState();
}

class _AddMatchScreenState extends State<AddMatchScreen> {
  final _teamAController = TextEditingController();
  final _teamBController = TextEditingController();
  final _matchTypeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _db = FirebaseDatabase.instance.ref();

  void _submitMatch() async {
    if (_formKey.currentState!.validate()) {
      final matchData = {
        "teamA": _teamAController.text.trim(),
        "teamB": _teamBController.text.trim(),
        "type": _matchTypeController.text.trim(),
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "status": "upcoming",
      };

      try {
        await _db.child("matches").push().set(matchData);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Match added successfully")),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to add match: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    _matchTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Match")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _teamAController,
                decoration: const InputDecoration(labelText: "Team A"),
                validator: (value) => value == null || value.isEmpty ? "Enter Team A" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _teamBController,
                decoration: const InputDecoration(labelText: "Team B"),
                validator: (value) => value == null || value.isEmpty ? "Enter Team B" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _matchTypeController,
                decoration: const InputDecoration(labelText: "Match Type (e.g. Tournament)"),
                validator: (value) => value == null || value.isEmpty ? "Enter Match Type" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Add Match"),
                onPressed: _submitMatch,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
