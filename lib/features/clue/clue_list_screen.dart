// ============================================================
// SECTION: Imports
// ============================================================
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/clue.dart';
import 'clue_detail_screen.dart'; // Dieser Import ist korrekt, wenn beide Dateien im selben Ordner liegen.

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
    if (mounted) {
      setState(() => _clues = loaded);
    }
  }

  // ============================================================
  // SECTION: Build-Method (UI-Aufbau)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    // Filtert die Liste, um nur die gelösten Hinweise anzuzeigen.
    final solvedEntries =
        _clues.entries.where((entry) => entry.value.solved).toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      appBar: AppBar(title: const Text('Gefundene Hinweise')),
      body: solvedEntries.isEmpty
          ? const Center(child: Text('Noch keine Hinweise gefunden.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: solvedEntries.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final code = solvedEntries[index].key;
                final clue = solvedEntries[index].value;

                // KORREKTUR: Die Anzeige wurde an das neue Clue-Modell angepasst.
                return ListTile(
                  leading: Icon(
                    // Zeigt das Icon basierend auf dem Typ des Rätsels an.
                    clue.riddleType == 'text'
                        ? Icons.text_snippet
                        : Icons.image,
                    color: Colors.green,
                  ),
                  title: Text('Code: $code'),
                  // Zeigt die Frage des gelösten Rätsels als Zusammenfassung an.
                  subtitle: Text(clue.question),
                  trailing:
                      const Icon(Icons.check_circle, color: Colors.green),
                  onTap: () {
                    // Beim Tippen wird der Detail-Bildschirm geöffnet, der
                    // jetzt direkt die Belohnung anzeigt, da der Hinweis gelöst ist.
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
