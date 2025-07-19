// ============================================================
// Datei: lib/features/clue/clue_list_screen.dart
// ============================================================

// ============================================================
// SECTION: Imports
// ============================================================
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/clue.dart';
import 'clue_detail_screen.dart';

// ============================================================
// SECTION: ClueListScreen Widget
// ============================================================
class ClueListScreen extends StatefulWidget {
  const ClueListScreen({super.key});

  @override
  State<ClueListScreen> createState() => _ClueListScreenState();
}

// ============================================================
// SECTION: State & Controller
// ============================================================
class _ClueListScreenState extends State<ClueListScreen> {
  final ClueService _clueService = ClueService();
  Map<String, Clue> _clues = {};

// ============================================================
// SECTION: Lifecycle
// ============================================================
  @override
  void initState() {
    super.initState();
    _loadClues();
  }

// ============================================================
// SECTION: Helper-Methoden
// ============================================================
  Future<void> _loadClues() async {
    final loaded = await _clueService.loadClues();
    setState(() => _clues = loaded);
  }

// ============================================================
// SECTION: Build-Method (UI-Aufbau)
// ============================================================
  @override
  Widget build(BuildContext context) {
    // Nur die Hinweise, die als solved markiert sind
    final solvedEntries = _clues.entries
        .where((entry) => entry.value.solved)
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      appBar: AppBar(title: const Text('Gefundene Hinweise')),
      body: solvedEntries.isEmpty
          ? const Center(child: Text('Keine gefundenen Hinweise.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: solvedEntries.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final code = solvedEntries[index].key;
                final clue = solvedEntries[index].value;

                return ListTile(
                  leading: Icon(
                    clue.type == 'text' ? Icons.text_snippet : Icons.image,
                    color: Colors.green,
                  ),
                  title: Text('Code: $code'),
                  subtitle: Text(
                    clue.type == 'text'
                        ? clue.content
                        : (clue.description ?? 'Bildhinweis'),
                  ),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClueDetailScreen(clue: clue),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
