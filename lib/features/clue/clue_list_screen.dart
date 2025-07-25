import 'package:flutter/material.dart';
import '../../data/models/clue.dart';
import '../../data/models/hunt.dart';
import 'clue_detail_screen.dart';
import 'gps_navigation_screen.dart'; // NEU: Import für den GPS-Bildschirm

class ClueListScreen extends StatefulWidget {
  final Hunt hunt;
  const ClueListScreen({super.key, required this.hunt});

  @override
  State<ClueListScreen> createState() => _ClueListScreenState();
}

class _ClueListScreenState extends State<ClueListScreen> {
  @override
  Widget build(BuildContext context) {
    final viewedEntries =
        widget.hunt.clues.entries.where((entry) => entry.value.hasBeenViewed).toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      appBar: AppBar(title: const Text('Missions-Logbuch')),
      body: viewedEntries.isEmpty
          ? const Center(child: Text('Noch keine Hinweise gefunden.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: viewedEntries.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final code = viewedEntries[index].key;
                final clue = viewedEntries[index].value;

                // --- NEUE LOGIK: Icon basierend auf dem Hinweis-Typ auswählen ---
                IconData leadingIcon;
                if (clue.isGpsClue) {
                  leadingIcon = Icons.location_on_outlined;
                } else if (clue.isRiddle) {
                  leadingIcon = Icons.question_answer_outlined;
                } else {
                  leadingIcon = Icons.visibility_outlined;
                }

                return ListTile(
                  leading: Icon(
                    leadingIcon,
                    color: clue.solved ? Colors.greenAccent : Colors.white,
                  ),
                  title: Text(clue.isGpsClue ? 'GPS-Ziel: $code' : 'Code: $code'),
                  subtitle: Text(
                    clue.question ?? clue.description ?? clue.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: clue.solved
                      ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                      : (clue.isRiddle ? const Icon(Icons.lock_open_outlined) : null),
                  onTap: () {
                    // --- NEUE LOGIK: Zum richtigen Bildschirm navigieren ---
                    if (clue.isGpsClue) {
                      // Wenn es ein GPS-Hinweis ist, öffne den Navigationsbildschirm
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GpsNavigationScreen(hunt: widget.hunt, clue: clue),
                        ),
                      );
                    } else {
                      // Ansonsten öffne den normalen Detailbildschirm
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClueDetailScreen(hunt: widget.hunt, clue: clue),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
