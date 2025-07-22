// ============================================================
// SECTION: Imports
// ============================================================
import 'package:flutter/material.dart';
import '../../data/models/clue.dart';
import '../../data/models/hunt.dart'; // NEU: Import für das Hunt-Modell
import 'clue_detail_screen.dart';

// ============================================================
// SECTION: ClueListScreen Widget
// ============================================================
class ClueListScreen extends StatefulWidget {
  // NEU: Der Screen erwartet jetzt die aktuelle Jagd.
  final Hunt hunt;

  const ClueListScreen({super.key, required this.hunt});

  @override
  State<ClueListScreen> createState() => _ClueListScreenState();
}

// ============================================================
// SECTION: State-Klasse
// ============================================================
class _ClueListScreenState extends State<ClueListScreen> {
  // ============================================================
  // SECTION: Build-Method (UI-Aufbau)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    // Die Hinweise werden direkt aus der übergebenen Jagd gefiltert.
    final solvedEntries =
        widget.hunt.clues.entries.where((entry) => entry.value.solved).toList()
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

                return ListTile(
                  leading: Icon(
                    clue.type == 'text' ? Icons.text_snippet : Icons.image,
                    color: Colors.green,
                  ),
                  title: Text('Code: $code'),
                  subtitle: Text(clue.isRiddle ? clue.question! : clue.content),
                  trailing:
                      const Icon(Icons.check_circle, color: Colors.green),
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
